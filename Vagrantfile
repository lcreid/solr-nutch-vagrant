# -*- mode: ruby -*-
# vi: set ft=ruby :

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
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

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

  solr_url = "http://apache.mirror.vexxhost.com/lucene/solr/4.10.3/solr-4.10.3.tgz"
  nutch_url = "http://apache.parentingamerica.com/nutch/1.9/apache-nutch-1.9-bin.tar.gz"
  solr_file = File.basename solr_url
  nutch_file = File.basename nutch_url

  config.vm.provision "java-installs",
    type: "shell",
    inline: "sudo apt-get -y install openjdk-7-jdk"

  config.vm.provision "apache-installs", type: "shell", privileged: false, inline: <<-SHELL
    echo Downloading and installing Apache software
    wget -nv -N "http://apache.mirror.vexxhost.com/lucene/solr/4.10.3/solr-4.10.3.tgz"
    tar -xf "solr-4.10.3.tgz"
    wget -nv -N "http://apache.parentingamerica.com/nutch/1.9/apache-nutch-1.9-bin.tar.gz"
    tar -xf "apache-nutch-1.9-bin.tar.gz"
  SHELL

  solr_dir = "solr-4.10.3"

  config.vm.provision "init-solr", type: "shell", privileged: false, inline: <<-SHELL
    # ls -l #{File.join(solr_dir, "solr/bin/solr")}
    cd #{solr_dir}
    echo Running solr init in $PWD
    chmod a+x bin/solr
    bin/solr start -e cloud -noprompt
    bin/solr stop -all
  SHELL

  solr_config_dir = File.join solr_dir, "/example/solr/collection1/conf"
  solr_schema = File.join solr_config_dir, "schema.xml"
  nutch_dir = "apache-nutch-1.9"
  nutch_config_dir = File.join nutch_dir, "/conf"
  nutch_schema = File.join nutch_dir, "schema.xml"
  config.vm.provision "config-solr-for-nutch", type: "shell", privileged: false, inline: <<-SHELL
    cp #{solr_schema} #{solr_schema}.original
    cp #{nutch_schema} #{solr_schema}
  SHELL

  config.vm.provision "patch", type: "shell", privileged: false, inline: <<-SHELL
    # This is the patch for solr 4. Have to check if the config for 5 is different.

    patch #{solr_schema} <<-EOF
      --- /home/reid/apache-nutch-1.9/conf/schema.xml	2014-08-12 22:12:21.000000000 -0700
      +++ schema.xml	2015-02-23 16:28:19.611069000 -0800
      @@ -50,8 +50,8 @@
                           catenateWords="1" catenateNumbers="1" catenateAll="0"
                           splitOnCaseChange="1"/>
                       <filter class="solr.LowerCaseFilterFactory"/>
      -                <filter class="solr.EnglishPorterFilterFactory"
      -                    protected="protwords.txt"/>
      +                <!-- <filter class="solr.EnglishPorterFilterFactory"
      +                    protected="protwords.txt"/> -->
                       <filter class="solr.RemoveDuplicatesTokenFilterFactory"/>
                   </analyzer>
               </fieldType>
      @@ -68,6 +68,7 @@
           <fields>
               <field name="id" type="string" stored="true" indexed="true"
                   required="true"/>
      +        <field name="_version_" type="long" indexed="true" stored="true"/>

               <!-- core fields -->
               <field name="segment" type="string" stored="true" indexed="false"/>
    EOF
  SHELL

  config.vm.provision "start-solr", type: "shell", privileged: false, inline: <<-SHELL
    cd #{solr_dir}
    echo Starting solr for good
    bin/solr start -e cloud -noprompt
  SHELL

end
