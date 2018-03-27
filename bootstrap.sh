#!/usr/bin/env bash

#MINIKUBE_VERSION=v0.25.2

if [ "1" -eq "2" ]; then
#
# UPDATE SYSTEM AND INSTALL BASE PACKAGES
#
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y curl #apt-transport-https ca-certificates software-properties-common

#
# INSTALL MINIO.IO AS A DAEMON
#
if [ ! -d /data ]; then
	mkdir /data && chown root:root /data && chmod 755 /data
fi
echo "downloading minio..."
curl -LsO https://dl.minio.io/server/minio/release/linux-amd64/minio && mv minio /usr/local/bin && chmod 755 /usr/local/bin/minio
echo "... DONE!"

echo "installing daemon..."
cp /vagrant/minio.service /etc/systemd/system && chown root:root /etc/systemd/system/minio.service && chmod 664 /etc/systemd/system/minio.service
sudo systemctl daemon-reload
sudo systemctl enable minio.service
sudo systemctl start minio.service
echo "... DONE!"

fi
#exit 0

#
# INSTALL HALYARD
#
#curl -LO https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh && chmod 755 InstallHalyard.sh && sudo ./InstallHalyard.sh

hal config deploy edit --type localdebian

# extract accessKey
ACCESS_KEY=$(sed -e 's/^"//' -e 's/"$//' <<<"$(cat /root/.minio/config.json | jq '.credential.accessKey')")
SECRET_KEY=$(sed -e 's/^"//' -e 's/"$//' <<<"$(cat /root/.minio/config.json |jq '.credential.secretKey')")
echo "access: >$ACCESS_KEY<"
echo "secret: >$SECRET_KEY<"
