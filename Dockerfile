FROM ubuntu:22.04

ARG USER_NAME=user
ARG USER_UID=1000
ARG USER_GID=1000
ARG INSTALL_TYPE=desktop

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8

# User
RUN apt update -y && apt install -y sudo

RUN groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /workspace && \
    chown ${USER_UID}:${USER_GID} /workspace

USER ${USER_NAME}
WORKDIR /workspace
    
# Locales (UTF-8)
RUN sudo -E apt update -y && sudo -E apt install -y locales
RUN sudo locale-gen en_US en_US.UTF-8
RUN sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Setup Sources
RUN sudo -E apt install -y \
    curl \
    software-properties-common
RUN sudo add-apt-repository universe
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    --output /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \ 
    | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS2
RUN sudo -E apt update -y && sudo -E apt upgrade -y && sudo -E apt install -y ros-dev-tools
RUN if [ "$INSTALL_TYPE" = "desktop" ]; then \
        sudo -E apt install -y ros-humble-desktop; \
    elif [ "$INSTALL_TYPE" = "base" ]; then \
        sudo -E apt install -y ros-humble-ros-base; \
    else \
        echo "Error: Invalid INSTALL_TYPE. Must be 'desktop' or 'base'." && exit 1; \
    fi

RUN echo "source /opt/ros/humble/setup.bash" | sudo tee /root/.bashrc
RUN echo "source /opt/ros/humble/setup.bash" | tee /home/${USER_NAME}/.bashrc
    
# Install common packages
RUN sudo -E apt update && sudo -E apt install -y \
    git \
    iproute2 \
    make \
    python3-pip python-is-python3 \
    tini \
    vim

# Clear APT cache
RUN sudo rm -rf /var/lib/apt/lists/*

# Install Python Packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    autopep8==2.3.1 \
    flake8==7.1.1 \
    pycodestyle==2.12.1

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["tail", "-f", "/dev/null"]
