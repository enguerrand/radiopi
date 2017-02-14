<?php
    // need something like the line below in /etc/sudoers for this to work
    // ALL ALL = NOPASSWD: /sbin/shutdown
    exec("sudo /sbin/shutdown -h now &");
?>
