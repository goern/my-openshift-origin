# -*- mode: ruby -*-
# vi: set ft=ruby :

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

  config.vm.define "nfs-1" do |nfs1|
    nfs1.vm.box = "rhel-7.1"
    nfs1.vm.box_check_update = true
    nfs1.vm.hostname = "nfs-1.goern.example.com"

    # a la https://stackoverflow.com/questions/33117939/vagrant-do-not-map-hostname-to-loopback-address-in-etc-hosts
    nfs1.vm.provision "shell", inline: "hostname --fqdn > /etc/hostname && hostname -F /etc/hostname"
    nfs1.vm.provision "shell", inline: "sed -ri 's/127\.0\.0\.1\s.*/127.0.0.1 localhost localhost.localdomain/' /etc/hosts"
    nfs1.vm.provision "shell", inline: "cp -f /usr/share/zoneinfo/UTC /etc/localtime"

    nfs1.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

    nfs1.vm.provision "shell", path: "common-configuration.sh"
    nfs1.vm.provision "shell", path: "configure-nfs-server.sh"

    nfs1.vm.provision "shell", inline: "yum update -y && yum clean all"
  end

    config.vm.define "master-1" do |this_host|
      this_host.vm.box = "rhel-7.1"
      this_host.vm.box_check_update = true
      this_host.vm.hostname = "master-1.goern.example.com"

      this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      this_host.vm.provision "shell", path: "common-configuration.sh"

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

    end

  3.times do |n|
    config.vm.define "node-#{n}" do |this_host|
      this_host.vm.box = "rhel-7.1"
      this_host.vm.box_check_update = false
      this_host.vm.hostname = "node-#{n}.goern.example.com"

      this_host.vm.provision "shell", path: "common-configuration.sh"

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
