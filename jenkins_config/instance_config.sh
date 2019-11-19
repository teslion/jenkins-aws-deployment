#!/bin/bash
sudo yum update -y

#installs needed programs and depoendencies
sudo yum install wget git unzip awscli java groovy -y
sudo curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo rm get-docker.sh
sudo systemctl start docker
sudo wget https://releases.hashicorp.com/packer/1.4.2/packer_1.4.2_linux_amd64.zip
sudo unzip packer_1.4.2_linux_amd64.zip
chmod +x ./packer
sudo rm packer_1.4.2_linux_amd64.zip
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.11.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

#installs Jenkins
export JENKINS_HOME=/var/lib/jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo mkdir /var/lib/jenkins/init.groovy.d
sudo mv /tmp/setup.groovy /var/lib/jenkins/init.groovy.d/init.groovy
sudo chown jenkins:jenkins /var/lib/jenkins/init.groovy.d
sudo chown jenkins:jenkins /var/lib/jenkins/init.groovy.d/init.groovy
sudo systemctl start jenkins

#adds needed ownership and permissions
sudo gpasswd -a jenkins docker
sudo usermod -a -G docker jenkins
sudo mv /tmp/eksctl /usr/bin/eksctl
sudo mv ./packer /usr/bin/packer.io
sudo mv ./kubectl /usr/bin/kubectl
sudo chown jenkins /usr/bin/packer.io
sudo chown jenkins /usr/bin/kubectl
sudo chown jenkins /usr/bin/eksctl
sudo chgrp jenkins /usr/bin/eksctl
sudo chgrp jenkins /usr/bin/packer.io
sudo chgrp jenkins /usr/bin/kubectl
sudo systemctl restart docker
sudo systemctl restart jenkins

sleep 60
