# Developing with a docker container

## Motivations for using Docker (why?)
* Setup development environment in an easy and repetitive way.
* Define required native dependencies per project environment.
* To isolate the project's stack.
* Define sensible defaults and other team/project standards.

To run a docker container within MacOSx here are options to mention a few:
  * [Boot2Docker](http://boot2docker.io/)
  * [Vagrant](http://www.vmware.com/uk/products/fusion)
  * [VMWare](http://www.vmware.com/uk/products/fusion)

The example showed here will is built on Vagrant.

## Installing and running

NB: this assumes that your smart-answers and govuk-content-schemas projects reside inside the same parent directory.

Create a parent folder here I call mine gds and a subfolder called vagrant

```bash
mkdir -p gds/vagrant
```

Create a Vagranfile inside the vagrant folder
```bash
touch gds/vagrant/Vagrantfile
```

Copy the lines below to the Vagrantfile

```ruby
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "trusty"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  [5000, 3000, 3010].each do |p|
    config.vm.network :forwarded_port, guest: p, host: p
  end
  config.vm.network :private_network, ip: "192.168.51.10"

  config.vm.synced_folder "../../gds/", "/gds", nfs: true # adjust this acc
  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.name = "gds-vm"
  end

  # Bootstrap to Docker
  config.vm.provision :shell, path: "scripts/bootstrap", :privileged => true
end

```

Create the bootstrap file insdie a scripts folder

```bash
mkdir -p gds/vagrant/scripts
touch gds/vagrant/scripts/bootstrap

```
Copy the lines below to the gds/vagrant/scripts/bootstrap file

```bash
#!/usr/bin/env bash
echo 'vagrant  ALL= (ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

# update ubuntu source list and package list
apt-get update -y

# most essential tools
apt-get -y install curl wget
apt-get -y install git-core
apt-get -y install mercurial
apt-get -y install build-essential checkinstall

sudo apt-get -y install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
sudo add-apt-repository 'deb http://mirrors.coreix.net/mariadb/repo/10.0/ubuntu trusty main'

sudo apt-get -y update

apt-get -y install vim
apt-get -y install tmux

# Set timezone
echo "Europe/London" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

cd /home/vagrant/

# apt-get update -y
apt-get install htop -y
apt-get install linux-image-extra-`uname -r` -y

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9

echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install lxc-docker -y

sudo gpasswd -a vagrant docker
sudo service docker restart

```

Create your vagrant box with the following commands:

```bash
cd gds/vagrant
vagrant up
```

After this is done, ssh into the vagrant box

```bash
vagrant ssh
```

Build the smart-answers docker container.

```bash
docker build --tag=smart-answers /gds/smart-answers
```

Next run your docker container:

```bash
 docker run --name=smart-answers --detach=true --volume=/gds:/gds --publish=3010:3010 smart-answers
```

This should listed in the list of running containers as smart-answers.

```bash
docker ps
```

To start and/or stop the smart-answers container:

```bash
docker stop smart-answers
docker start smart-answers
```

To view and/or follow the container's logs:

```bash
docker logs -f smart-answers
```
To run tests:

```bash
 docker run --tty=true --interactive=true --detach=false --rm=true --volume=/gds:/gds smart-answers "cd /gds/smart-answers; bundle exec rake test"
```

For more on docker see the [docker documentation](https://docs.docker.com/)
