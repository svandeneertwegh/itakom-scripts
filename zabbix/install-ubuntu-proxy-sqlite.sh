#!/bin/bash

ZABBIX_RELEASE_VERSION="7.4"
UBUNTU_VERSION=$(lsb_release -rs)

echo ""
echo "You are installing zabbix proxy with sqlite3 support"
echo "================================================="
echo "You are using Ubuntu version: ${UBUNTU_VERSION}"
echo "You are installing the zabbix release: ${ZABBIX_RELEASE_VERSION}"
echo "================================================"

ZABBIX_RELEASE_DEB="zabbix-release_latest_${ZABBIX_RELEASE_VERSION}+ubuntu${UBUNTU_VERSION}_all.deb"

echo "Download zabbix version ${ZABBIX_RELEASE_VERSION} source"
sudo wget "https://repo.zabbix.com/zabbix/${UBUNTU_VERSION}/release/ubuntu/pool/main/z/zabbix-release/${ZABBIX_RELEASE_DEB}"

echo "Install the zabbix source package"
sudo dpkg -i $ZABBIX_RELEASE_DEB

echo "Remove obsolete zabbix source package"
sudo rm $ZABBIX_RELEASE_DEB

echo "Update the apt package manager"
sudo apt update

echo "Install zabbix proxy with sqlite support"
sudo apt install zabbix-proxy-sqlite3

rm $ZABBIX_RELEASE_DEB

echo "Set hostname"
read -p "Choose a hostname for zabbix proxy: " yn
echo $yn

sed -i 's/DBName=(.*)/DBName=$yn/g' /etc/zabbix/zabbix-proxy

