# Installation steps for a PLDAPS rig with dDPI
# Note: you probably have to run everything as super user

apt-get update
apt-get upgrade

########################################################################################################################
# Install the basic packages
apt-get install apt-utils build-essential clang cmake curl git doxygen 

apt-get install inotify-tools make pkg-config wget python3-gi python3-pyqt5 python3-setuptools

########################################################################################################################
# Install Gstreamer
#
apt-get update
apt-get install libgstreamer1.0-dev libgstreamer-plugins-bad1.0-dev \
        libglib2.0-dev \
        libudev-dev \
        libtinyxml-dev \
        libusb-1.0-0-dev \
        libzip-dev \
        libgirepository1.0-dev \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-tools \
        python3-gst-1.0


########################################################################################################################
# Install Nvidia drivers
#

########################################################################################################################
# Install Sublime Text
#
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get install apt-transport-https

echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt-get update
sudo apt-get install sublime-text

########################################################################################################################
# Install Matlab
# got to mathworks.com and log in. Go to license / download and install / select version

# after installation
sudo apt-get install matlab-support

########################################################################################################################
# Install psychtoolbox
#
wget -O- http://neuro.debian.net/lists/bionic.us-nh.full | sudo tee /etc/apt/sources.list.d/neurodebian.sources.list
sudo apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9

sudo apt-get update

sudo apt-get install psychtoolbox

########################################################################################################################
# Install SR Research for Eyelink
# https://www.sr-support.com/forum/downloads/eyelink-display-software/46-eyelink-developers-kit-for-linux-linux-display-software
wget -O - "http://download.sr-support.com/software/dists/SRResearch/SRResearch_key" | sudo apt-key add -

sudo add-apt-repository "deb http://download.sr-support.com/software SRResearch main"
sudo apt-get update

sudo apt-get install eyelink-display-software

########################################################################################################################
# Install Vpixx Utilities for Propixx
# you might have to log in at vpixx.com first
cd ~/Downloads/
wget http://www.vpixx.com/developer/VPixx_Software_Tools.zip
unzip VPixx_Software_Tools.zip
cd VPixx_Software_Tools/vputil/bin/linux/

sudo cp libi1d3.so.0 /usr/lib/libi1d3.so.0
sudo cp libi1Pro.so.0 /usr/lib/libi1Pro.so.0
sudo chmod +x vputil
sudo ./vputil

########################################################################################################################
# Install rs 232 USB to serial driver for new era syringe
#
# Follow instructions at https://www.usb-drivers.org/usb-serial-port-adapter-rs-232-in-ubuntu-linux.html