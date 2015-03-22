# solr-nutch-vagrant

This is a Vagrantfile to create a [Vagrant](https://www.vagrantup.com/) virtual machine running the [Nutch](http://nutch.apache.org/) web crawler, and storing the results of the crawl in the [Solr](http://lucene.apache.org/solr/) search engine. It's meant for web site developers who need to develop and test search functionality on their web site.

# Quick start

## VirtualBox and Vagrant
These steps are applicable for Ubuntu, Mint, Debian, etc.

  sudo apt-get install virtualbox-dkms virtualbox
  wget "https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb"
  sudo dpkg -i vagrant_1.7.2_x86_64.deb

You may want to try the latest version of Vagrant, rather than the version specified above.

## The Vagrant Machine

  git clone https://github.com/lcreid/solr-nutch-vagrant.git
  cd solr-nutch-vagrant
  vagrant up

At this point, you can test the Solr is running by browsing to `localhost:8983`. Through the magic of Vagrant, your requests will actually be sent to the Vagrant box's port 8983, which is the default Solr port for queries. If you try a search, you won't get any documents yet. You have to crawl the web site first.

## Configuring the URL to Search
You can ignore this section if the web site you want to search is on the host machine's port 3000 (e.g. being served by Mongrel, like Rails or Nanoc).

TODO: Finish this.

## Running a Crawl
After installing, and periodically thereafter, you need to crawl the site you're testing. On the host machine, type:

  vagrant ssh -c "./crawl"

Or log into the guest and do it there:

  vagrant ssh
  ./crawl

Now browse to `localhost:8983` and do a search to see if you get any documents.

# Support

You can report problems or contribute to this project by submitting an issue to the [Github issue tracker](https://github.com/lcreid/solr-nutch-vagrant/issues). I'm happy to entertain pull requests, but it's best to submit an issue first, so we can discuss before you run off and do a lot of work.

This machine is built on Ubuntu Server 14.04 with Solr 5.0.0 and Nutch 1.9.
