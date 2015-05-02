# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'socket'

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8983" will access port 8983 on the guest machine,
  # which is the Solr port.
  config.vm.network "forwarded_port", guest: 8983, host: 8983

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true

    # Solr won't start without at least a GB of RAM
    vb.memory = "1024"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  config.vm.provision "messages",
    type: "shell",
    privileged: false,
    inline: 'echo "For support, see: https://github.com/lcreid/solr-nutch-vagrant"'

  # solr_url = "http://apache.mirror.vexxhost.com/lucene/solr/5.0.0/solr-5.0.0.tgz"
  # nutch_url = "http://apache.parentingamerica.com/nutch/1.9/apache-nutch-1.9-bin.tar.gz"
  # solr_file = File.basename solr_url
  # nutch_file = File.basename nutch_url

  config.vm.provision "java-installs",
    type: "shell",
    inline: <<-SHELL
      sudo apt-get update
      sudo apt-get -y install openjdk-7-jdk
    SHELL

  solr_distribution_dir = "/home/vagrant/solr-4.10.3"
  nutch_distribution_dir = "/home/vagrant/apache-nutch-1.9"

  config.vm.provision "apache-installs", type: "shell", privileged: false, inline: <<-SHELL
    echo Downloading and installing Apache software
    wget -nv -N "http://apache.mirror.vexxhost.com/lucene/solr/4.10.3/solr-4.10.3.tgz"
    tar -xf "solr-4.10.3.tgz"
    wget -nv -N "http://apache.parentingamerica.com/nutch/1.9/apache-nutch-1.9-bin.tar.gz"
    tar -xf "apache-nutch-1.9-bin.tar.gz"
  SHELL

  solr_home_dir = "/vagrant/solr"
  solr_command = File.join solr_distribution_dir, "bin/solr"

  nutch_home_dir = "/vagrant/nutch"
  nutch_conf_dir = File.join nutch_home_dir, "conf"
  nutch_urls_dir = File.join nutch_home_dir, "urls"
  # crawl-dir has to be on the local drive of the Vagrant machine. I spend
  # weeks chasing a problems that was because it was on the shared device
  # (/vagrant/...)
  crawl_dir = "/home/vagrant/crawl-dir"

  nutch_bin = File.join nutch_home_dir, "bin"
  crawl_command = File.join nutch_bin, "crawl"
  nutch_command = File.join nutch_bin, "nutch"

  config.vm.provision "set-up-profile", type: "shell", privileged: false, inline: <<-SHELL
    echo Creating some useful aliases and environment variables.
    echo Check .profile to see them.
    sed --in-place \
      -e '/export JAVA_HOME/d' \
      -e '/export NUTCH_CONF_DIR/d' \
      -e '/export URLS_DIR/d' \
      -e '/export CRAWL_DB/d' \
      -e '/export LINK_DB/d' \
      -e '/export SEGMENTS/d' \
      -e '/export SOLR_HOME_DIR/d' \
      -e '/alias solr=/d' \
      -e '/alias nutch=/d' \
      .profile
    echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >>.profile
    echo 'export NUTCH_CONF_DIR=#{nutch_conf_dir}' >>.profile
    echo 'export URLS_DIR=#{nutch_urls_dir}' >>.profile
    echo 'export CRAWL_DB=#{crawl_dir}/crawldb' >>.profile
    echo 'export LINK_DB=#{crawl_dir}/linkdb' >>.profile
    echo 'export SEGMENTS_DIR=#{crawl_dir}/segments' >>.profile
    echo 'export SOLR_HOME_DIR=#{solr_home_dir}' >>.profile
    echo 'alias solr="#{solr_command}"' >>.profile
    echo 'alias nutch="#{nutch_command}"' >>.profile
  SHELL

  config.vm.provision "clone", type: "shell", privileged: false, inline: <<-SHELL
    # echo "Copying distribution to our SOLR_HOME_DIR #{solr_home_dir}"
    # [ -d #{solr_home_dir} ] && rm -rf #{solr_home_dir}
    # cp -ar #{solr_distribution_dir} #{solr_home_dir}
    # chmod a+x #{solr_command}
    echo "Copying distribution to our Nutch home #{nutch_home_dir}"
    [ -d #{nutch_home_dir} ] && rm -rf #{nutch_home_dir}
    cp -ar #{nutch_distribution_dir} #{nutch_home_dir}
  SHELL

  core_dir = File.join solr_home_dir, "cark"
  solr_config_dir = File.join core_dir, "conf"

  solr_schema = File.join solr_config_dir, "schema.xml"
  nutch_template_conf_dir = File.join nutch_distribution_dir, "conf"
  nutch_template_schema = File.join nutch_template_conf_dir, "schema.xml"

  start_solr = solr_command + " start -s " + solr_home_dir
  stop_solr = solr_command + " stop -all"

  config.vm.provision "init-solr", type: "shell", privileged: false, inline: <<-SHELL
    #{stop_solr}
    echo "Making core 'cark' at #{core_dir} (inside joke)."
    [ -d #{solr_home_dir} ] && rm -rf #{solr_home_dir}
    mkdir -p #{solr_home_dir}
    cp -a #{File.join solr_distribution_dir, "example/solr/solr.xml"} #{solr_home_dir}
    [ -d #{core_dir} ] && rm -rf #{core_dir}
    mkdir -p #{core_dir}
    cp -a #{File.join solr_distribution_dir, "example/solr/collection1/conf"} #{core_dir}
    echo "name=cark" >#{File.join core_dir, "core.properties"}

    echo "Setting up the Nutch-Solr integration in #{solr_schema}."
    sed -e '53s/</<!-- &/' \
      -e '54s/$/ -->/' \
      -e '70a<field name="_version_" type="long" indexed="true" stored="true"/>' \
      -e '80s/false/true/' #{nutch_template_schema} >#{solr_schema}
  SHELL

  config.vm.provision "init-startup", type: "shell", inline: "cp /vagrant/solr.conf /etc/init/"

  config.vm.provision "start-solr", type: "shell", inline: "start solr"

  nutch_seed_file = File.join nutch_urls_dir, "seed.txt"
  nutch_url_filter = File.join nutch_conf_dir, "regex-urlfilter.txt"
  nutch_site_file = File.join nutch_conf_dir, 'nutch-site.xml'
  nutch_template_urlfilter = File.join nutch_template_conf_dir, "regex-urlfilter.txt"
  nutch_template_site_file = File.join nutch_template_conf_dir, "nutch-site.xml"



  config.vm.provision "init-nutch", type: "shell", privileged: false, inline: <<-SHELL
    echo "Deleting Nutch crawl directory."
    rm -rf #{crawl_dir}
    echo "Set the name of your spider to Jade Spider."
    sed -e '7c  <property><name>http.agent.name</name><value>Jade Spider</value></property>' \
      -e '8i    <property><name>db.fetch.interval.default</name><value>5</value><description>Refetch after 5 seconds. Obviously not for production, but good for testing.</description></property>' \
      #{nutch_template_site_file} >#{nutch_site_file}
    echo "You can change the name of your spider by editing #{nutch_site_file}."
    mkdir -p #{nutch_urls_dir}
    echo "Set #{nutch_seed_file} to crawl http://#{Socket.gethostname}:3000/."
    echo "http://#{Socket.gethostname}:3000/" >#{nutch_seed_file}
    echo "Edit #{nutch_seed_file} to specify which URLs to crawl."
    echo "Set #{nutch_url_filter} to crawl only within the above domain."
    echo "Recommended, so you don't crawl half the Internet."
    sed -e '$s/^/#/' -e '$a+^http://([a-zA-Z0-9]*\\\\.)*#{Socket.gethostname}:3000/' #{nutch_template_urlfilter} >#{nutch_url_filter}
  SHELL

  crawl_command_content = <<-EOF
    #!/bin/bash

    mkdir -p #{crawl_dir}
    #{crawl_command} #{nutch_urls_dir} #{crawl_dir} http://localhost:8983/solr/cark 2
  EOF

  config.vm.provision "make-crawl-command", type: "shell", privileged: false, inline: <<-SHELL
    mkdir -p bin
    cd bin
    echo '#{crawl_command_content}' >crawl
    chmod a+x crawl
    echo "You can now log in to your VM with 'vagrant ssh',"
    echo "and crawl http://#{Socket.gethostname}:3000/ by running 'crawl'."
  SHELL
end
