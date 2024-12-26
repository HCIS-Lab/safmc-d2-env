FROM ubuntu:22.04

ARG install_type=desktop

ENV DEBIAN_FRONTEND=noninteractive

# Locales (UTF-8)
RUN apt update -y && apt install -y locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Setup Sources
RUN apt install -y \
    curl \
    software-properties-common
RUN add-apt-repository universe
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    --output /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \ 
    | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS2
RUN apt update -y && apt upgrade -y && apt install -y ros-dev-tools
RUN if [ "$install_type" = "desktop" ]; then \
        apt install -y ros-humble-desktop; \
    elif [ "$install_type" = "base" ]; then \
        apt install -y ros-humble-ros-base; \
    else \
        echo "Error: Invalid install_type. Must be 'desktop' or 'base'." && exit 1; \
    fi

# Install common packages
RUN apt-get update && apt-get install -y \
    git \
    iproute2 \
    make \
    python3-pip python-is-python3 \
    tini \
    vim

# Clear APT cache
RUN rm -rf /var/lib/apt/lists/*

# Install Python Packages
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    autopep8==2.3.1 \
    flake8==7.1.1 \
    pycodestyle==2.12.1

RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["tail", "-f", "/dev/null"]
