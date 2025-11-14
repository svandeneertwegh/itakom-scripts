#!/bin/bash

ZABBIX_RELEASE_VERSION="7.4"
UBUNTU_VERSION=$(lsb_release -rs)
PACKAGE_NAME="zabbix-release_latest_${ZABBIX_RELEASE_VERSION}+ubuntu${UBUNTU_VERSION}_all.deb"
ZABBIX_REPOSITORY_URL="https://repo.zabbix.com/zabbix/${ZABBIX_RELEASE_VERSION}/release/ubuntu/pool/main/z/zabbix-release/${PACKAGE_NAME}"
DEST_PATH="/tmp/${PACKAGE_NAME}"

echo -e "033[0;32m-> 033[0m"
echo -e "033[0;32m-> You are installing zabbix proxy with sqlite3 support033[0m"
echo -e "033[0;32m-> =================================================033[0m"
echo -e "033[0;32m-> You are using Ubuntu version: ${UBUNTU_VERSION}033[0m"
echo -e "033[0;32m-> You are installing the zabbix release: ${ZABBIX_RELEASE_VERSION}033[0m"
echo -e "033[0;32m-> ================================================033[0m"

if dpkg-query -l "$PACKAGE_NAME" >/dev/null 2>&1; then
    echo -e "033[0;32m-> Package '$PACKAGE_NAME' is already installed.033[0m"
    echo -e "033[0;32m-> Latest zabbix release is already installed033[0m"
    exit
else
    echo -e "033[0;32m-> Package '$PACKAGE_NAME' is NOT installed.033[0m"
    echo -e "033[0;32m-> Trying to install latest release033[0m"
    echo -e "033[0;32m-> Downloading zabbix version ${ZABBIX_RELEASE_VERSION} apt repository033[0m"
    echo $ZABBIX_REPOSITORY_URL;
    sudo wget -O - "$ZABBIX_REPOSITORY_URL" | sudo tee "$DEST_PATH" > /dev/null
    echo -e "033[0;32m-> Install the zabbix source package033[0m"
    sudo dpkg -i "${DEST_PATH}"
    echo -e "033[0;32m-> Remove obsolete zabbix source package033[0m"
    sudo rm "${DEST_PATH}"
fi 


echo -e "033[0;32m-> Update the apt package manager033[0m"
sudo apt update

echo -e "033[0;32m-> Install zabbix proxy with sqlite support033[0m"
sudo apt install zabbix-proxy-sqlite3

echo -e "033[0;32m-> Set hostname033[0m"
read -p "Choose a hostname for zabbix proxy: " yn
echo $yn

sed -i 's/DBName=(.*)/DBName=$yn/g' /etc/zabbix/zabbix-proxy

