#!/usr/bin/env bash

# Name      : flatpak_system_to_user.sh
# Purpose   : Migrating system flatpaks from system to user
# 
# Usage: 
# - create the file in some folder, do `chmod +x flatpak_system_to_user.sh
# - run ./flatpak_system_to_user.sh as your user from that folder. 

#
# Check whether user is not "root"
#
check_root() {
echo "Checking for user or root" >&2
if [[ ! $EUID > 0 ]]; then
  echo "Run this as your user, exiting" >&2
  exit 1
else 
  echo "All well, you are not root" >&2
fi
}

#
# Set some vars 
#
set_vars() {
FLATPAK_REMOTE_NAME="flathub"
FLATPAK_REMOTE_URL="https://flathub.org/repo/flathub.flatpakrepo"
FLATPAK_REMOTE_DISABLED="disabled"
FLATPAK_REMOTE_USER=$(flatpak --user remote-list --show-disabled| awk '{print $1}')
FLATPAK_REMOTE_USER_DISABLED=$(flatpak --user remote-list --show-disabled | awk '{print $2}')
FLATPAK_SYSTEM_COUNT=0
FLATPAK_USER_COUNT=0
}

#
# Install flathub remote to the user if needed
#
setup_remote() {
echo "Checking for user's flathub remote" >&2
if [[ ! $FLATPAK_REMOTE_USER ]]; then
  echo "- User's flathub remote not installed" >&2
  echo "- Adding flathub remote for user" >&2
  flatpak --user remote-add --if-not-exists "$FLATPAK_REMOTE_NAME" "$FLATPAK_REMOTE_URL"
  sleep 5
  echo "- User's flathub remote now installed" >&2  
  flatpak --user remote-modify --enable "$FLATPAK_REMOTE_NAME" >/dev/null 2>&1
  sleep 5
  echo "- User's flathub remote now enabled" >&2  
else 
  echo "- User's flathub remote already installed" >&2
  echo "Checking for user's flathub remote status" >&2 
  if [[ $FLATPAK_REMOTE_USER_DISABLED ]]; then
    echo "- User's flathub remote is disabled" >&2
    flatpak --user remote-modify --enable "$FLATPAK_REMOTE_NAME" >/dev/null 2>&1
    sleep 5
    echo "- User's flathub remote is now enabled" >&2
  else
    echo "- User's flathub remote already enabled" >&2   
  fi
  echo "- User's flatpak remote setup complete !" >&2
fi
}

#
# Create lists from both system and user installed flatpaks
#
migrate() {
echo "Creating lists from system and user installed flatpaks" >&2
mapfile -t system_fp < <(flatpak --system list --columns=ref | awk 'NF {print $1}')
mapfile -t user_fp < <(flatpak --user list --columns=ref | awk 'NF {print $1}')
# Build a set of system‑installed flatpak refs
declare -A system_set
for ref in "${system_fp[@]}"; do
  system_set["$ref"]=1
  ((FLATPAK_SYSTEM_COUNT++))
done
echo "- List for system's flatpak remote done" >&2
# Build a set of user‑installed flatpak refs
declare -A user_set
for ref in "${user_fp[@]}"; do
  user_set["$ref"]=1
  ((FLATPAK_USER_COUNT++))
done
echo "- List for user's flatpak remote done" >&2
# Create system installed flatpak counter
OLD=$FLATPAK_SYSTEM_COUNT
TODO=0
FP=""
if [[ $OLD == 1 ]]; then
  FP="flatpak"
else
  FP="flatpaks"
fi
# fp_move system_fp userset
fp_move
}

#
# For each system flatpak, install in user if missing, then remove feerom system
#
fp_move() {
echo "Totals: System: $OLD >> User: $FLATPAK_USER_COUNT" >&2
if [[ ! $OLD == 0 ]]; then
  for ref in "${system_fp[@]}"; do
    TODO=$(($OLD - $FLATPAK_SYSTEM_COUNT +1))
    echo "Migrating $TODO of $OLD flatpaks from system to user install: $ref" >&2
    if [[ -n "${user_set[$ref]+x}" ]]; then 
      echo "- Already in user install: $ref" >&2
      echo "- Uninstalling flatpak from system: $ref" >&2
      sudo flatpak uninstall -y --system  --force-remove --noninteractive "$ref" >/dev/null 2>&1
      echo "- Uninstalled from system: $ref" >&2
      ((FLATPAK_SYSTEM_COUNT--))
      echo "- Done: $TODO of $OLD | To do: $FLATPAK_SYSTEM_COUNT of $OLD  | User: $FLATPAK_USER_COUNT" >&2
    else 
      echo "- Installing flatpak to user: $ref" >&2
      flatpak install -y --user --noninteractive flathub "$ref" >/dev/null 2>&1    
      echo "- Installed to user: $ref" >&2
      ((FLATPAK_USER_COUNT++))
      echo "- Done: $TODO of $OLD | To do: $FLATPAK_SYSTEM_COUNT of $OLD  | User: $FLATPAK_USER_COUNT" >&2
      echo "- Uninstalling flatpak from system: $ref" >&2
      sudo flatpak uninstall -y --system --force-remove --noninteractive "$ref" >/dev/null 2>&1
      echo "- Uninstalled from system: $ref" >&2
      ((FLATPAK_SYSTEM_COUNT--))
      echo "- Done: $TODO of $OLD | To do: $FLATPAK_SYSTEM_COUNT of $OLD  | User: $FLATPAK_USER_COUNT" >&2
    continue
    fi
  done
  echo -e "\nMigration of $OLD $FP to user's flathub remote completed" >&2
else 
  echo -e "\nMigration of $TODO $FP to user is useless, exiting" >&2
fi
}

echo -e "\n         --- THE END ---"

#
# run the functions
# 
check_root
set_vars
setup_remote
migrate
