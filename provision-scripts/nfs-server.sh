#!/bin/bash

# This reuses https://access.redhat.com/solutions/2147871

sudo yum install -y nfs-utils && \
sudo yum clean all

sudo mkdir -p /srv/nfs/registry /srv/nfs/vol0001 /srv/nfs/vol0002 /srv/nfs/vol0003
sudo chmod 777 /srv/nfs/registry /srv/nfs/vol0001 /srv/nfs/vol0002 /srv/nfs/vol0003
sudo chown nfsnobody:nfsnobody /srv/nfs/registry /srv/nfs/vol0001 /srv/nfs/vol0002 /srv/nfs/vol0003
setsebool -P virt_use_nfs 1

sudo chmod 666 /etc/exports
echo '/srv/nfs/registry *(rw,sync,no_root_squash,no_all_squash)' >>/etc/exports
echo '/srv/nfs/vol0001 *(rw,sync,no_root_squash,no_all_squash)' >>/etc/exports
echo '/srv/nfs/vol0002 *(rw,sync,no_root_squash,no_all_squash)' >>/etc/exports
echo '/srv/nfs/vol0003 *(rw,sync,no_root_squash,no_all_squash)' >>/etc/exports
sudo chmod 644 /etc/exports
sudo exportfs -av

cat <<EOT >>/etc/sysconfig/nfs
LOCKD_TCPPORT=32803
LOCKD_UDPPORT=32769
MOUNTD_PORT=892
EOT

sudo systemctl enable rpcbind && sudo systemctl start rpcbind
sudo systemctl enable nfs-server && sudo systemctl start nfs-server
