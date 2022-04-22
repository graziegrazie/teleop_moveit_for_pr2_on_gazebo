ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get upgrade -y && apt-get install -y curl lsb-release gnupg
# RUN curl -sSL http://get.gazebosim.org | sh

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
ARG ROS_DISTRO
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
        python-rosinstall \
        python-rosinstall-generator \
        python-wstool \
        python-catkin-tools \
        build-essential \
        tmux \
        "ros-${ROS_DISTRO}-desktop-full" \
        "ros-${ROS_DISTRO}-pr2-gazebo" \
        "ros-${ROS_DISTRO}-moveit" \
        "ros-${ROS_DISTRO}-moveit-ros" \
        "ros-${ROS_DISTRO}-moveit-pr2" \
        "ros-${ROS_DISTRO}-rosparam-shortcuts"

ENV BASH_ENV="/root/launch.sh"
SHELL ["/bin/bash", "-c"]
ENTRYPOINT [ "/bin/bash", "-C" ]
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> $BASH_ENV

WORKDIR /catkin_ws
RUN mkdir src && catkin build
RUN source /catkin_ws/devel/setup.bash

WORKDIR /catkin_ws/src
RUN apt-get install -y python-rosdep
RUN rosdep init && rosdep update

RUN git clone https://github.com/graziegrazie/jsk_control.git
RUN apt-get update
RUN apt-get install -y \
    "ros-${ROS_DISTRO}-move-base-msgs"

RUN rosdep install -y --from-paths . --ignore-src --rosdistro ${ROS_DISTRO} ; exit 0
RUN catkin build -c ; exit 0
RUN source /catkin_ws/devel/setup.bash

RUN echo "source /catkin_ws/devel/setup.bash" >> $BASH_ENV
RUN apt-get -y install vim