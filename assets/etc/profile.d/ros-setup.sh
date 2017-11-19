if [ ! -z "$BASH" ]; then
    . /opt/ros/${ROS_DISTRO}/setup.bash
    . /home/pr2/dev/catkin_ws/devel/setup.bash

else
    . /opt/ros/${ROS_DISTRO}/setup.sh
    . /home/pr2/dev/catkin_ws/devel/setup.sh
fi
