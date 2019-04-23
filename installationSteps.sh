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

########################################################################################################################
# Install Gstreamer
#

########################################################################################################################
# Install SR Research for Eyelink
#

########################################################################################################################
# Install Vpixx Utilities for Propixx
#


########################################################################################################################
# Install rs 232 USB to serial driver for new era syringe
#
# Follow instructions at https://www.usb-drivers.org/usb-serial-port-adapter-rs-232-in-ubuntu-linux.html