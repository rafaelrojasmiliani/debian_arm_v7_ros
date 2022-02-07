FROM --platform=linux/arm/v7 rafa606/debian_arm_v7
WORKDIR /catkinws
ENV SSL_CERT_FILE=/usr/lib/ssl/certs/ca-certificates.crt
SHELL ["/bin/bash", "-c"]
RUN mkdir  /catkinws/src && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o \
                        Dpkg::Options::="--force-confnew" \
                        gnupg python3 python3-dev python3-pip build-essential \
                        libyaml-cpp-dev lsb-release isc-dhcp-server && \
    sh -c """ \
    echo deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main \
        > /etc/apt/sources.list.d/ros-latest.list \
    """ && \
    apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' \
        --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends -o \
        Dpkg::Options::="--force-confnew" \
        build-essential \
        git python-pip python-setuptools gcc libpq-dev \
        python-dev  python-pip python3-dev python3-pip python3-venv \
        python3-wheel python-rosdep python-rosinstall-generator \
        python-wstool python-rosinstall && \
    rosdep init && rosdep update && \
        rosinstall_generator \
        controller_manager_msgs roscpp std_msgs controller_interface \
        hardware_interface joint_trajectory_controller pluginlib realtime_tools \
        actionlib_msgs message_generation actionlib control_msgs controller_manager \
        geometry_msgs industrial_robot_status_interface sensor_msgs std_srvs tf \
        tf2_geometry_msgs tf2_eigen tf2_ros tf2_sensor_msgs \
        tf2_py tf2_msgs trajectory_msgs robot_state_publisher \
        joint_state_publisher map_msgs position_controllers tf_conversions \
        joint_state_controller velocity_controllers force_torque_sensor_controller \
        --rosdistro noetic --deps --wet-only --tar > ros.rosinstall && \
    wstool init -j8 src ros.rosinstall && \
    rosdep install -r -q  --from-paths src --ignore-src --rosdistro noetic -y

RUN src/catkin/bin/catkin_make_isolated --install -DCMAKE_BUILD_TYPE=Release -DCATKIN_SKIP_TESTING=ON --install-space /opt/ros/noetic -j1 -DPYTHON_EXECUTABLE=/usr/bin/python3 && \
    cd / && rm -rf /catkinws/*
