# Setup IAM Roles
Create IAM roles with policies to enable read-only S3 buacket access from EC2 instance.

# Populate user variables
*  Copy `user.tfvars` to `user.auto.tfvars`.
    ```bash
    $ cd iam
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
1. Create the IAM role with associated permissions/policies and relationships
```bash
$ terraform plan                   # Generates a speculative execution plan
$ terraform apply                  # Actually create the resources
```

## Destroy resources
Cleanup all the resources created by the `apply` command in previous step.
```bash
$ terraform destroy --auto-approve
```
