#!/bin/sh

ZABBIX_RELEASE_VERSION="7.4"
UBUNTU_VERSION=$(lsb_release -rs)
PACKAGE_NAME="zabbix-release_latest_${ZABBIX_RELEASE_VERSION}+ubuntu${UBUNTU_VERSION}_all.deb"
ZABBIX_REPOSITORY_URL="https://repo.zabbix.com/zabbix/${ZABBIX_RELEASE_VERSION}/release/ubuntu/pool/main/z/zabbix-release/${PACKAGE_NAME}"
ZABBIX_APT_PACKAGE="zabbix-proxy-sqlite3"
ZABBIX_PROXY_CONF="/etc/zabbix/zabbix_proxy.conf"

echo "Start install script"
echo "-> "
echo "-> You are installing zabbix proxy with sqlite3 support"
echo "-> ================================================="
echo "-> You are using Ubuntu version: ${UBUNTU_VERSION}"
echo "-> You are installing the zabbix release: ${ZABBIX_RELEASE_VERSION}"
echo "-> ================================================"
echo "-> Downloading zabbix version ${ZABBIX_RELEASE_VERSION} apt repository"
sudo wget "${ZABBIX_REPOSITORY_URL}" >/dev/null 2>&1
echo "done"
echo "-> Installing the zabbix apt repository package"
sudo dpkg -i "${PACKAGE_NAME}" >/dev/null 2>&1
echo "done"
sudo rm "${PACKAGE_NAME}" >/dev/null 2>&1

echo "-> Update the apt package manager"
sudo apt update >/dev/null 2>&1
echo "done"
if sudo dpkg -s "${ZABBIX_APT_PACKAGE}" | grep -q "install ok installed"; then
    echo "-> Package '$ZABBIX_APT_PACKAGE' is already installed."
    read -p "Try to upgrade the '$ZABBIX_APT_PACKAGE' package? [y/n]: " try
    if [ "$try" = "y" ]; then
      if sudo apt list --upgradable 2>/dev/null | grep -q "$ZABBIX_APT_PACKAGE"; then
          sudo apt upgrade "$ZABBIX_APT_PACKAGE" >/dev/null 2>&1
          echo "-> Package '$ZABBIX_APT_PACKAGE' is succesfully upgraded!"
          sudo apt systemctl restart zabbix-proxy
          echo "-> Successfully restarted zabbix-proxy!"
        else
           echo "-> No upgrade available!"
        fi
    fi
    exit;

else
    echo "-> Package '$ZABBIX_APT_PACKAGE' is NOT installed."
    echo "-> Installing ${ZABBIX_APT_PACKAGE}"
    sudo apt install "${ZABBIX_APT_PACKAGE}" -y > /dev/null 2>&1
    echo "done"
fi

read -p "Configure zabbix-proxy? [y/n]: " answer

if [ "$answer" = "y" ]; then

    echo "-> Set hostname"
    read -p "Choose a hostname for zabbix proxy: " hostname
    read -p "Choose the zabbix server: " server

    sudo sed -i "s/^Hostname=.*$/Hostname=$hostname/g" "${ZABBIX_PROXY_CONF}"
    sudo sed -i "s/^Server=.*$/Server=$server/g" "${ZABBIX_PROXY_CONF}"

    echo "-> Successfully installed ${ZABBIX_APT_PACKAGE}"
    echo "-> Successfully set hostname to '$hostname' in ${ZABBIX_PROXY_CONF}"
    echo "-> Successfully set server address to '$server' in ${ZABBIX_PROXY_CONF}"

    sudo mkdir -p "/var/lib/zabbix-proxy"
    echo "-> Successfully made folder '/var/lib/zabbix-proxy'"
    sudo chown -R zabbix:zabbix /var/lib/zabbix-proxy
    echo "-> Successfully set owner of folder to zabbix"

    sudo sed -i 's/^DBname=.*$/DBname=\/var\/lib\/zabbix-proxy\/database.sqlite3/g' "${ZABBIX_PROXY_CONF}"

    echo "-> Successfully set sqlite3 database to /var/lib/zabbix-proxy/database.sqlite3"
    sudo systemctl enable zabbix-proxy >/dev/null 2>&1
    sudo systemctl restart zabbix-proxy >/dev/null 2>&1
    echo "-> Successfully enabled autostart from boot and started it"
else
  echo ""
fi
echo "-> End script!"
