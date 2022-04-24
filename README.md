# Overview
This repositry contains Dockerfile and docker-compose.yml. Those help user to control end-effector on PR2 with MoveIt!. Target pose for MoveIt! is sent from teleop node with gaming controller.

# How to use?
First, please build docker file with docker-compose.yml. This YAML files is composed with reference to [this file](https://github.com/elephantrobotics/mycobot_ros/blob/noetic/docker-compose.yml).
```
docker-compose build nvidia-ros && xhost +local:root && docker-compose up nvidia-ros
```

After attaching to a created container, please perform following commands in terminal on container. Terminal multiplexer such as tmux is useful.
```
roslaunch pr2_gazebo pr2_empty_world.launch
roslaunch pr2_moveit_config move_group.launch
roslaunch pr2_moveit_config moveit_rviz.launch config:=true
rosrun robot_state_publisher robot_state_publisher
roslaunch jsk_teleop_joy pr2_moveit.launch
```