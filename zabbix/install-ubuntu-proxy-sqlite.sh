#!/bin/sh

ZABBIX_RELEASE_VERSION="7.4"
UBUNTU_VERSION=$(lsb_release -rs)
PACKAGE_NAME="zabbix-release_latest_${ZABBIX_RELEASE_VERSION}+ubuntu${UBUNTU_VERSION}_all.deb"
ZABBIX_REPOSITORY_URL="https://repo.zabbix.com/zabbix/${ZABBIX_RELEASE_VERSION}/release/ubuntu/pool/main/z/zabbix-release/${PACKAGE_NAME}"
ZABBIX_APT_PACKAGE="zabbix-proxy-sqlite3"
ZABBIX_PROXY_CONF="/etc/zabbix/zabbix_proxy.conf"

echo "\033[0;32m-> \033[0m"
echo "\033[0;32m-> You are installing zabbix proxy with sqlite3 support\033[0m"
echo "\033[0;32m-> =================================================\033[0m"
echo "\033[0;32m-> You are using Ubuntu version: ${UBUNTU_VERSION}\033[0m"
echo "\033[0;32m-> You are installing the zabbix release: ${ZABBIX_RELEASE_VERSION}\033[0m"
echo "\033[0;32m-> ================================================\033[0m"

echo "\033[0;32m-> Trying to install latest release\033[0m"
echo "\033[0;32m-> Downloading zabbix version ${ZABBIX_RELEASE_VERSION} apt repository\033[0m"
sudo wget "${ZABBIX_REPOSITORY_URL}" >/dev/null 2>&1
echo "done"
echo "\033[0;32m-> Installing the zabbix source package\033[0m"
sudo dpkg -i "${PACKAGE_NAME}" >/dev/null 2>&1
echo "done"
sudo rm "${PACKAGE_NAME}" >/dev/null 2>&1

echo "\033[0;32m-> Update the apt package manager\033[0m"
sudo apt update >/dev/null 2>&1
echo "done"
if sudo dpkg -s "${ZABBIX_APT_PACKAGE}" | grep -q "install ok installed"; then
    echo "\033[0;32m-> Package '$ZABBIX_APT_PACKAGE' is already installed.\033[0m"
    exit;

else
    echo "\033[0;32m-> Package '$ZABBIX_APT_PACKAGE' is NOT installed.\033[0m"
    echo "\033[0;32m-> Installing ${ZABBIX_APT_PACKAGE}\033[0m"
    sudo apt install "${ZABBIX_APT_PACKAGE}" -y > /dev/null 2>&1
    echo "done"
fi

read -p "Configure zabbix-proxy? y/n" answer

if [[ "$answer" == "yes" || "$answer" == "y" ]]; then

    echo "\033[0;32m-> Set hostname\033[0m"
    read -p "Choose a hostname for zabbix proxy " hostname
    read -p "Choose the zabbix server " server

    sudo sed -i 's/^Hostname=.*$/Hostname=$hostname/g' "${ZABBIX_PROXY_CONF}"
    sudo sed -i 's/^Server=.*$/Server=$server/g' "${ZABBIX_PROXY_CONF}"

    echo "\033[0;32m-> Successfully installed ${ZABBIX_APT_PACKAGE}\033[0m"
    echo "\033[0;32m-> Successfully set hostname to '$hostname' in ${ZABBIX_PROXY_CONF}\033[0m"
    echo "\033[0;32m-> Successfully set server address to '$server' in ${ZABBIX_PROXY_CONF}\033[0m"

    sudo mkdir -p "/var/lib/zabbix-proxy"
    echo "\033[0;32m-> Successfully made folder '/var/lib/zabbix-proxy'\033[0m"
    sudo chown -R zabbix:zabbix /var/lib/zabbix-proxy
    echo "\033[0;32m-> Successfully set owner of folder to zabbix\033[0m"

    sudo sed -i 's/^DBname=.*$/DBname=\/var\/lib\/zabbix-proxy\/database.sqlite3/g' "${ZABBIX_PROXY_CONF}"

    echo "\033[0;32m-> Successfully set sqlite3 database to /var/lib/zabbix-proxy/database.sqlite3\033[0m"
    sudo systemctl enable zabbix-proxy >/dev/null 2>&1
    sudo systemctl restart zabbix-proxy >/dev/null 2>&1
    echo "\033[0;32m-> Successfully enabled autostart from boot and started it\033[0m"
else
  echo ""
fi
echo "\033[0;32m-> End script!\033[0m"
