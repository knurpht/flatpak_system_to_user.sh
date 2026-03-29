### Description
So far there is no good tooling to move the flatpaks installed with the defaults from `system` to `user`. I did not want to go through them manually, so wrote a bash script

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
This from my real system where I aleady ran the script before, so the rest of the flatpaks are already gone, just not KDEnlive and its deps.

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

