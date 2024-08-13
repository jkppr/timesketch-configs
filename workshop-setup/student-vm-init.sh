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
  git
)

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >> /startup-script-status.log
}

install_packages() {
  apt-get -y install ${packages[@]} 2>&1 >> /startup-script-status.log
  return $?
}

echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Starting startup script ..." >> /startup-script-status.log

# Update VM
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Update the VM ..." >> /startup-script-status.log
apt update && apt upgrade -y
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: DONE" >> /startup-script-status.log

# Try to install the packages
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Install default packages ..." >> /startup-script-status.log
exit_code=1
for try in $(seq 1 ${max_retry}); do
  [[ ${try} -gt 1 ]] && sleep 5
  if install_packages; then
    exit_code=0
    break
  else
    err "[$try/$max_retry] Failed to install packages, retrying in 5 seconds."
  fi
done;
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: DONE" >> /startup-script-status.log

# Install gcloud
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Prepare gcloud ..." >> /startup-script-status.log
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install helm
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Prepare helm ..." >> /startup-script-status.log
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Install gcloud & helm ..." >> /startup-script-status.log
apt update && apt install helm google-cloud-cli -y
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: DONE" >> /startup-script-status.log

# Add global env variable
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Add global env vars ..." >> /startup-script-status.log
echo "export DFTIMEWOLF_NO_CURSES=1" > /etc/profile.d/workshop-env.sh

# DONE
echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: Startup script finished!" >> /startup-script-status.log

(exit ${exit_code})
