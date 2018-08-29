#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo "Error: please run as root."
	exit 1
fi

root=$PWD

# echo $(logname)

read -p "Do you wish to install ROS? It is required for some SLAM implementations. (Y/N): " res
if [[ $res == [yY] || $res == [yY][eE][sS] ]]; then
	sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
	apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
	apt-get update
	apt-get install ros-indigo-desktop-full
	rosdep init
	echo "Please open a new shell and run 'rosdep update' as a non-root user"
	read -p "Press [enter] to continue"
	echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
	source ~/.bashrc
fi

############################################
################ LSD SLAM ##################
############################################

echo "Installing LSD SLAM..."

yes | apt-get install python-rosinstall
mkdir $PWD/rosbuild_ws
cd $PWD/rosbuild_ws
rosws init . /opt/ros/indigo
mkdir package_dir
yes | rosws set $PWD/package_dir -t .
echo "source $PWD/setup.bash" >> ~/.bashrc
cd package_dir

yes | apt-get install ros-indigo-libg2o ros-indigo-cv-bridge liblapack-dev libblas-dev freeglut3-dev libqglviewer-dev libsuitesparse-dev libx11-dev

git clone https://github.com/tum-vision/lsd_slam.git lsd_slam

#------------------------------------------#

# return to install root
cd $root

############################################
################ ORB SLAM ##################
############################################

echo "Installing ORB SLAM..."

git clone https://github.com/raulmur/ORB_SLAM2.git orb_slam

cd orb_slam
chmod +x build.sh
./build.sh

#------------------------------------------#

# return to install root
cd $root

############################################
################ DSO SLAM ##################
############################################

echo "Installing DSO SLAM..."

git clone https://github.com/JakobEngel/dso.git dso_slam

cd dso_slam
mkdir build
cd build
cmake ..
make -j4

#------------------------------------------#

# return to install root
cd $root

############################################
##### Create Video and Calibration Dirs ####
#### Download process/calibration files ####
############################################

mkdir videos
cd videos

wget https://raw.githubusercontent.com/ZackerySteck/VFC/master/processvideo.sh
wget https://raw.githubusercontent.com/ZackerySteck/VFC/master/create_timestamps.py
chmod +x processvideo.sh

# return to install root
cd $root

mkdir calibration
cd calibration

wget https://raw.githubusercontent.com/ZackerySteck/CCalib/master/calibrate.py

RED='\033[0;31m'
GREEN='033[0;32m'
NC='\033[0m'

echo "INSTALLATION COMPLETE!"
echo -e "${RED}IMPORTANT: please navigate to $PWD/rosbuild_ws/package_dir and execute 'rosmake lsd_slam' to complete installation${NC}"
