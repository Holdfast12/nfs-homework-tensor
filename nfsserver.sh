#!/bin/bash
sudo systemctl enable nfs --now
sudo hostname nfs-server
sudo echo nfs-server > /etc/hostname
