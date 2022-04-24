ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ENV BASH_ENV="/root/launch.sh"
SHELL ["/bin/bash", "-c"]
ENTRYPOINT [ "/bin/bash", "-C" ]

RUN apt-get update && apt-get upgrade -y && apt-get install -y curl lsb-release gnupg
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
ARG ROS_DISTRO
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y "ros-${ROS_DISTRO}-desktop-full"
RUN apt-get install -y \
        python-rosdep \
        python-rosinstall \
        python-rosinstall-generator \
        python-wstool \
        python-catkin-tools \
        build-essential \
        tmux \
        vim \
        "ros-${ROS_DISTRO}-pr2-gazebo" \
        "ros-${ROS_DISTRO}-joy" \
        "ros-${ROS_DISTRO}-moveit" \
        "ros-${ROS_DISTRO}-moveit-ros" \
        "ros-${ROS_DISTRO}-moveit-pr2" \
        "ros-${ROS_DISTRO}-move-base-msgs" \
        "ros-${ROS_DISTRO}-rosparam-shortcuts"

WORKDIR /catkin_ws
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> $BASH_ENV
RUN mkdir src && catkin init
RUN source /opt/ros/${ROS_DISTRO}/setup.bash
RUN catkin build
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> $BASH_ENV
RUN echo "source /catkin_ws/devel/setup.bash" >> $BASH_ENV

WORKDIR /catkin_ws/src
RUN git clone https://github.com/graziegrazie/jsk_control.git
RUN rosdep init && rosdep update
RUN rosdep install -y --from-paths . --ignore-src --rosdistro ${ROS_DISTRO} ; exit 0
RUN catkin build -c ; exit 0
RUN source /catkin_ws/devel/setup.bash