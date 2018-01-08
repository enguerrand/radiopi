# radiopi
Bash scripts to stream music on the command line with a minimalistic php frontend

I wrote this to run on a raspberry pi (hence the repo name) and I am currently running it on raspbian, but it's all quite distro-agnostic and should run fine on any distro that provides the dependencies listed below.

Dependencies:
- bash
- webserver with php (tested on apache2)
- players referenced in config/players.conf (currently only cvlc, i.e. package vlc-nox in Raspbian)
- command line tools used to provide stream urls in config/stations.conf (currently only curl)
- amixer
- if you want the poweroff and reboot buttons to work (which comes in handy on a raspberry pi) you'll need sudo and you'll need it to configure such that the webserver is allowed to execute /sbin/shutdown without password. See comments in poweroff.php and/or reboot.php

Installation:
- install dependencies listed above
- clone the repo into a directory that the webserver has access to (e.g. /var/www/html/radiopi on raspbian jessie)
- optionally configure sudo as mentioned above
- adjust contents of files in config as needed. (I believe they are reasonably self-explanatory)
