#!/usr/bin/bash
set -e

# SERVICES=("/terraform/s3" "/terraform/iam" "/terraform/ec2_ipv6")
# SERVICES=("/terraform/s3" "/terraform/iam" "/terraform/ec2_ipv4")

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
  terraform fmt
  terraform validate
}


function deploy() {
  for service in ${SERVICES[@]}; do
    echo -e "\033[1mProcessing service:\033[0m $service"
    sleep 15
    pushd ${service}
      pre_deploy_ops
      terraform plan
      terraform apply -auto-approve
    popd
  done
}


function destroy() {
  for ((service=${#SERVICES[@]}-1; service>=0; service--)); do
    echo "Processing service: ${SERVICES[${service}]}"
    sleep 15
    pushd ${SERVICES[${service}]}
      # terraform init
      terraform apply -auto-approve -destroy
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
