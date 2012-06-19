#!/bin/sh
PATH=/bin:/sbin/:/usr/bin:/usr/sbin

POOL="rpool"
ROOTFS="${POOL}/ROOT/freebsd-82r"

gpart create -s gpt da0
gpart create -s gpt da1

gpart add -s 128K -t freebsd-boot -l boot0 da0
gpart add -s 128L -t freebsd-boot -l boot1 da1
gpart add -s 4G -t freebsd-swap -l swap0 da0
gpart add -s 4G -t freebsd-swap -l swap1 da1
gpart add -t freebsd-zfs -l disk0 da0
gpart add -t freebsd-zfs -l disk1 da0

gpart bootcode -b /dist/boot/pmbr -p /dist/boot/gptzfsboot -i 1 da0
gpart bootcode -b /dist/boot/pmbr -p /dist/boot/gptzfsboot -i 1 da1

mkdir /boot/zfs
zpool create rpool mirror /dev/gpt/disk0 /dev/gpt/disk1

zfs set checksum=fletcher4 rpool

zfs create -p -o mountpont=/mnt					$ROOTFS
zfs create -o mountpoint=/home					${POOL}/HOME

zfs create -o compression=on	-o exec=on	-o setuid=off	${ROOTFS}/tmp
zfs create							${ROOTFS}/usr
zfs create -o compression=lzjb			-o setuid=off	${ROOTFS}/usr/ports
zfs create -o compression=off	-o exec=off	-o setuid=off	${ROOTFS}/usr/ports/distfiles
zfs create -o compression=off	-o exec=off	-o setuid=off	${ROOTFS}/usr/ports/packages
zfs create -o compression=lzjb	-o exec=off	-o setuid=off	${ROOTFS}/usr/src
zfs create							${ROOTFS}/var
zfs create -o compression=lzjb	-o exec=off	-o setuid=off	${ROOTFS}/var/crash
zfs create			-o exec=off	-o setuid=off	${ROOTFS}/var/db
zfs create -o compression=lzjb	-o exec=on	-o setuid=off	${ROOTFS}/var/db/pkg
zfs create			-o exec=off	-o setuid=off	${ROOTFS}/var/empty
zfs create -o compresison=lzjb	-o exec=off	-o setuid=off	${ROOTFS}/var/log
zfs create -o compression=gzip	-o exec=off	-o setuid=off	${ROOTFS}/var/mail
zfs create			-o exec=off	-o setuid=off	${ROOTFS}/var/run
zfs create -o compression=lzjb	-o exec=on	-o setuid=off	${ROOTFS}/var/tmp

chmod 1777 /mnt/tmp
chmod 1777 /mnt/var/tmp

cd /dist/8.2-RELEASE
DESTDIR=/mnt
export DESTDIR
for dir in base catpages dict doc games info lib32 manpages ports; do
    (cd $dir; ./install.sh)
done;
cd src; ./install.sh all
cd ../kernels; ./install.sh generic
cd /mnt/boot; cp -Rlpv GENERIC/* /mnt/boot/kernel

zfs set readonly=on ${ROOTFS}/var/empty

cat > /mnt/etc/rc.conf << EOF
zfs_enable="YES"
hostname="thalia.hq.draenan.net"
ifconfig_em0="DHCP"
EOF

cat > /mnt/boot/loader.conf << EOF
ahci_load="YES"
zfs_load="YES"
vfs.root.mountfrom="zfs:${ROOTFS}"
EOF

chroot /mnt passwd
chroot /mnt tzsetup
chroot /mnt "cd /etc/mail && make aliases"

cp /boot/zfs/zpool.cache /mnt/boot/zfs/zpool.cache

zpool set bootfs=${ROOTFS} $POOL

cat > /mnt/etc/fstab << EOF
# Device	Mountpoint	FStype	Options	Dump	Pass#
/dev/gpt/swap0	none		swap	sw	0	0
/dev/gpt/swap1	none		swap	sw	0	0
EOF

LD_LIBRARY_PATH="/dist/lib"
export LD_LIBRARY_PATH

cd /
zfs umount -a

zfs set mountpoint=none $POOL
zfs set mountpoint=none ${POOL}/ROOT
zfs set mountpoint=legacy ${ROOTFS}
zfs set mountpoint=/tmp ${ROOTFS}/tmp
zfs set mountpoint=/usr ${ROOTFS}/usr
zfs set mountpoint=/var ${ROOTFS}/var

