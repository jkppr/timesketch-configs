#!/bin/bash
#
# Startup script to execute when bootstrapping a new student VM.
# The script will install everything necessary to participate in the
# cloud forensics workshop.

max_retry=100

# Default packages to install
packages=(
  kubectl
  tmux
  python3-pip
  google-cloud-sdk-gke-gcloud-auth-plugin
  apt-transport-https
  ca-certificates
  gnupg
  curl
  sudo
)

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

install_packages() {
  apt -y install ${packages[@]}
}

# Update VM
apt update && apt upgrade -y

# Try to install the packages
for try in $(seq 1 ${max_retry}); do
  [[ ${try} -gt 1 ]] && sleep 5
  install_packages && exit_code=0 && break || exit_code=$?
  err "Failed to install packages, retrying in 5 seconds."
done;

# Install gcloud
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

apt update && apt install helm google-cloud-cli -y

# Add global env variable
echo "export DFTIMEWOLF_NO_CURSES=1" > /etc/profile.d/workshop-env.sh

(exit ${exit_code})
