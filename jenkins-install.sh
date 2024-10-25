#!/bin/bash
# Ensure that your software packages are up to date on your instance by using the following command to perform a quick software update:
sudo yum update –y
sudo yum install wget -y

# Add the Jenkins repo using the following command:
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

#Import a key file from Jenkins-CI to enable installation from the package:
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum upgrade -y

# Install Java (Amazon Linux 2023):
sudo dnf install java-17-amazon-corretto -y

sudo echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install Jenkins
sudo yum install jenkins -y

# Enable the Jenkins service to start at boot:
sudo systemctl enable jenkins

# Start Jenkins as a service:
sudo systemctl start jenkins

# Installing Git
sudo yum install git -y
