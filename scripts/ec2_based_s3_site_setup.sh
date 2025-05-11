#!/usr/bin/env bash
# set -e

trap '
  cleanup
' ERR INT TERM

function cleanup() {
    echo "An error occurred or script was interrupted..."
    sudo umount /mnt/s3fs-bucket
    sudo rm -rf /mnt/s3fs-bucket
    sudo yum erase mount-s3
    exit 40
}


function setup_mount_s3() {
  # Step1: Install utility
  # Reference: Installation - https://docs.aws.amazon.com/AmazonS3/latest/userguide/mountpoint-installation.html

  sudo yum clean all
  sudo yum update -y
  sudo yum list --installed | grep -o mount-s3
  if [[ $? != 0 ]]; then
    sudo yum install --assumeyes https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.rpm
  fi

  # Step2: Verify installation
  mount-s3 --version
  read -t60 -p "Verify if the installed version above is correct. Press any key to continue..."

  # Step3: Mount
  # Reference: Mount - https://docs.aws.amazon.com/AmazonS3/latest/userguide/mountpoint-usage.html
  [[ -d /mnt/s3fs-bucket ]] || sudo mkdir -p /mnt/s3fs-bucket

  if sudo mountpoint /mnt/s3fs-bucket >/dev/null; then
    echo "Mount exists for directory /mnt/s3fs-bucket"
  else
    read -t60 -p "Provide the s3 bucket name to mount: " s3_bucket_name
    echo "Mounting bucket ${s3_bucket_name} to /mnt/s3fs-bucket"
    sudo mount-s3 ${s3_bucket_name} /mnt/s3fs-bucket
  fi
}


# function configure_nginx_s3_location() {
#   echo "Configuring Nginx location for S3 bucket..."

#   # Define the Nginx configuration snippet
#   # Using a heredoc for clarity
#   read -r -d '' NGINX_CONF << EOM
#     # Location block to serve files from the mounted S3 bucket
#     location /s3-bucket-objects/ {
#         alias /mnt/s3fs-bucket/;
#         autoindex on; # Enable directory listing
#         index index.html index.htm;
#     }
# EOM

#   local nginx_config_file="/etc/nginx/conf.d/s3-bucket.conf"

#   # Create a simple server block if the file doesn't exist or is empty
#   # This is a basic example; your actual server block might be more complex
#   if [ ! -s "$nginx_config_file" ]; then
#     echo "Creating basic server block in $nginx_config_file"
# sudo bash -c "cat > $nginx_config_file" << SERVER_BLOCK
# server {
#     listen 80 default_server;
#     listen [::]:80 default_server;

#     server_name _; # Catch-all server name

#     root /usr/share/nginx/html; # Default root, adjust if needed
#     index index.html index.htm;

#     location / {
#         try_files \$uri \$uri/ =404;
#     }

#     # Insert the S3 location block here
#     $NGINX_CONF

# }
# SERVER_BLOCK

#   # Validate Nginx configuration
#   sudo nginx -t

#   # Reload Nginx to apply changes
#   sudo systemctl reload nginx
#   echo "Nginx reloaded."
# }


# function setup_webserver() {
#   # Setup nginx
#   [[ ! $(yum list --installed nginx) ]] && sudo yum install --assumeyes nginx
#   sudo systemctl enable --now nginx
#   sudo systemctl status -l nginx
#   configure_nginx_s3_location
# }


function auth_mod_setup() {
  # Setup python and flask
  [[ ! $(yum list --installed python3.12) ]] && sudo yum install --assumeyes python3.12

  # Setup oauth using Python flask
  python3.12 -m ensurepip --upgrade
  python3.12 -m pip install --upgrade pip -r requirements.txt
}

setup_mount_s3
auth_mod_setup
