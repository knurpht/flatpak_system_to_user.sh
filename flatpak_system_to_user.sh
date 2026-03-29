  #!/usr/bin/env bash

# Name      : flatpak_system_to_user.sh
# Purpose   : Migrating system flatpaks from system to user
# 
# Usage: 
# - create the file in some folder, do `chmod +x flatpak_system_to_user.sh
# - run ./flatpak_system_to_user.sh as your user from that folder. 

set -euo pipefail

# Set some vars 
USER_NAME=$(whoami)
FLATPAK_REMOTE_NAME="flathub"
FLATPAK_REMOTE_URL="https://flathub.org/repo/flathub.flatpakrepo"
FLATPAK_REMOTE_USER=$(flatpak remote-list --user | awk '{print $1}' | grep -qx "$FLATPAK_REMOTE_NAME")


# Install flathub to the user if needed
echo "Checking for user remote"
if [[ "$(id -un)" != "$USER_NAME" ]]; then
  echo "Run this as $USER_NAME" >&2
  exit 1
fi

if [[ $FLATPAK_REMOTE_USER ]]; then
  echo "Adding flathub remote for user" >&2
  flatpak --user remote-add --if-not-exists "$FLATPAK_REMOTE_NAME" "$FLATPAK_REMOTE_URL"
else echo "User remote already setup"
fi


# Create lists from both system and user installed flatpaks
echo "Create lists from both system and user installed flatpaks" >&2
mapfile -t system_fp < <(flatpak --system list --columns=ref | awk 'NF {print $1}')
mapfile -t user_fp < <(flatpak --user list --columns=ref | awk 'NF {print $1}')

# Build a set of user‑installed flatpak refs
declare -A user_set
for ref in "${user_fp[@]}"; do
  user_set["$ref"]=1
done

# For each system flatpak, install in user if missing, then remove from system

for ref in "${system_fp[@]}"; do
echo "Migrating flatpaks to user install: $ref" >&2
  if [[ -n "${user_set[$ref]+x}" ]]; then
    echo "Already in user install: $ref" >&2
    echo "Uninstall flatpak from system: $ref" >&2
    sudo flatpak uninstall -y --system  --force-remove --noninteractive "$ref"
  else 
    echo "- Installing flatpak to user: $ref" >&2
    flatpak install -y --user --noninteractive flathub "$ref"    
    echo "Uninstall flatpak from system: $ref" >&2
    sudo flatpak uninstall -y --system --force-remove --noninteractive "$ref"
  continue
  fi

done
echo "Migration finished"
