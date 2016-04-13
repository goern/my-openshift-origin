#!/bin/bash

echo 'DEVS="/dev/vdb"' > /etc/sysconfig/docker-storage-setup

yum install -y docker && \
yum clean all

docker-storage-setup

systemctl enable docker && systemctl start docker
