#!/bin/bash
#
# Startup script to execute when bootstrapping a new student VM.
# The script will install everything necessary to participate in the
# cloud forensics workshop.

max_retry=10
logfile="/startup-script-status.log"

# Packages to install via apt. Note that 'helm' has been removed.
packages=(
  tmux
  python3-pip
  apt-transport-https
  ca-certificates
  gnupg
  curl
  sudo
  git
  python3-poetry
  google-cloud-cli
  google-cloud-sdk-gke-gcloud-auth-plugin
  kubectl
)

log() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >> "${logfile}"
}

install_apt_packages() {
  # The DEBIAN_FRONTEND=noninteractive is important to prevent
  # prompts that would hang the script.
  DEBIAN_FRONTEND=noninteractive apt-get -y install "${packages[@]}" 2>&1 >> "${logfile}"
  return $?
}

log "Starting startup script ..."

# --- APT Repository Setup ---
log "Adding Google Cloud APT repository..."
curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list

# --- APT Package Installation ---
log "Updating package lists and installing APT packages..."
exit_code=1
for try in $(seq 1 ${max_retry}); do
  log "[$try/$max_retry] Attempting to update and install..."
  apt-get update 2>&1 >> "${logfile}"
  if install_apt_packages; then
    exit_code=0
    log "Successfully installed all APT packages."
    break
  else
    log "[$try/$max_retry] Failed to install APT packages. Retrying in 15 seconds."
    sleep 15
  fi
done;

if [ ${exit_code} -ne 0 ]; then
    log "CRITICAL: Could not install APT packages after ${max_retry} attempts."
fi

# --- Install Helm ---
log "Installing Helm using the official script..."
if curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash &>> "${logfile}"; then
  log "Helm installed successfully."
else
  log "CRITICAL: Failed to install Helm."
  exit_code=1 # Mark the script as failed if Helm is critical
fi

# --- Environment Setup ---
log "Adding global environment variables..."
echo "export DFTIMEWOLF_NO_CURSES=1" > /etc/profile.d/workshop-env.sh
log "DONE"

log "Startup script finished!"
(exit ${exit_code})
