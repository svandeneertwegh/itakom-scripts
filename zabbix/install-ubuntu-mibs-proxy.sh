#!/bin/sh

UBUNTU_VERSION=$(lsb_release -rs)
SNMP_APT_PACKAGE="snmp snmpd snmp-mibs-downloader"
UBUNTU_SNMP_MIBS_PATH="/usr/share/snmp/mibs/"
UBUNTU_SNMP_CONF="/etc/snmp/snmp.conf"

echo "Start install custom mibs on ubuntu with zabbix-proxy"
echo "-> "
echo "-> You are installing custom MIBS support"
echo "-> ================================================="
echo "-> You are using Ubuntu version: ${UBUNTU_VERSION}"
echo "-> ================================================"
echo "-> Update the apt package manager"
sudo apt update >/dev/null 2>&1
echo "-> Installing the mibs-downloader"
sudo apt install "${SNMP_APT_PACKAGE}" -y > /dev/null 2>&1
echo "done"
echo "Location of custom-mibs on this system is:"
echo "${UBUNTU_SNMP_MIBS_PATH}"
echo "Now copying the custom mibs to the above path"
sudo cp -rf custom-mibs/*.txt ${UBUNTU_SNMP_MIBS_PATH}
echo "-> Remove the disabled snmp mibs loader"
sudo sed -i "s/^mibs/# mibs/g" "${UBUNTU_SNMP_CONF}"
echo "Enabled snmp loader"
echo "Restarting proxy and snmp service"
sudo systemctl restart zabbix-proxy snmpd
echo "-> Successfully enabled custom mibs files"
echo "-> End script!"
