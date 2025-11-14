#!/bin/bash

ZABBIX_RELEASE_VERSION="7.4"
UBUNTU_VERSION=$(lsb_release -rs)
PACKAGE_NAME_SHORT="zabbix-release_latest_${ZABBIX_RELEASE_VERSION}+ubuntu${UBUNTU_VERSION}_all"
PACKAGE_NAME="zabbix-release_latest_${ZABBIX_RELEASE_VERSION}+ubuntu${UBUNTU_VERSION}_all.deb"
ZABBIX_REPOSITORY_URL="https://repo.zabbix.com/zabbix/${ZABBIX_RELEASE_VERSION}/release/ubuntu/pool/main/z/zabbix-release/${PACKAGE_NAME}"
DEST_PATH="/tmp/${PACKAGE_NAME}"
ZABBIX_APT_PACKAGE="zabbix-proxy-sqlite3"
ZABBIX_PROXY_CONF="/etc/zabbix/zabbix_proxy.conf"

echo -e "\033[0;32m-> \033[0m"
echo -e "\033[0;32m-> You are installing zabbix proxy with sqlite3 support\033[0m"
echo -e "\033[0;32m-> =================================================\033[0m"
echo -e "\033[0;32m-> You are using Ubuntu version: ${UBUNTU_VERSION}\033[0m"
echo -e "\033[0;32m-> You are installing the zabbix release: ${ZABBIX_RELEASE_VERSION}\033[0m"
echo -e "\033[0;32m-> ================================================\033[0m"

echo -e "\033[0;32m-> Trying to install latest release\033[0m"
echo -e "\033[0;32m-> Downloading zabbix version ${ZABBIX_RELEASE_VERSION} apt repository\033[0m"
sudo wget -O - "${ZABBIX_REPOSITORY_URL}" | sudo tee "${DEST_PATH}" > /dev/null
echo -e "\033[0;32m-> Install the zabbix source package\033[0m"
sudo dpkg -i "${DEST_PATH}"
echo -e "\033[0;32m-> Remove obsolete zabbix source package\033[0m"
sudo rm "${DEST_PATH}"

echo -e "\033[0;32m-> Update the apt package manager\033[0m"
sudo apt update

if sudo dpkg -s "${ZABBIX_APT_PACKAGE}" | grep -q "install ok installed"; then
    echo "\033[0;32mPackage '$ZABBIX_APT_PACKAGE' is already installed.\033[0m"
    exit;

else
    echo "\033[0;32mPackage '$ZABBIX_APT_PACKAGE' is NOT installed.\033[0m"
    echo "\033[0;32mInstalling ${ZABBIX_APT_PACKAGE}\033[0m"
    sudo apt install "${ZABBIX_APT_PACKAGE}" -y
fi

echo -e "\033[0;32m-> Set hostname\033[0m"
read -p "Choose a hostname for zabbix proxy: \n" hostname

sed -i 's/^Hostname=.*$/Hostname=$hostname/g' "${ZABBIX_PROXY_CONF}"

echo -e "\033[0;32m-> Successfully installed ${ZABBIX_APT_PACKAGE}\033[0m"
echo -e "\033[0;32m-> Successfully set hostname in ${ZABBIX_PROXY_CONF}\033[0m"
sudo systemctl enable zabbix-proxy
sudo systemctl restart zabbix-proxy
echo -e "\033[0;32m-> Successfully enabled autostart from boot and started it\033[0m"
echo -e "\033[0;32m-> End script!\033[0m"
