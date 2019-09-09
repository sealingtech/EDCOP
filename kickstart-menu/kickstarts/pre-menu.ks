%pre --interpreter=/usr/bin/bash
exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
chvt 6
mkdir -p /tmp/ks
mkdir -p /build/isolinux/ks/
chmod -R 755 /build
mkdir /kickstarts/
python /run/install/repo/EXTRAS/kickstart-menu/menu.py
cp /build/isolinux/ks/vars /tmp
chvt 1
%end

