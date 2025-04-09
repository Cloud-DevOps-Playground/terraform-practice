#!/usr/bin/env bash

# Install necessary utils
yum install -y yum-utils
yum install -y git unzip

# Install Terraform
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum install -y terraform

# install aws-cli
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -i /opt/aws/aws-cli -b /usr/local/bin
/usr/local/bin/aws --version
rm -rf awscliv2.zip /tmp/aws

# Setup aws credentials
ln -s /terraform/.aws ~/.aws
