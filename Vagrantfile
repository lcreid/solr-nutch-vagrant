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
    inline: "sudo apt-get -y install openjdk-7-jdk"

  solr_dir = "solr-5.0.0"

  config.vm.provision "apache-installs", type: "shell", privileged: false, inline: <<-SHELL
    echo Downloading and installing Apache software
    wget -nv -N "http://apache.mirror.vexxhost.com/lucene/solr/5.0.0/solr-5.0.0.tgz"
    tar -xf "solr-5.0.0.tgz"
    wget -nv -N "http://apache.parentingamerica.com/nutch/1.9/apache-nutch-1.9-bin.tar.gz"
    tar -xf "apache-nutch-1.9-bin.tar.gz"
    chmod a+x #{File.join solr_dir, "bin/solr"}
  SHELL

  solr_home_dir = "/vagrant/solr"
  core_dir = "/vagrant/solr/cark"

  config.vm.provision "init-solr", type: "shell", privileged: false, inline: <<-SHELL
    # ls -l #{File.join(solr_dir, "solr/bin/solr")}
    echo Running solr init in $PWD. This deletes your existing core!
    cd #{solr_dir}
    bin/solr stop -all
    rm -rf #{solr_home_dir}
    mkdir -p #{solr_home_dir}
    cp -a "server/solr/solr.xml" #{solr_home_dir}
    # echo Populating #{core_dir}
    # mkdir -p #{core_dir} #{File.join core_dir, "conf"}
    # cp -ar "server/solr/configsets/basic_configs/conf" #{core_dir}
    # echo "name=cark" >#{File.join core_dir, "core.properties"}
    # You have to start Solr before creating the core.
    bin/solr start -s #{solr_home_dir}
    bin/solr create -c cark
    # bin/solr start -e cloud -noprompt
    # bin/solr stop -all
  SHELL

=begin
  This didn't work.

  # Config port forwarding so localhost:3000 on the Vagrant guest goes to
  # :3000 on the Vagrant host (presumably the developer's workstation)
  config.vm.provision "forward-port", type: "shell", inline: <<-SHELL
    # Get the host IP by looking up the default gateway.
    HOST_IP=`ip route | awk '/default/ { print $3 }'`
    # TODO: No to the above. I just port forward localhost:3000 to default gateway:3000
    # From: http://www.linuxquestions.org/questions/linux-newbie-8/how-to-port-forward-539814/
    # This is probably better: http://www.fclose.com/816/port-forwarding-using-iptables/
    echo "1" >/proc/sys/net/ipv4/ip_forward
    # TODO: Delete old rules from previous runs.
    iptables -t nat -F
    iptables -F
    iptables -A OUTPUT -t nat -i eth0 -p tcp --dport 3000 -j DNAT --to $HOST_IP:3000
    # Shouldn't need the following, because the default policy is ACCEPT
    # iptables -A FORWARD -p tcp -d $HOST_IP --dport 3000 -j ACCEPT
    # TODO: Make these rules persistent.
  SHELL
=end

  solr_config_dir = File.join core_dir, "conf"
  solr_schema = File.join solr_config_dir, "schema.xml"
  nutch_dir = "apache-nutch-1.9"
  nutch_bin_dir = File.join nutch_dir, "bin"
  nutch_config_dir = File.join nutch_dir, "conf"
  nutch_home_dir = "/vagrant/nutch"
  nutch_conf_dir = File.join nutch_home_dir, "conf"
  nutch_urls_dir = File.join nutch_home_dir, "urls"
  nutch_seed_file = File.join nutch_urls_dir, "seed.txt"
  nutch_url_filter = File.join nutch_conf_dir, "regex-urlfilter.txt"
  nutch_site_file = File.join nutch_conf_dir, 'nutch-site.xml'
  crawl_dir = File.join nutch_home_dir, "crawl-dir"

  config.vm.provision "init-nutch", type: "shell", privileged: false, inline: <<-SHELL
    echo "Setting up Nutch conf directory."
    rm -rf #{nutch_conf_dir}
    rm -rf #{crawl_dir}
    mkdir -p #{nutch_conf_dir}
    cp -a #{nutch_config_dir}/* #{nutch_conf_dir}
    echo "Set the name of your spider to Jade Spider."
    sed --in-place -e '/^<configuration>/a<property><name>http.agent.name</name><value>Jade Spider</value></property>' #{nutch_site_file}
    echo "You can change the name of your spider by editing #{nutch_site_file}."
    mkdir -p #{nutch_urls_dir}
    echo "Set #{nutch_seed_file} to crawl http://#{Socket.gethostname}:3000."
    echo "http://#{Socket.gethostname}:3000" >#{nutch_seed_file}
    echo "Edit #{nutch_seed_file} to specify which URLs to crawl."
    echo "Set #{nutch_url_filter} to crawl only within the above domain."
    echo "Recommended, so you don't crawl half the Internet."
    sed --in-place -e '$s/^/#/' -e '$a+^http://([a-zA-Z0-9]*\\\\.)*#{Socket.gethostname}' #{nutch_url_filter}
    echo "Setting up the Nutch-Solr integration"
    cp -a #{File.join nutch_conf_dir, "schema.xml"} #{solr_schema}
    sed --in-place -e '53s/</<!-- &/' \
      -e '54s/$/ -->/' \
      -e '70a<field name="_version_" type="long" indexed="true" stored="true"/>' \
      -e '80s/false/true/' #{solr_schema}
  SHELL

  crawl_command_content = <<-EOF
    #!/bin/bash

    export NUTCH_CONF_DIR=#{nutch_conf_dir}
    export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
    cd; cd #{nutch_dir}
    mkdir -p #{crawl_dir}
    bin/crawl #{nutch_urls_dir} #{crawl_dir} http://localhost:8983/solr/ 2
  EOF

  config.vm.provision "make-crawl-command", type: "shell", privileged: false, inline: <<-SHELL
    mkdir bin
    cd bin
    echo '#{crawl_command_content}' >crawl
    chmod a+x crawl
  SHELL

