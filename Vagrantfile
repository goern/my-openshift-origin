# -*- mode: ruby -*-
# vi: set ft=ruby :

DEPLOY_IDM=false
DEPLOY_CEPH=false
DEPLOY_OPENSHIFT_ORIGIN=true
DEPLOY_GLUSTER=false
DEPLOY_ARTIFACTORY=true
DEPLOY_ICINGA2=true

CEPH_MONS=3
CEPH_OSDS=3

OPENSHIFT_MASTERS=1
OPENSHIFT_NODES=3
OPENSHIFT_NODES_ATOMIC=false
GLUSTER_NODES=1

Vagrant.configure(2) do |config|
  config.ssh.insert_key = false

  # check if the hostmanager plugin is installed
  unless Vagrant.has_plugin?("vagrant-hostmanager")
    raise 'vagrant-hostmanager is not installed! see https://github.com/smdahlen/vagrant-hostmanager'
  end

  if Vagrant.has_plugin?('vagrant-registration')
    config.registration.skip = true
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

  if DEPLOY_ICINGA2
    config.vm.define "icinga2" do |icinga2|
      icinga2.vm.box = "centos/7"
      icinga2.vm.box_check_update = true
      icinga2.vm.hostname = "icinga2.goern.example.com"

      icinga2.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      icinga2.vm.provider "libvirt" do |libvirt|
        libvirt.driver = "kvm"
        libvirt.memory = 2048
        libvirt.cpus = 2
      end

      icinga2.vm.provision "shell", path: "provision-scripts/common.sh"
      icinga2.vm.provision "shell", path: "provision-scripts/epel.sh"

      icinga2.vm.network "forwarded_port", guest: 8081, host: 8081
    end
  end

  if DEPLOY_ARTIFACTORY
    config.vm.define "artifactory" do |artifactory|
      artifactory.vm.box = "centos/7"
      artifactory.vm.box_check_update = true
      artifactory.vm.hostname = "artifactory.goern.example.com"

      artifactory.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      artifactory.vm.provider "libvirt" do |libvirt|
        libvirt.driver = "kvm"
        libvirt.memory = 2048
        libvirt.cpus = 2
      end

      artifactory.vm.provision "shell", path: "provision-scripts/common.sh"
      artifactory.vm.provision "shell", path: "provision-scripts/artifactory.sh"

      artifactory.vm.network "forwarded_port", guest: 8081, host: 8081
    end
  end # artifactory

  if DEPLOY_IDM
    config.vm.define "idm-1" do |idm1|
      idm1.vm.box = "centos/7"
      idm1.vm.box_check_update = true
      idm1.vm.hostname = "idm-1.goern.example.com"

      idm1.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      idm1.vm.provider "libvirt" do |libvirt|
        libvirt.driver = "kvm"
        libvirt.memory = 2048
        libvirt.cpus = 2
      end

      idm1.vm.provision "shell", path: "provision-scripts/common.sh"
      idm1.vm.provision "shell", path: "provision-scripts/idm-server.sh"

      idm1.vm.provision "shell", inline: "yum update -y && yum clean all"
    end
  end

  if not DEPLOY_CEPH
    config.vm.define "nfs-1" do |nfs1|
      nfs1.vm.box = "centos/7"
      nfs1.vm.box_check_update = true
      nfs1.vm.hostname = "nfs-1.goern.example.com"

      nfs1.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

      nfs1.vm.provider :libvirt do |domain|
        domain.memory = 768
        domain.cpus = 1
      end

      nfs1.vm.provision "shell", path: "provision-scripts/common.sh"
      nfs1.vm.provision "shell", path: "provision-scripts/nfs-server.sh"
    end
  end

  if DEPLOY_OPENSHIFT_ORIGIN
    if OPENSHIFT_MASTERS > 1
      config.vm.define "lb-1" do |lb1|
        lb1.vm.box = "centos/7"
        lb1.vm.box_check_update = true
        lb1.vm.hostname = "master.goern.example.com"

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
        this_host.vm.box = "centos/7"
        this_host.vm.box_check_update = true
        this_host.vm.hostname = "master-#{n}.goern.example.com"

        this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

        this_host.vm.provider "libvirt" do |libvirt|
          libvirt.driver = "kvm"
          libvirt.memory = 2048
          libvirt.cpus = 2
          libvirt.storage :file, :size => '16G'
        end

        this_host.vm.provision "shell", path: "provision-scripts/common.sh"
        this_host.vm.provision "shell", path: "provision-scripts/docker.sh"

        this_host.vm.provision "shell", inline: "mkdir -p /etc/origin/master && echo 'admin:$apr1$NRX9JJxb$kqO2v6n5fLCN2M8cZ0vu10' >/etc/origin/master/htpasswd"

        if OPENSHIFT_MASTERS == 1
          this_host.vm.network "forwarded_port", guest: 8443, host_ip: '', host: 8443
        end
      end
    end

    OPENSHIFT_NODES.times do |n|
      config.vm.define "node-#{n}" do |this_host|
        if OPENSHIFT_NODES_ATOMIC
          this_host.vm.box = "centos/atomic-host"
        elsif
          this_host.vm.box = "centos/7"
        end

        this_host.vm.box_check_update = true
        this_host.vm.hostname = "node-#{n}.goern.example.com"

        this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

        this_host.vm.provider "libvirt" do |libvirt|
          libvirt.driver = "kvm"
          libvirt.memory = 2048
          libvirt.cpus = 2
          libvirt.storage :file, :size => '18G'
        end

        if !OPENSHIFT_NODES_ATOMIC
          this_host.vm.provision "shell", path: "provision-scripts/common.sh"
          this_host.vm.provision "shell", path: "provision-scripts/docker.sh"
        end
      end
    end

    if DEPLOY_GLUSTER
      GLUSTER_NODES.times do |n|
        config.vm.define "gluster-node-#{n}" do |this_host|
          this_host.vm.box = "centos/7"
          this_host.vm.box_check_update = true

          this_host.vm.hostname = "gluster-node-#{n}.goern.example.com"

          this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

          this_host.vm.provider "libvirt" do |libvirt|
            libvirt.driver = "kvm"
            libvirt.memory = 2048
            libvirt.cpus = 2

            # this is vdb for docker
            libvirt.storage :file, :size => '8G'
            # this is for gluster itself
            libvirt.storage :file, :size => '16G'
          end

          this_host.vm.provision "shell", path: "provision-scripts/common.sh"

          this_host.vm.provision "shell", path: "provision-scripts/docker.sh"
        end
      end
    end
  end

  if DEPLOY_CEPH
    CEPH_MONS.times do |n|
      config.vm.define "ceph-mon-#{n}" do |this_host|
        this_host.vm.box = "centos/7"
        this_host.vm.box_check_update = true
        this_host.vm.hostname = "ceph-mon-#{n}.goern.example.com"

        this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

        this_host.vm.provider "libvirt" do |libvirt|
          libvirt.driver = "kvm"
          libvirt.memory = 1024
          libvirt.cpus = 1
          libvirt.storage :file, :size => '4G'
        end

        this_host.vm.provision "shell", path: "provision-scripts/common.sh"
      end
    end

    CEPH_OSDS.times do |n|
      config.vm.define "ceph-osd-#{n}" do |this_host|
        this_host.vm.box = "centos/7"
        this_host.vm.box_check_update = true
        this_host.vm.hostname = "ceph-osd-#{n}.goern.example.com"

        this_host.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

        this_host.vm.provider "libvirt" do |libvirt|
          libvirt.driver = "kvm"
          libvirt.memory = 1024
          libvirt.cpus = 1

          libvirtdriverletters = ('b'..'z').to_a
          (0..1).each do |d|
            libvirt.storage :file, :device => "vd#{libvirtdriverletters[d]}", :path => "disk-#{n}-#{d}.disk", :size => '4G'
          end
        end

        this_host.vm.provision "shell", path: "provision-scripts/common.sh"
      end
    end
  end

end
