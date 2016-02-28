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

  # set some sane defaults for all VMs
  config.vm.provider :libvirt do |domain|
    domain.memory = 1024
    domain.cpus = 1
  end

  config.vm.define "nfs-1" do |nfs1|
    nfs1.vm.box = "centos/7"
    nfs1.vm.box_check_update = true
    nfs1.vm.hostname = "nfs-1.goern.example.com"

    # a la https://stackoverflow.com/questions/33117939/vagrant-do-not-map-hostname-to-loopback-address-in-etc-hosts
    nfs1.vm.provision "shell", inline: "hostname --fqdn > /etc/hostname && hostname -F /etc/hostname"
    nfs1.vm.provision "shell", inline: "sed -ri 's/127\.0\.0\.1\s.*/127.0.0.1 localhost localhost.localdomain/' /etc/hosts"

    nfs1.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

    nfs1.vm.provision "shell", path: "configure-nfs-server.sh"

    nfs1.vm.provision "shell", inline: "yum update -y && yum clean all"
  end

  config.vm.define "master-1" do |master1|
    master1.vm.box = "centos/7"
    master1.vm.box_check_update = true
    master1.vm.hostname = "master-1.goern.example.com"

    master1.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

    # a la https://stackoverflow.com/questions/33117939/vagrant-do-not-map-hostname-to-loopback-address-in-etc-hosts
    master1.vm.provision "shell", inline: "hostname --fqdn > /etc/hostname && hostname -F /etc/hostname"
    master1.vm.provision "shell", inline: "sed -ri 's/127\.0\.0\.1\s.*/127.0.0.1 localhost localhost.localdomain/' /etc/hosts"

    master1.vm.provider "libvirt" do |libvirt|
      libvirt.driver = "kvm"
      libvirt.memory = 2048
      libvirt.cpus = 2
      libvirt.storage :file, :size => '8G'
    end

    master1.vm.provision "shell" do |s|
      s.inline = "echo 'DEVS=\"/dev/vdb\"' > /etc/sysconfig/docker-storage-setup"
    end

    master1.vm.provision "shell", inline: "yum install -y docker"
    master1.vm.provision "shell", inline: "docker-storage-setup"
    master1.vm.provision "shell", inline: "yum update -y && yum clean all"

  end

  3.times do |n|
    config.vm.define "node-#{n}" do |this_host|
      this_host.vm.box = "centos/7"
      this_host.vm.box_check_update = false
      this_host.vm.hostname = "node-#{n}.goern.example.com"

      # a la https://stackoverflow.com/questions/33117939/vagrant-do-not-map-hostname-to-loopback-address-in-etc-hosts
      this_host.vm.provision "shell", inline: "hostname --fqdn > /etc/hostname && hostname -F /etc/hostname"
      this_host.vm.provision "shell", inline: "echo '127.0.0.1 localhost localhost.localdomain' >/etc/hosts"

      this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      this_host.vm.provider "libvirt" do |libvirt|
        libvirt.driver = "kvm"
        libvirt.memory = 2048
        libvirt.cpus = 2
        libvirt.storage :file, :size => '8G'
      end

      this_host.vm.provision "shell", inline: "echo 'DEVS=\"/dev/vdb\"' > /etc/sysconfig/docker-storage-setup"
      this_host.vm.provision "shell", inline: "yum install -y docker"
      this_host.vm.provision "shell", inline: "docker-storage-setup"
      this_host.vm.provision "shell", inline: "yum update -y && yum clean all"
    end
  end

end
