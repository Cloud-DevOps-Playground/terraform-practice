# Create S3
Create a S3 with public subnet for IPv6 traffic only.

# Populate user variables
*  Copy `user.tfvars` to `user.auto.tfvars`.
    ```bash
    $ cd s3
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
3. Create S3 bucket

```bash
$ terraform plan                   # Generates a speculative execution plan
$ terraform apply                  # Actually create the resources
```

## Destroy resources
Cleanup all the resources created by the `apply` command in previous step.
```bash
$ terraform destroy --auto-approve
```
