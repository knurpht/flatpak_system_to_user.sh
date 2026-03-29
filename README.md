### Description
So far there is no good tooling to move the flatpaks installed with the defaults from `system` to `user`. I did not want to go through them manually, so wrote a bash script `flatpak_system_to_user.sh` ( code below )

### Example KDEnlive
Before:
```
knurpht@Lenovo-P16:~> flatpak --system list
Naam                                Toepassings-ID                                    Versie            Branch
TAP-plugins                         org.freedesktop.LinuxAudio.Plugins.TAP            1.0.1             24.08
SWH                                 org.freedesktop.LinuxAudio.Plugins.swh            0.4.17            24.08
Mesa                                org.freedesktop.Platform.GL.default               25.3.5            24.08
Mesa (Extra)                        org.freedesktop.Platform.GL.default               25.3.5            24.08extra
openh264                            org.freedesktop.Platform.openh264                 2.5.1             2.5.1
Adwaita theme                       org.kde.KStyle.Adwaita                                              6.9
KDE Application Platform            org.kde.Platform                                                    6.9
Kdenlive                            org.kde.kdenlive                                  25.12.2           stable
knurpht@Lenovo-P16:~> flatpak --system list | grep -i kdenlive
Kdenlive        org.kde.kdenlive        25.12.2 stable
knurpht@Lenovo-P16:~> flatpak --user list | grep -i kdenlive
knurpht@Lenovo-P16:~> 
```
This from my real system where I aleady ran the script, so the rest of the flatpaks are already there, just not KDEnlive and its deps.

### The script
```
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
```
The script spits out some output on the way. 

### The result
Migration finished? 
Let's check
```
knurpht@Lenovo-P16:~/bin> flatpak --system list
knurpht@Lenovo-P16:~/bin> flatpak --system list
knurpht@Lenovo-P16:~/bin> flatpak --user list | grep -i kdenlive
Kdenlive        org.kde.kdenlive        25.12.2 stable
knurpht@Lenovo-P16:~/bin> 
```

