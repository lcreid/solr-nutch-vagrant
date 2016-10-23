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

wget -nv -N "http://archive.apache.org/dist/lucene/solr/4.10.3/solr-4.10.3.tgz"
tar -xf "solr-4.10.3.tgz"
wget -nv -N "http://archive.apache.org/dist/nutch/1.11/apache-nutch-1.11-bin.tar.gz"
tar -xf "apache-nutch-1.11-bin.tar.gz"

solr_distribution_dir="/home/vagrant/solr-4.10.3"
nutch_distribution_dir="/home/vagrant/apache-nutch-1.11"

solr_home_dir="/vagrant/solr"
solr_command="$solr_distribution_dir/bin/solr"

nutch_home_dir="/vagrant/nutch"
nutch_conf_dir=$nutch_home_dir/conf
nutch_urls_dir=$nutch_home_dir/urls

# crawl-dir has to be on the local drive of the Vagrant machine. I spent
# weeks chasing a problem that was because it was on the shared device
# (/vagrant/...)
crawl_dir="/home/vagrant/crawl-dir"

nutch_bin=$nutch_home_dir/bin
crawl_command=$nutch_bin/crawl
nutch_command=$nutch_bin/nutch

VAGRANT_BIN=~vagrant/bin
mkdir -p $VAGRANT_BIN
VAGRANT_CRAWL_COMMAND="$VAGRANT_BIN/crawl"
cat >"$VAGRANT_CRAWL_COMMAND" <<-EOF
  #!/bin/bash

  mkdir -p "$crawl_dir"
  "$crawl_command" "$nutch_urls_dir" "$crawl_dir" http://localhost:8983/solr/cark 2
EOF
chmod a+x "$VAGRANT_CRAWL_COMMAND"

cat >>~vagrant/.profile <<-EOF
  export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
  export NUTCH_CONF_DIR=/vagrant/nutch/conf
  export URLS_DIR=/vagrant/nutch/urls
  export CRAWL_DB=/home/vagrant/crawl-dir/crawldb
  export LINK_DB=/home/vagrant/crawl-dir/linkdb
  export SEGMENTS_DIR=/home/vagrant/crawl-dir/segments
  export SOLR_HOME_DIR=/vagrant/solr
  alias solr="/home/vagrant/solr-4.10.3/bin/solr"
  alias nutch="/vagrant/nutch/bin/nutch"
EOF

# Set up upstart so Solr is running whenever we boot
sudo  bash -c 'cat >/etc/systemd/system/solr.service' <<-EOF
[Unit]
Description=Run Solr on Vagrant box.

[Service]
User=vagrant
Group=vagrant
ExecStart=/home/vagrant/solr-4.10.3/bin/solr start -f -s /vagrant/solr
ExecStop=/home/vagrant/solr-4.10.3/bin/solr stop -p 8983
Restart=on-failure
RestartSec=20

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable solr.service

sudo apt-get dist-upgrade -y -qq
sudo apt-get autoremove -y -qq
