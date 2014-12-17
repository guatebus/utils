# Vagrant installation

Start by adding the Vagrantfile and provision.sh files to your project. The
Vagrantfile is usually added at the project's root (make sure to update the
location to provision.sh relative to the Vagrantfile).

The Vagrantfile and provision.sh script are setup for a Symfony 2.4 project
but can be changed to suit your needs.

## Install the project

Your project and its dependencies will be self-contained in a virtual machine
managed by Vagrant. At the end of this section, you will have the development
environment set up in a virtual machine and you will be able to access the
website from your browser.

In order to install the project, you'll first need to follow these steps:

- Install the latest version of [Vagrant](http://www.vagrantup.com/) by installing
  [the correct package for your operating system](http://www.vagrantup.com/downloads.html)
- Install the latest version of [VirtualBox](https://www.virtualbox.org/) by installing [the
  correct package for your operating system](https://www.virtualbox.org/wiki/Downloads)

Once these two packages are installed:

Clone the repository in a directory and open a terminal inside this directory.

    vagrant plugin install vagrant-hostmanager

After that, you must install the dependencies of the project. If you use composer:

    composer.phar install

The installation phase on your machine is now done and you can launch the VM
with

    vagrant up

## Connect to the VM

Every command to setup the development environment must be run in the VM. To do so,
we can ssh into the VM. Open a terminal where this repository has been cloned and
type:

    vagrant ssh

You should now be connected to the VM.

Once in the VM, you will be able to reach the project by typing:

    cd your_project

## parameters.yml

* Symfony-only: Update the project's parameters.yml file, use the .dist file as a key
({projectRoot}/app/config/parameters.yml.dist)

## Project Data

The project needs data so that it can be tested on. You can load the project's fixtures
or restore a dump of the actual application's migrated db. If you will load fixtures using
the Symfony console, the commands need to be executed from "~/your_project" inside the VM

### Using Migrated (real) data [preferred]

While ssh'd into the vagrant box, and at the  "~/your_project" location, run the following:

    app/console doctrine:database:create
    app/console doctrine:schema:create
    mysql -uroot dbNameInParametersYmlFile < your_db_dump.sql

### Using Fixtures

While ssh'd into the vagrant box, and at the  "~/your_project" location, run the following:

    app/console doctrine:database:create
    app/console doctrine:schema:create
    app/console doctrine:fixtures:load --append

You can now open a web browser to `http://www.your_project.dev/app_dev.php`