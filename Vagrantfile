# -*- mode: ruby -*-
# vi: set ft=ruby :

#-------------------------EDIT BELOW HERE---------------------------------------
# CONFIGURE BOX VARIABLES

  WP_HOSTNAME = "project-dev-box"
  PRIVATE_IP = "192.168.31.15"
  BOX_NAME = "project-dev-box"
  BOX_MEMORY = "512"
  PROVISION = "provision.sh"

  DIGITALOCEAN_TOKEN = "DIGITAL_OCEAN_TOKEN_HERE"
  DIGITALOCEAN_REGION = "nyc2"
  DIGITALOCEAN_SIZE = "512mb"

#-------------------------DO NOT EDIT BELOW HERE--------------------------------
#-------------------------UNLESS YOU KNOW WHAT YOU'RE DOING---------------------

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, :path => PROVISION, run: "always"
  config.vm.hostname = WP_HOSTNAME

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  config.vm.network "forwarded_port", guest: 80, host: 80
  config.vm.network "forwarded_port", guest: 3306,  host: 3306

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: PRIVATE_IP

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./config/", "/project/config", create: true
  config.vm.synced_folder "./database/", "/project/database", create: true
  config.vm.synced_folder "./www/", "/project/www", create: true, group: "www-data", owner: "www-data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|
    # Set the name of the VM
    vb.name = BOX_NAME

    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", BOX_MEMORY]

    # allow symlinks to be created in the shared folder (ex: node_modules):
    vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/project", "1"]
  end
  config.vm.provider :digital_ocean do |provider, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

    provider.token = DIGITALOCEAN_TOKEN
    provider.image = 'Ubuntu 14.04 x64'
    provider.region = DIGITALOCEAN_REGION
    provider.size = DIGITALOCEAN_SIZE
    provider.private_networking = 'false'
  end
end
