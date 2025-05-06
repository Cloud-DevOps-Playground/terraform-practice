#!/usr/bin/bash
set -e

SERVICES=("/terraform/key_management" "/terraform/vpc" "/terraform/s3" "/terraform/iam" "/terraform/ec2_ipv6")
# SERVICES=("/terraform/key_management" "/terraform/s3" "/terraform/iam" "/terraform/ec2_ipv4")

trap '
  cleanup
' ERR INT TERM

function cleanup() {
    echo "An error occurred or script was interrupted. Cleaning up..."
    while [[ $(dirs -p | wc -l) -gt 1 ]]; do
        popd
    done
    exit 1
}


function pre_deploy_ops() {
  terraform init
  terraform fmt -check
  terraform validate
}


function deploy() {
  for service in ${SERVICES[@]}; do
    echo "Processing service: $service"
    sleep 15
    pushd ${service}
      pre_deploy_ops
      if [[ "/terraform/vpc" == "${service}" ]]; then
        terraform plan -var my_ip=$(curl -s -6 ifconfig.info | tr -d [:space:])
        terraform apply -auto-approve -var my_ip=$(curl -s -6 ifconfig.info | tr -d [:space:])
      elif [[ "/terraform/ec2_ipv4" == "${service}" ]]; then
        terraform plan -var my_ip=$(curl -s -4 ifconfig.info | tr -d [:space:])
        terraform apply -auto-approve -var my_ip=$(curl -s -4 ifconfig.info | tr -d [:space:])
      else
        terraform plan
        terraform apply -auto-approve
      fi
    popd
  done
}


function destroy() {
  for ((service=${#SERVICES[@]}-1; service>=0; service--)); do
    echo "Processing service: ${SERVICES[${service}]}"
    sleep 15
    pushd ${SERVICES[${service}]}
      # terraform init
      if [[ "/terraform/vpc" == "${SERVICES[${service}]}" ]]; then
        terraform apply -auto-approve -var my_ip=$(curl -s -6 ifconfig.info | tr -d [:space:]) -destroy
      elif [[ "/terraform/ec2_ipv4" == "${SERVICES[${service}]}" ]]; then
        terraform apply -auto-approve -var my_ip=$(curl -s -4 ifconfig.info | tr -d [:space:]) -destroy
      else
        terraform apply -auto-approve -destroy
      fi
    popd
  done
}


if [[ "$1" == "deploy" ]]; then
  deploy
elif [[ "$1" == "destroy" ]]; then
  destroy
else
  echo -e "ERROR: Command error.\n\tSyntax: ./ec2_s3_prvsnr.sh <deploy|destroy>" >&2
  exit 1
fi
