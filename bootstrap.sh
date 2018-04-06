#!/usr/bin/env bash

#
# UPDATE SYSTEM
#
echo "updating system..."
apt-get update -y
apt-get dist-upgrade -y
echo "... DONE!"

#
# INSTALL BASE PACKAGES (CURL...)
#
if ! which curl 2>&1 > /dev/null; then 
	echo "installing curl..."
	apt-get install -y curl #apt-transport-https ca-certificates software-properties-common
	echo "... DONE!"
fi

#
# INSTALL MINIO.IO AS A DAEMON RUNNING AS MINIO
#
if ! getent passwd minio 2>&1 > /dev/null; then
	echo "creating minio user..."
	useradd -d /home/minio -m -s /bin/false minio
	echo "... DONE!"
fi

if [ ! -d /data ]; then
	echo "creating minio storage..."
	mkdir /data && chown minio:minio /data && chmod 755 /data
	echo "... DONE!"
fi

if [ ! -f /usr/local/bin/minio ]; then
	echo "downloading minio..."
	curl -LsO https://dl.minio.io/server/minio/release/linux-amd64/minio && mv minio /usr/local/bin && chmod 755 /usr/local/bin/minio
	echo "... DONE!"
fi

if ! systemctl is-enabled minio 2>&1 > /dev/null; then
	echo "installing minio daemon..."
	cp /vagrant/minio.service /etc/systemd/system && chown root:root /etc/systemd/system/minio.service && chmod 664 /etc/systemd/system/minio.service
	systemctl daemon-reload
	systemctl list-units minio.service --all
	systemctl enable minio.service
	echo "... DONE!"
fi 

if ! systemctl is-active minio 2>&1 > /dev/null; then
	echo "starting minio daemon..."
	systemctl start minio.service
	echo $?
	echo "... DONE!"
fi

exit 0

#
# INSTALL HALYARD
#
if [ ! $(which hal) ]; then
	echo "installing Halyard..."
	curl -LsO https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh && chmod 755 InstallHalyard.sh && ./InstallHalyard.sh
	echo "... DONE!"
else 
	update-halyard
	hal -v
fi

#
# SELECT LOCAL DEBIAN ENVIRONMENT
#
echo "configuring local Debian installation..."
hal config deploy edit --type localdebian
echo "... DONE!"

#
# CONFIGURE STORAGE (MINIO AS S3)
#
echo "configuring storage (minio)..."
# extract accessKey and secretKey from minio configuration
ACCESS_KEY=$(sed -e 's/^"//' -e 's/"$//' <<<"$(cat /home/minio/.minio/config.json | jq '.credential.accessKey')")
SECRET_KEY=$(sed -e 's/^"//' -e 's/"$//' <<<"$(cat /home/minio/.minio/config.json | jq '.credential.secretKey')")
echo $SECRET_KEY | hal config storage s3 edit --endpoint http://localhost:9001 --access-key-id $ACCESS_KEY --secret-access-key 
#hal config storage s3 edit --access-key-id $ACCESS_KEY --secret-access-key --endpoint http://localhost:9001 <<< "$SECRET_KEY" 
hal config storage edit --type s3
echo "... DONE!"

exit 0

#
# CONFIGURE CLOUD PROVIDER (K8S OR OPENSTACK)
#
if [ "$1" -eq "--kubernetes" ]; then
	echo "configuring kubernetes $2..."
	# TODO
	echo "... DONE!"
elif [ "$1" -eq "--openstack" ]; then
	echo "configuring openstack $2..."
	# TODO
	echo "... DONE!"
else
	echo "unknown provider!"
fi