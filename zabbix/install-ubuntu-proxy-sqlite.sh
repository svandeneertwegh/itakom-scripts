#!/bin/bash

ZABBIX_RELEASE_VERSION="7.4"
UBUNTU_VERSION=$(lsb_release -rs)
PACKAGE_NAME="zabbix-release_latest_${ZABBIX_RELEASE_VERSION}+ubuntu${UBUNTU_VERSION}_all.deb"
ZABBIX_REPOSITORY_URL="https://repo.zabbix.com/zabbix/${UBUNTU_VERSION}/release/ubuntu/pool/main/z/zabbix-release/${PACKAGE_NAME}"

echo "-> "
echo "-> You are installing zabbix proxy with sqlite3 support"
echo "-> ================================================="
echo "-> You are using Ubuntu version: ${UBUNTU_VERSION}"
echo "-> You are installing the zabbix release: ${ZABBIX_RELEASE_VERSION}"
echo "-> ================================================"

if dpkg-query -l "$PACKAGE_NAME" >/dev/null 2>&1; then
    echo "-> Package '$PACKAGE_NAME' is already installed."
    echo "-> Latest zabbix release is already installed"
    exit
else
    echo "-> Package '$PACKAGE_NAME' is NOT installed."
    echo "-> Trying to install latest release"
    echo "-> Downloading zabbix version ${ZABBIX_RELEASE_VERSION} apt repository"
    echo $ZABBIX_REPOSITORY_URL;
    sudo wget -O - "$ZABBIX_REPOSITORY_URL"
    echo "-> Install the zabbix source package"
    sudo dpkg -i $ZABBIX_RELEASE_DEB
    echo "-> Remove obsolete zabbix source package"
    sudo rm $ZABBIX_RELEASE_DEB
fi 


echo "-> Update the apt package manager"
sudo apt update

echo "-> Install zabbix proxy with sqlite support"
sudo apt install zabbix-proxy-sqlite3

echo "-> Set hostname"
read -p "Choose a hostname for zabbix proxy: " yn
echo $yn

sed -i 's/DBName=(.*)/DBName=$yn/g' /etc/zabbix/zabbix-proxy

