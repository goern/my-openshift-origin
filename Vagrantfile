# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.ssh.insert_key = false

  # check if the hostmanager plugin is installed
  unless Vagrant.has_plugin?("vagrant-hostmanager")
    raise 'vagrant-hostmanager is not installed! see https://github.com/smdahlen/vagrant-hostmanager'
  end

  # check if the reload plugin is installed
  unless Vagrant.has_plugin?("vagrant-reload")
    raise 'vagrant-reload is not installed! see https://github.com/aidanns/vagrant-reload'
  end

  # and configure the hostmanager plugin
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.include_offline = true

  # set some sane defaults for all VMs
  config.vm.provider :libvirt do |domain|
    domain.memory = 2048
    domain.cpus = 2
  end

  # provision and configure IdM service
  config.vm.define "master-1" do |master1|
    master1.vm.box = "rhel-7.1"
    master1.vm.box_check_update = true
    master1.vm.hostname = "master-1.goern.example.com"

    # a la https://stackoverflow.com/questions/33117939/vagrant-do-not-map-hostname-to-loopback-address-in-etc-hosts
    master1.vm.provision "shell", inline: "hostname --fqdn > /etc/hostname && hostname -F /etc/hostname"
    master1.vm.provision "shell", inline: "sed -ri 's/127\.0\.0\.1\s.*/127.0.0.1 localhost localhost.localdomain/' /etc/hosts"

    master1.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

    master1.vm.provision "shell" do |s|
      s.inline = "subscription-manager register --force --username=#{ENV['REDHAT_USERNAME']} --password=#{ENV['REDHAT_PASSWORD']}"
    end

    master1.vm.provision "shell", path: "./prerequisites.sh"

  end

  # provision and enroll Atomic Hosts
  3.times do |n|
    config.vm.define "node-#{n}" do |this_host|
      this_host.vm.box = "rhel-7.1"
      this_host.vm.box_check_update = false
      this_host.vm.hostname = "node-#{n}.goern.example.com"

      # a la https://stackoverflow.com/questions/33117939/vagrant-do-not-map-hostname-to-loopback-address-in-etc-hosts
      this_host.vm.provision "shell", inline: "hostname --fqdn > /etc/hostname && hostname -F /etc/hostname"
      this_host.vm.provision "shell", inline: "echo '127.0.0.1 localhost localhost.localdomain' >/etc/hosts"

      this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      this_host.vm.provision "shell" do |s|
        s.inline = "subscription-manager register --force --username=#{ENV['REDHAT_USERNAME']} --password=#{ENV['REDHAT_PASSWORD']}"
      end

      this_host.vm.provision "shell", path: "./prerequisites.sh"

    end
  end

end
