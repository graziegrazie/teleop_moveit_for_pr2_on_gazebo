ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN apt-get update && apt-get upgrade -y && apt-get install -y curl lsb-release gnupg
# RUN curl -sSL http://get.gazebosim.org | sh

#COPY --from=osrf/ros:kinetic-desktop-full / /

#RUN apt-get install net-tools
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
#RUN git clone https://github.com/fzi-forschungszentrum-informatik/cartesian_controllers.git
RUN apt-get install -y python-rosdep
RUN rosdep init && rosdep update
#RUN rosdep install -y --from-paths . --ignore-src --rosdistro ${ROS_DISTRO}

RUN git clone https://github.com/graziegrazie/jsk_control.git
RUN git clone https://github.com/graziegrazie/jsk_robot.git
RUN git clone https://github.com/jsk-ros-pkg/jsk_demos.git
RUN git clone https://github.com/jsk-ros-pkg/jsk_common.git
RUN apt-get update
RUN apt-get install -y \
    "ros-${ROS_DISTRO}-jsk-visualization" \
    "ros-${ROS_DISTRO}-jsk-pcl-ros" \
    "ros-${ROS_DISTRO}-jsk-ik-server" \
    "ros-${ROS_DISTRO}-jsk-perception" \
    "ros-${ROS_DISTRO}-jsk-topic-tools" \
    "ros-${ROS_DISTRO}-jsk-pr2eus" \
    "ros-${ROS_DISTRO}-jsk-3rdparty" \
    "ros-${ROS_DISTRO}-jsk-planning" \
    "ros-${ROS_DISTRO}-pr2-bringup" \
    "ros-${ROS_DISTRO}-pr2-navigation" \
    "ros-${ROS_DISTRO}-pr2-apps" \
    "ros-${ROS_DISTRO}-pr2-gripper-sensor-msgs" \
    "ros-${ROS_DISTRO}-navigation" \
    "ros-${ROS_DISTRO}-pointcloud-to-laserscan" \
    "ros-${ROS_DISTRO}-move-base-msgs"

RUN rosdep install -y --from-paths . --ignore-src --rosdistro ${ROS_DISTRO} ; exit 0
RUN catkin build -c ; exit 0
#RUN catkin build -c eus_nlopt eus_qpoases eus_qp jsk_footstep_planner jsk_pr2_startup virtual_force_publisher ; exit 0
#RUN catkin build jsk_maps
RUN source /catkin_ws/devel/setup.bash
RUN rosrun roseus generate-all-msg-srv.sh move_base_msgs 

RUN echo "source /catkin_ws/devel/setup.bash" >> $BASH_ENV
ENV ROBOT sim
RUN apt-get -y install vim