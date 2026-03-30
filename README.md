### Description
So far there is no good tooling to move the flatpaks installed with the defaults from `system` to `user`. I did not want to go through them manually, so wrote a bash script

### Example Amarok
Before:
```
knurpht@Lenovo-P16:~> LANG=C flatpak --system list
Name                                Application ID                                   Version           Branch
Mesa                                org.freedesktop.Platform.GL.default              25.3.5            25.08
Mesa (Extra)                        org.freedesktop.Platform.GL.default              25.3.5            25.08-extra
Codecs Extra Extension              org.freedesktop.Platform.codecs-extra                              25.08-extra
Adwaita theme                       org.kde.KStyle.Adwaita                                             6.10
KDE Application Platform            org.kde.Platform                                                   6.10
Amarok                              org.kde.amarok                                   3.3.2             stable
knurpht@Lenovo-P16:~> 

knurpht@Lenovo-P16:~> LANG=C flatpak --user list | grep -i amarok
knurpht@Lenovo-P16:~> 

knurpht@Lenovo-P16:~> LANG=C flatpak --user remotes
knurpht@Lenovo-P16:~> 
```
This shows that Amarok is installed as system flatpak, not installed as user flatpak, and that the user has no remote installed. This comes from my real system where I aleady ran the script before, so the rest of the flatpaks are already gone to the user. 

### Running the script
```
knurpht@Lenovo-P16:~> flatpak_system_to_user.sh
Checking for user or root
All well, you are not root
Checking for user's flathub remote
- User's flathub remote not installed
- Adding flathub remote for user
- User's flathub remote now installed
- User's flathub remote now enabled
Creating lists from system and user installed flatpaks
- List for system's flatpak remote done
- List for user's flatpak remote done
Totals: System: 6 >> User: 51
Migrating 1 of 6 flatpaks from system to user install: org.freedesktop.Platform.GL.default/x86_64/25.08
- Already in user install: org.freedesktop.Platform.GL.default/x86_64/25.08
- Uninstalling flatpak from system: org.freedesktop.Platform.GL.default/x86_64/25.08
- Uninstalled from system: org.freedesktop.Platform.GL.default/x86_64/25.08
- Done: 1 of 6 | To do: 5 of 6  | User: 51
Migrating 2 of 6 flatpaks from system to user install: org.freedesktop.Platform.GL.default/x86_64/25.08-extra
- Already in user install: org.freedesktop.Platform.GL.default/x86_64/25.08-extra
- Uninstalling flatpak from system: org.freedesktop.Platform.GL.default/x86_64/25.08-extra
- Uninstalled from system: org.freedesktop.Platform.GL.default/x86_64/25.08-extra
- Done: 2 of 6 | To do: 4 of 6  | User: 51
Migrating 3 of 6 flatpaks from system to user install: org.freedesktop.Platform.codecs-extra/x86_64/25.08-extra
- Already in user install: org.freedesktop.Platform.codecs-extra/x86_64/25.08-extra
- Uninstalling flatpak from system: org.freedesktop.Platform.codecs-extra/x86_64/25.08-extra
- Uninstalled from system: org.freedesktop.Platform.codecs-extra/x86_64/25.08-extra
- Done: 3 of 6 | To do: 3 of 6  | User: 51
Migrating 4 of 6 flatpaks from system to user install: org.kde.KStyle.Adwaita/x86_64/6.10
- Already in user install: org.kde.KStyle.Adwaita/x86_64/6.10
- Uninstalling flatpak from system: org.kde.KStyle.Adwaita/x86_64/6.10
- Uninstalled from system: org.kde.KStyle.Adwaita/x86_64/6.10
- Done: 4 of 6 | To do: 2 of 6  | User: 51
Migrating 5 of 6 flatpaks from system to user install: org.kde.Platform/x86_64/6.10
- Already in user install: org.kde.Platform/x86_64/6.10
- Uninstalling flatpak from system: org.kde.Platform/x86_64/6.10
- Uninstalled from system: org.kde.Platform/x86_64/6.10
- Done: 5 of 6 | To do: 1 of 6  | User: 51
Migrating 6 of 6 flatpaks from system to user install: org.kde.amarok/x86_64/stable
- Installing flatpak to user: org.kde.amarok/x86_64/stable
- Installed to user: org.kde.amarok/x86_64/stable
- Done: 6 of 6 | To do: 1 of 6  | User: 52
- Uninstalling flatpak from system: org.kde.amarok/x86_64/stable
- Uninstalled from system: org.kde.amarok/x86_64/stable
- Done: 6 of 6 | To do: 0 of 6  | User: 52

Migration of 6 flatpaks to user's flathub remote completed

         --- THE END ---
knurpht@Lenovo-P16:~> 
```

### The result
Migration finished? 
Let's check
```
knurpht@Lenovo-P16:~> flatpak --system list
knurpht@Lenovo-P16:~> 

knurpht@Lenovo-P16:~> LANG=C flatpak --user remotes 
Name    Options
flathub
knurpht@Lenovo-P16:~>

knurpht@Lenovo-P16:~> flatpak --user list | grep -i amarok
Amarok  org.kde.amarok  3.3.2   stable
knurpht@Lenovo-P16:~> 

```

### Instructions
### 
```
git clone https://github.com/knurpht/flatpak_system_to_user.sh.git
cd flatpak_system_to_user.sh
chmod +x flatpak_system_to_user.sh
./flatpak_system_to_user.sh
```
### May the FOSS be with you !!!
