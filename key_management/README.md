# AWS Key-Pair Management
Create a key-pair resource for use with EC2 instances.

## Populate user variables
*  Copy `user.tfvars` to `user.auto.tfvars`.
    ```bash
    $ cd key_management
    $ cp user.tfvars user.auto.tfvars
    ```

*  Update the values of varibles defined in `user.auto.tfvars`.
    E.g.
    ```
    aws_region = "us-east-1"
    key_name   = "id_ed25519_aws"
    ```

*  Validate the variable values against the terraform formula using:
    ```bash
    $ terraform init            # Initialize working directory for Terraform
    $ terraform fmt -check      # Format the Terraform configuration files
    $ terraform validate        # Validate the configuration files in this directory
    ```

## Create resources
Perform the following steps using AWS CLI:
1. Create key-pair resource

```
$ terraform plan                    # Generates a speculative execution plan
$ terraform apply --auto-approve    # Actually create the resources
```

## Destroy resources
Cleanup all the resources created by the `apply` command in previous step.
```
$ terraform destroy --auto-approve
```

# Generate the TLS private-public key-pair locally
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
