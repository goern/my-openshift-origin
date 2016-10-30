#!/bin/bash

ARTIFACTORY_VERSION=4.13.1

yum install -y net-tools java-1.8.0-openjdk postgresql-server wget

wget https://bintray.com/jfrog/artifactory-pro-rpms/rpm -O /etc/yum.repos.d/bintray-jfrog-artifactory-pro-rpms.repo

# rpm -Uvh https://bintray.com/jfrog/artifactory-rpms/download_file?file_path=jfrog-artifactory-oss-${ARTIFACTORY_VERSION}.rpm
yum install -y jfrog-artifactory-pro

systemctl enable artifactory && systemctl start artifactory
