FROM ubuntu:trusty
MAINTAINER Xun Wang <wang.xun@gmail.com> #derived from github.com/uts-magic-lab/ros-docker and osrf/docker_images

# enable the deb src for main.
RUN sed -i '4s/# //' /etc/apt/sources.list
# install packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg2

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    python-catkin-tools \
    python-pip

ENV ROS_DISTRO indigo

# Install ROS
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    ros-${ROS_DISTRO}-desktop-full

# Install additional dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    ros-${ROS_DISTRO}-async-web-server-cpp \
    ros-${ROS_DISTRO}-audio-common-msgs \
    ros-${ROS_DISTRO}-easy-markers \
    ros-${ROS_DISTRO}-kalman-filter \
    ros-${ROS_DISTRO}-cmake-modules \
    ros-${ROS_DISTRO}-rosbridge-server \
    ros-${ROS_DISTRO}-pr2-gazebo \
    ros-${ROS_DISTRO}-move-base-msgs \
    ros-${ROS_DISTRO}-moveit-pr2 \
    ros-${ROS_DISTRO}-moveit-ros-planning-interface \
    ros-${ROS_DISTRO}-pr2-common-action-msgs \
    ros-${ROS_DISTRO}-pr2-power-board \
    ros-${ROS_DISTRO}-sound-play \
    gcc \
    g++ \
    sudo  \
    aptitude  \
    libccrtp-dev \
    vim         \
    nano  \
    python-software-properties \
    automake  \
    libflac-dev \
    libtinyxml-dev \
    libzbar-dev \
    telnet \
    && apt-get autoclean

# Create nonprivileged user
RUN useradd --create-home --shell=/bin/bash pr2

# Run rosdep
RUN rosdep init
USER pr2
WORKDIR /home/pr2
RUN . "/opt/ros/${ROS_DISTRO}/setup.sh" && \
    rosdep update

# Build PR2 workspace
RUN . "/opt/ros/${ROS_DISTRO}/setup.sh" && \
    mkdir -p ~/dev/catkin_ws/src && \
    cd ~/dev/catkin_ws/src && \
    catkin_init_workspace && \
    cd ~/dev/catkin_ws && \
    catkin_make

ENV EDITOR nano -wi

RUN . "/opt/ros/${ROS_DISTRO}/setup.sh" && \
    cd ~/dev/catkin_ws/src && \
    git clone https://github.com/uts-magic-lab/pyride_common_msgs.git && \
    cd ~/dev/catkin_ws && \
    catkin_make

RUN . "/opt/ros/${ROS_DISTRO}/setup.sh" && \
    cd ~/dev/catkin_ws/src && \
    git clone -b indigo-dev --recursive https://github.com/uts-magic-lab/pyride_pr2.git && \
    cd ~/dev/catkin_ws/src/pyride_pr2/celt && \
    ./autogen.sh && \
    ./configure --enable-static --enable-custom-modes --prefix=/home/pr2/dev/catkin_ws/src/pyride_pr2/ && \
    make install && \
    . "/home/pr2/dev/catkin_ws/devel/setup.sh" && \
    cd ~/dev/catkin_ws && \
    catkin_make

ADD assets /

# Publish roscore and rosbridge and pyride port
EXPOSE 11311
EXPOSE 9090
EXPOSE 27005

ENTRYPOINT ["/usr/local/bin/ros_entrypoint"]
