#!/bin/bash

set -e

sleep 30

# Set up the Vagrant insecure key, which will get replaced the first time
# Vagrant brings up the box.
sudo mkdir ~vagrant/.ssh
sudo chmod 700 ~vagrant/.ssh
sudo wget --no-check-certificate 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' -O ~vagrant/.ssh/authorized_keys
sudo chmod 600 ~vagrant/.ssh/authorized_keys
sudo chown -R vagrant:vagrant ~vagrant/.ssh

sudo apt-get update -y -qq

# The following are needed for Virtualbox Guest Additions to work.
sudo apt-get install -y -q virtualbox-guest-utils virtualbox-guest-dkms
sudo apt-get install -y -q linux-headers-$(uname -r) build-essential dkms

# I used to install the jdk, but trying the jre only again.
sudo apt-get -y install openjdk-8-jre-headless

echo Downloading and installing Apache software
wget -nv -N "http://archive.apache.org/dist/lucene/solr/4.10.3/solr-4.10.3.tgz"
tar -xf "solr-4.10.3.tgz"
wget -nv -N "http://archive.apache.org/dist/nutch/1.9/apache-nutch-1.9-bin.tar.gz"
tar -xf "apache-nutch-1.9-bin.tar.gz"

solr_distribution_dir="/home/vagrant/solr-4.10.3"
nutch_distribution_dir="/home/vagrant/apache-nutch-1.9"

solr_home_dir="/vagrant/solr"
solr_command=File.join solr_distribution_dir, "bin/solr"

nutch_home_dir="/vagrant/nutch"
nutch_conf_dir=$nutch_home_dir/conf
nutch_urls_dir=$nutch_home_dir/urls

# crawl-dir has to be on the local drive of the Vagrant machine. I spend
# weeks chasing a problems that was because it was on the shared device
# (/vagrant/...)
crawl_dir="/home/vagrant/crawl-dir"

nutch_bin=$nutch_home_dir/bin
crawl_command=$nutch_bin/crawl
nutch_command=$nutch_bin/nutch

sudo apt-get dist-upgrade -y -qq
sudo apt-get autoremove -y -qq
