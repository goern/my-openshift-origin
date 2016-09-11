#!/bin/bash

echo 'DEVS="/dev/vdb"' > /etc/sysconfig/docker-storage-setup

yum install -y docker && \
yum clean all

docker-storage-setup
lvextend --size 16G /dev/VolGroup00/docker-pool

systemctl enable docker && systemctl start docker
