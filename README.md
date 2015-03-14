# solr-nutch-vagrant

This is a Vagrantfile to create a [Vagrant](https://www.vagrantup.com/) virtual machine running the [Nutch](http://nutch.apache.org/) web crawler, and storing the results of the crawl in the [Solr](http://lucene.apache.org/solr/) search engine. It's meant for web site developers who need to develop and test search functionality on their web site.

The goal is to upload this machine to [Hashicorp's Atlas of Vagrant boxes](https://atlas.hashicorp.com/boxes/search), but that hasn't happened yet. It's still in development.

At a high level, here's how to use this vagrant VM:

1. Initialize and run the virtual machine
2. Configure Nutch to crawl your web site (typically the development version running on the machine that's running the vagrant box
3. Start the Nutch crawl
4. Test your web site's search functionality by pointing at `localhost:8983`. Through the magic of Vagrant, your requests will actually be sent to the Vagrant box's port 8983, which is the default Solr port for queries.

You can report problems or contribute to this project by submitting an issue to the [Github issue tracker](https://github.com/lcreid/solr-nutch-vagrant/issues). I'm happy to entertain pull requests, but it's best to submit an issue first, so we can discuss before you run off and do a lot of work.

This machine is built on Ubuntu Server 14.04 with Solr 5.0.0 and Nutch 1.9.
