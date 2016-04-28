# -*- mode: ruby -*-
# vi: set ft=ruby :

DEPLOY_IDM=false
OPENSHIFT_MASTERS=1
OPENSHIFT_NODES=2
OPENSHIFT_DOMAINNAME='goern.example.com'

Vagrant.configure(2) do |config|
  config.ssh.insert_key = false

  # check if the hostmanager plugin is installed
  unless Vagrant.has_plugin?("vagrant-hostmanager")
    raise 'vagrant-hostmanager is not installed! see https://github.com/smdahlen/vagrant-hostmanager'
  end

  # and configure the hostmanager plugin
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.include_offline = true

  # check if the vagrant-registration plugin is installed
  unless Vagrant.has_plugin?("vagrant-registration")
    raise 'vagrant-registration is not installed! see https://github.com/projectatomic/adb-vagrant-registration'
  end
  config.registration.unregister_on_halt = false
  config.registration.username = ENV['VAGRANT_REGISTRATION_USERNAME']
  config.registration.password = ENV['VAGRANT_REGISTRATION_PASSWORD']

  # set some sane defaults for all VMs
  config.vm.provider :libvirt do |domain|
    domain.memory = 1024
    domain.cpus = 1
  end

  config.vm.define "nfs-1" do |this_host|
    this_host.vm.box = "rhel-7.1"
    this_host.vm.box_check_update = true
    this_host.vm.hostname = "nfs-1.#{OPENSHIFT_DOMAINNAME}"

    this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

    this_host.vm.provision "shell", path: "provision-scripts/common.sh"
    this_host.vm.provision "shell", path: "provision-scripts/nfs-server.sh"
  end

  if OPENSHIFT_MASTERS > 1
    config.vm.define "lb-1" do |lb1|
      lb1.vm.box = "rhel-7.1"
      lb1.vm.box_check_update = true
      lb1.vm.hostname = "master.#{OPENSHIFT_DOMAINNAME}"

      lb1.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      lb1.vm.provider :libvirt do |domain|
        domain.memory = 512
        domain.cpus = 1
      end

      lb1.vm.provision "shell", path: "common-configuration.sh"

      lb1.vm.provision "shell", inline: "yum update -y && yum clean all"

      lb1.vm.network "forwarded_port", guest: 8443, host: 8443
    end
  end

  OPENSHIFT_MASTERS.times do |n|
    config.vm.define "master-#{n}" do |this_host|
      this_host.vm.box = "rhel-7.1"
      this_host.vm.box_check_update = true
      this_host.vm.hostname = "master-#{n}.#{OPENSHIFT_DOMAINNAME}"

      this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      this_host.vm.provision "shell", path: "provision-scripts/common.sh"

      this_host.vm.provider "libvirt" do |libvirt|
        libvirt.driver = "kvm"
        libvirt.memory = 1024
        libvirt.cpus = 2
        libvirt.storage :file, :size => '8G'
      end

      this_host.vm.provision "shell" do |s|
        s.inline = "echo 'DEVS=\"/dev/vdb\"' > /etc/sysconfig/docker-storage-setup"
      end

      this_host.vm.provision "shell", inline: "yum install -y docker"
  #      this_host.vm.provision "shell", inline: "docker-storage-setup"
      this_host.vm.provision "shell", inline: "yum update -y && yum clean all"

      this_host.vm.provision "shell", inline: "mkdir -p /etc/origin/master && echo 'admin:$apr1$NRX9JJxb$kqO2v6n5fLCN2M8cZ0vu10' >/etc/origin/master/htpasswd"

      if OPENSHIFT_MASTERS == 1
        this_host.vm.network "forwarded_port", guest: 8443, host_ip: '0.0.0.0', host: 8443
      end
    end
  end

  OPENSHIFT_NODES.times do |n|
    config.vm.define "node-#{n}" do |this_host|
      this_host.vm.box = "rhel-7.1"
      this_host.vm.box_check_update = false
      this_host.vm.hostname = "node-#{n}.#{OPENSHIFT_DOMAINNAME}"

      this_host.vm.provision "shell", path: "provision-scripts/common.sh"

      this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      this_host.vm.provider "libvirt" do |libvirt|
        libvirt.driver = "kvm"
        libvirt.memory = 2048
        libvirt.cpus = 2
        libvirt.storage :file, :size => '8G'
      end

      this_host.vm.provision "shell", inline: "echo 'DEVS=\"/dev/vdb\"' > /etc/sysconfig/docker-storage-setup"
      this_host.vm.provision "shell", inline: "yum install -y docker"
#      this_host.vm.provision "shell", inline: "docker-storage-setup"
      this_host.vm.provision "shell", inline: "yum update -y && yum clean all"
    end
  end

end
