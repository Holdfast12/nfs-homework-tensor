#!/bin/bash
sudo mkdir -p /mnt/nfs_shares/backups
echo "/mnt/nfs_shares/backups 192.168.1.2/24(rw,sync,no_root_squash)" | sudo tee -a /etc/exports
#sudo exportfs -a
sudo systemctl enable nfs --now
sudo firewall-cmd --zone=public --permanent --add-service=nfs --add-service=rpc-bind --add-service=mountd
sudo firewall-cmd --reload
sudo hostname nfs-server
sudo echo nfs-server > /etc/hostname
