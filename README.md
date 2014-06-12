Openstack Installer
================

Project for building out OpenStack using the data model.

## Spinning up VMs with Vagrant

This project historically supported spinning up VMs to test OpenStack with Vagrant.

This approach is recommended for development environment or for users who want
to get up and going in the simplest way possible.

### requirements

This setup requires that a few additional dependencies are installed:

* virtualbox
* vagrant > 1.5

### Instructions

Developers should be started by installing the following simple utility:

Currently, you have to install it from source.

    mkdir vendor
    export GEM_HOME=`pwd`/vendor
    gem install thor --no-ri --no-rdoc
    git clone git://github.com/bodepd/librarian-puppet-simple vendor/librarian-puppet-simple
    export PATH=`pwd`/vendor/librarian-puppet-simple/bin/:$PATH

Once this library is installed, you can run the following command from this project's root directory. This will use the Puppetfile to clone the openstack modules in the local modules directory.

    librarian-puppet install --verbose

### Spinning up virtual machines with vagrant

Now that you have set up the puppet content, the next step is to build
out your multi-node environment using vagrant.

First, deploy the apt-ng-cacher instance:

    vagrant up cache

Next, bring up the build server:

    vagrant up build

Now, bring up the blank boxes so that they can PXE boot against the master

    vagrant up control_basevm

    vagrant up compute_basevm

Now, you have created a fully functional openstack environment, now have a look at some services:

  * service dashboard: http://192.168.242.100/
  * horizon:           http://192.168.242.10/ (username: admin, password: Cisco123)

Log into your controller:

    vagrant ssh control_basevm

Run a simple script that validates that everything is working as expected.

    bash /tmp/test_nova.sh


## Spinning up virtual machines with Openstack

This is no longer supported. Support needs to be reintroduced.

The data model in this repository can be consumed by the scenariobuilder tool. To install it, use pip:

    pip install scenariobuilder

The 'sb' tool can then be used with Openstack credentials to instantiate the data model in VMs on an Openstack cloud. For more information see: https://github.com/CiscoSystems/scenariobuilder