=begin
The line that says where the segment is will be here in the crawl output:
/^ParseSegment: segment: /
bin/nutch solrindex http://127.0.0.1:8983/solr/ crawl/crawldb -linkdb crawl/linkdb crawl/segments/
=end

    # echo "<property>\n  <name>http.agent.name</name>\n  <value>Vagrant Spider</value>\n<property>" >> #{File.join nutch_conf_dir, "nutch-default.xml"}

  # nutch_schema = File.join nutch_dir, "schema.xml"
  # config.vm.provision "config-solr-for-nutch", type: "shell", privileged: false, inline: <<-SHELL
  #   cp #{nutch_schema} #{core_dir}
  # SHELL

  # config.vm.provision "patch", type: "shell", privileged: false, inline: <<-SHELL
  #   # This is the patch for solr 4. Have to check if the config for 5 is different.
  #
  #   patch #{solr_schema} <<-EOF
  #     --- /home/reid/apache-nutch-1.9/conf/schema.xml	2014-08-12 22:12:21.000000000 -0700
  #     +++ schema.xml	2015-02-23 16:28:19.611069000 -0800
  #     @@ -50,8 +50,8 @@
  #                          catenateWords="1" catenateNumbers="1" catenateAll="0"
  #                          splitOnCaseChange="1"/>
  #                      <filter class="solr.LowerCaseFilterFactory"/>
  #     -                <filter class="solr.EnglishPorterFilterFactory"
  #     -                    protected="protwords.txt"/>
  #     +                <!-- <filter class="solr.EnglishPorterFilterFactory"
  #     +                    protected="protwords.txt"/> -->
  #                      <filter class="solr.RemoveDuplicatesTokenFilterFactory"/>
  #                  </analyzer>
  #              </fieldType>
  #     @@ -68,6 +68,7 @@
  #          <fields>
  #              <field name="id" type="string" stored="true" indexed="true"
  #                  required="true"/>
  #     +        <field name="_version_" type="long" indexed="true" stored="true"/>
  #
  #              <!-- core fields -->
  #              <field name="segment" type="string" stored="true" indexed="false"/>
  #   EOF
  # SHELL

  # config.vm.provision "start-solr", type: "shell", privileged: false, inline: <<-SHELL
  #   cd #{solr_dir}
  #   echo Starting solr for good
  #   bin/solr start -s /vagrant/solr -noprompt
  #   # bin/solr start -e cloud -noprompt
  # SHELL

  # TODO: Make the following clean up after itself if run more than once.
  config.vm.provision "set-up-profile", type: "shell", privileged: false, inline: <<-SHELL
    sed --in-place \
      -e '/export JAVA_HOME/d' \
      -e '/export NUTCH_CONF_DIR/d' \
      -e '/export CRAWL_DB/d' \
      -e '/export SOLR_HOME_DIR/d' \
      .profile
    echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")' >>.profile
    echo 'export NUTCH_CONF_DIR=#{nutch_conf_dir}' >>.profile
    echo 'export CRAWL_DB=#{crawl_dir}/crawldb' >>.profile
    echo 'export CRAWL_DB=#{crawl_dir}/crawldb' >>.profile
    echo 'export SOLR_HOME_DIR=#{solr_home_dir}' >>.profile
  SHELL
end
