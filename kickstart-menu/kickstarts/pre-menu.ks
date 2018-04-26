%pre --interpreter=/usr/bin/bash
exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
chvt 6
mkdir -p /tmp/ks
python /run/install/repo/EXTRAS/kickstart-menu/menu.py
%end

