#!/bin/bash -e

install -m 644 files/splash.service "${ROOTFS_DIR}/etc/systemd/system/splashscreen.service"

install -m 644 files/indaba.service "${ROOTFS_DIR}/etc/systemd/system/indaba.service"

install -m 644 files/indaba-supervisor.service "${ROOTFS_DIR}/etc/systemd/system/indaba-supervisor.service"

mkdir -p "${ROOTFS_DIR}/indaba"

install -m 644 files/indaba-update.tar "${ROOTFS_DIR}/indaba/"

cp -R files/supervisor "${ROOTFS_DIR}/indaba/supervisor"

install -m 644 files/splash.png "${ROOTFS_DIR}/opt/splash.png"

# chmod +x "${ROOTFS_DIR}/indaba/indaba-supervisor"

install -m 774 files/gettitan "${ROOTFS_DIR}/indaba/"

chmod +x "${ROOTFS_DIR}/indaba/gettitan"

echo "indaba" > ${ROOTFS_DIR}/etc/hostname

echo "127.0.1.1    indaba" >> ${ROOTFS_DIR}/etc/hosts

on_chroot <<EOF

# SSL Workaround for no time
echo "-k" > ~/.curlrc

# Install docker
curl -sSL https://get.docker.com/ | sh

# update user group
usermod -aG docker indaba

# Install Argon Fan & Power
curl -k https://download.argon40.com/argon1.sh | bash

echo "1=100" > /etc/argononed.conf

# disable splash
sed -i -e "$ i\disable_splash=1" /boot/config.txt

# Install right version of usbmount

apt-get install -y debhelper build-essential ntfs-3g

cd /tmp
git clone https://github.com/rbrito/usbmount.git
cd usbmount
dpkg-buildpackage -us -uc -b
cd ..
apt install -y ./usbmount_0.0.24_all.deb

# update for automount USB
sed -i "s/PrivateMounts=.*/PrivateMounts=no/g" /lib/systemd/system/systemd-udevd.service

sed -i "s/FILESYSTEMS=.*/FILESYSTEMS=vfat ext2 ext3 ext4 hfsplus ntfs exfat fuseblk/g" /etc/usbmount/usbmount.conf

# install framebuffer image viewer && exfat support
apt-get install -y fbi exfat-fuse exfat-utils

# install pipeviewer
apt-get install -y pv

# install node
curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
apt-get install -y nodejs

# install supervisor
cd /indaba/supervisor && npm i

touch /indaba/.supervisorinstalled

# install dnsmasq
apt-get install -y dnsmasq dhcpcd5

echo "address=/#/10.10.10.1" >> /etc/dnsmasq.conf
echo "no-resolv" >> /etc/dnsmasq.conf
echo "bogus-priv" >> /etc/dnsmasq.conf
echo "domain-needed" >> /etc/dnsmasq.conf

#set static IP:
echo "interface eth0" >> /etc/dhcpcd.conf 
echo "static ip_address=10.10.10.1/24" >> /etc/dhcpcd.conf
echo "static routers=10.10.10.254" >> /etc/dhcpcd.conf
echo "static domain_name_servers=10.10.10.254" >> /etc/dhcpcd.conf

#enable indaba
systemctl enable indaba

#enable supervisor
systemctl enable indaba-supervisor

#enable splash
systemctl enable splashscreen

# disable console on boot
echo "console=serial0,115200 console=tty3 root=ROOTDEV rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait splash quiet plymouth.ignore-serial-consoles logo.nologo disable_overscan=1" > /boot/cmdline.txt

# disable bluetooth:
sudo apt-get purge bluez -y
sudo apt-get autoremove -y

#low-power settings:

echo "dtoverlay=disable-bt" >> /boot/config.txt
echo "dtoverlay=pi3-disable-wifi" >> /boot/config.txt
echo "dtoverlay=disable-bt" >> /boot/config.txt
echo "dtparam=eth_led0=4" >> /boot/config.txt
echo "dtparam=eth_led1=4" >> /boot/config.txt
echo "dtparam=act_led_trigger=none" >> /boot/config.txt
echo "dtparam=act_led_activelow=off" >> /boot/config.txt

EOF
