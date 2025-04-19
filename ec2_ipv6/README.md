# Deploy EC2 Instance(s)
Deploy basic EC2 instance(s) with IPv6 public IP.

## Prerequisites
1. Ensure a AWS key-pair resource is already created before proceeding to create EC2 instance.\
To create a AWS key-pair resource, follow [AWS Key-Pair Management](../key_management/README.md#AWS_Key-Pair_Management).

2. Ensure the AWS VPC, subnet and security groups for IPv6 subnet are created.
To create a AWS VPC, subnet and security groups for IPv6, follow: [Create IPv6 VPC](../vpc/README.md#Create_IPv6_VPC).

## Populate user variables
*  Copy `user.tfvars` to `user.auto.tfvars`.
    ```bash
    $ cd ec2_ipv6
    $ cp user.tfvars user.auto.tfvars
    ```

*  Update the values of varibles defined in `user.auto.tfvars`.

*  Validate the variable values against the terraform formula using:
    ```bash
    $ terraform init      # Initialize working directory for Terraform
    $ terraform fmt       # Format the Terraform configuration files
    $ terraform validate  # Validate the configuration files in this directory
    ```

## Create resources
Perform the following steps using AWS CLI:
1. Create EC2 instance and assign the key-pair as well as the new created security group

```bash
$ terraform plan                    # Generates a speculative execution plan
$ terraform apply --auto-approve    # Actually create the resources
```

## Destroy resources
Cleanup all the resources created by the `apply` command in previous step.
```bash
$ terraform destroy --auto-approve
```

## Connect to AWS
**Note**: If ssh port is modified using `ssh_port` variable, ensure it is appropriately set in ssh commands below.

(Assuming AMI default user to be **ec2-user**.)
```bash
$ ssh -p <CUSTOM_SSH_PORT> -i id_ed25519_aws.pem -l ec2-user $(terraform output -raw instance_public_dns)
```

**Tip**: If you don't know the user, try logging in as root. This would suggest the preferred login user as shown here:

```bash
$ ssh -p <CUSTOM_SSH_PORT> -i id_ed25519_aws.pem -l root $(terraform output -raw instance_public_dns)
Please login as the user "ec2-user" rather than the user "root".

Connection to <instance_public_dns> closed.
```
