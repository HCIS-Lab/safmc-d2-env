FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu22.04

ARG USER_NAME=user
ARG USER_UID=1000
ARG USER_GID=1000
ARG INSTALL_TYPE=desktop

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display

# User
RUN apt update -y && apt install -y sudo \
    groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    mkdir -p /workspace && \
    chown ${USER_UID}:${USER_GID} /workspace

USER ${USER_NAME}
WORKDIR /workspace

# Install Gazebo
RUN sudo apt-get update && sudo apt-get -y install curl lsb-release gnupg \
    sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    sudo apt-get update && \
    sudo apt-get install -y gz-harmonic
    
# Locales (UTF-8)
RUN sudo -E apt update -y && sudo -E apt install -y locales \
    sudo locale-gen en_US en_US.UTF-8 \
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Setup Sources
RUN sudo -E apt install -y \
    curl \
    software-properties-common \
    sudo add-apt-repository universe \
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    --output /usr/share/keyrings/ros-archive-keyring.gpg \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \ 
    | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS2
RUN sudo -E apt update -y && sudo -E apt upgrade -y && sudo -E apt install -y ros-dev-tools \
    if [ "$INSTALL_TYPE" = "desktop" ]; then \
        sudo -E apt install -y ros-humble-desktop; \
    elif [ "$INSTALL_TYPE" = "base" ]; then \
        sudo -E apt install -y ros-humble-ros-base; \
    else \
        echo "Error: Invalid INSTALL_TYPE. Must be 'desktop' or 'base'." && exit 1; \
    fi \
    echo "source /opt/ros/humble/setup.bash" | sudo tee /root/.bashrc \
    echo "source /opt/ros/humble/setup.bash" | tee /home/${USER_NAME}/.bashrc

# Install common packages
RUN sudo -E apt update && sudo -E apt install -y \
    git \
    iproute2 \
    make \
    python3-pip python-is-python3 \
    tini \
    vim \
    python3-sdformat14 libsdformat14 

# Install Python Packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    autopep8==2.3.1 \
    flake8==7.1.1 \
    pycodestyle==2.12.1

RUN sudo apt-get update && sudo apt-get install -y \
    libgl1-mesa-glx \
    libxext6 \
    libx11-6 \
    x11-xserver-utils \
    mesa-utils \
    && sudo apt-get clean

COPY setup /setup
RUN sudo chmod +x /setup/ubuntu.sh && bash /setup/ubuntu.sh

RUN mkdir -p /workspace/packages/src/ && \
    cd /workspace/packages/src && \
    git clone https://github.com/PX4/px4_msgs.git && \
    cd /workspace/packages && \
    colcon build --packages-select px4_msgs --parallel-workers $(nproc) && \
    echo "source /workspace/packages/install/setup.bash" | tee /home/${USER_NAME}/.bashrc && \
    echo "source /workspace/packages/install/setup.bash" | sudo tee /root/.bashrc && \

# Clear APT cache
RUN sudo rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["tail", "-f", "/dev/null"]
