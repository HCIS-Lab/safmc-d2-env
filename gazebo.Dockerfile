FROM lnfu/safmc-d2-env:desktop AS base

# Add GPG keys for Gazebo and ROS
RUN sudo curl -fsSL https://packages.osrfoundation.org/gazebo.gpg \
    -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg

RUN curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
    | sudo apt-key add -

# Set up Gazebo and ROS repositories
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null

RUN echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/ros2-latest.list > /dev/null

# Installation
RUN sudo -E apt update -y && sudo -E apt install -y \
    gz-harmonic \
    ros-humble-ros-gzharmonic
