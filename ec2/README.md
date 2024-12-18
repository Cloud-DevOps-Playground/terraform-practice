# Deploy EC2 Instance(s)
Deploy basic EC2 instance(s) with your own private-public key-pair.

## Generate the TLS private-public key-pair
**Note**: This is for information purpose only and can be ignored.

Generate PEM files using `ssh-keygen` command:
```
$ mkdir .ssh
$ chmod 755 .ssh
$ ssh-keygen -m PEM -t ed25519 -f .ssh/id_ed25519_aws.pem -P ""
$ chmod 400 .ssh/id_ed25519_aws.pem
$ chmod 644 .ssh/id_ed25519_aws.pem.pub
$ ssh-keygen -y -P "" -f .ssh/id_ed25519_aws.pem    # <= Validate generated key
$ ls -Al .ssh
total 2
-r--r--r-- 1 local_user 197121 411 Dec 11 17:08 id_ed25519_aws.pem
-rw-r--r-- 1 local_user 197121 103 Dec 11 17:08 id_ed25519_aws.pem.pub
```

# Populate user variables
Copy `user.tfvars` to `user.auto.tfvars`.
```
$ cd ec2
$ cp user.tfvars user.auto.tfvars
```

Update the values of varibles defined in `user.auto.tfvars`.
Validate the vairable values against the terraform formula using:
```
$ terraform init      # Initialize working directory for Terraform

$ terraform fmt       # Format the Terraform configuration files
$ terraform validate  # Validate the configuration files in this directory
```

## Create resources
Perform the following steps using AWS CLI:
1. Create TLS key-pair entry for ssh login using the local public key from the generated key-pair
2. Create a new security group in default subnet, in order to allow ssh access to EC2 instance
3. Create EC2 instance and assign the key-pair as well as the new created security group

**Note**: Remember to assign your public IP (_your Internet Provided IP as seen by AWS_) to the **_my_ip_** variable
</br>Or
</br>just rely on `-var my_ip=$(curl -s -4 ifconfig.info | tr -d [:space:])` as used in command below:

```
$ terraform plan -var my_ip=$(curl -s -4 ifconfig.info | tr -d [:space:])                   # Generates a speculative execution plan
$ terraform apply --auto-approve -var my_ip=$(curl -s -4 ifconfig.info | tr -d [:space:])   # Actually create the resources
```

## Destroy resources
Cleanup all the resources created by the `apply` command in previous step.
```
$ terraform destroy --auto-approve -var my_ip=$(curl -s -4 ifconfig.info | tr -d [:space:])
```

## Connect to AWS
**Note**: If ssh port is modified using `ssh_port` variable, ensure it is appropriately set in ssh commands below.

(Assuming AMI default user to be **ec2-user**.)
```
$ ssh -p <CUSTOM_SSH_PORT> -i id_ed25519_aws.pem -l ec2-user $(terraform output -raw instance_public_dns)
```

**Tip**: If you don't know the user, try logging in as root. This would suggest the preferred login user as shown here:

```
$ ssh -p <CUSTOM_SSH_PORT> -i id_ed25519_aws.pem -l root $(terraform output -raw instance_public_dns)
Please login as the user "ec2-user" rather than the user "root".

Connection to <instance_public_dns> closed.
```
