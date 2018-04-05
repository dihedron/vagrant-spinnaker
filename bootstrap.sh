#!/usr/bin/env bash

#MINIKUBE_VERSION=v0.25.2

if [ "1" -eq "2" ]; then

#
# UPDATE SYSTEM AND INSTALL BASE PACKAGES
#
echo "updating system..."
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install -y curl #apt-transport-https ca-certificates software-properties-common
echo "... DONE!"

#
# INSTALL MINIO.IO AS A DAEMON RUNNING AS MINIO
#
echo "creating minio user..."
useradd -d /home/minio -m -s /bin/false minio
if [ ! -d /data ]; then
	mkdir /data && chown minio:minio /data && chmod 755 /data
if
echo "... DONE!"

fi

echo "downloading minio..."
#curl -LsO https://dl.minio.io/server/minio/release/linux-amd64/minio && mv minio /usr/local/bin && chmod 755 /usr/local/bin/minio
echo "... DONE!"

echo "installing daemon (as $(whoami))..."
cp /vagrant/minio.service /etc/systemd/system && chown root:root /etc/systemd/system/minio.service && chmod 664 /etc/systemd/system/minio.service
echo "... 1"
systemctl daemon-reload
echo "... 2"
systemctl enable minio.service
echo "... 3"
systemctl start minio.service
echo "... DONE!"


#exit 0

#
# INSTALL HALYARD
#
curl -LsO https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh && chmod 755 InstallHalyard.sh && sudo ./InstallHalyard.sh

hal config deploy edit --type localdebian

# extract accessKey
ACCESS_KEY=$(sed -e 's/^"//' -e 's/"$//' <<<"$(cat /home/minio/.minio/config.json | jq '.credential.accessKey')")
SECRET_KEY=$(sed -e 's/^"//' -e 's/"$//' <<<"$(cat /home/minio/.minio/config.json | jq '.credential.secretKey')")
hal config storage s3 edit --access-key-id $ACCESS_KEY --secret-access-key --endpoint http://localhost:9001 <<< "$SECRET_KEY" 
hal config storage edit --type s3
