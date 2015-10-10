#!/bin/bash

# Prep for boxing for Vagrant
# See: https://www.skoblenick.com/vagrant/creating-a-custom-box-from-scratch/
# and: https://blog.engineyard.com/2014/building-a-vagrant-box

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get clean
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
cat /dev/null > ~/.bash_history && history -c && exit
