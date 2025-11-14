ZABBIX_RELEASE_VERSION="7.4"
UBUNTU_VERSION=$(lsb_release -rs)

echo -e "You are installing the zabbix proxy with sqlite3 support\n"
echo "========="x3
echo "You are using Ubuntu version ${UBUNTU_VERSION}\n"
echo "You are installing the zabbix release ${ZABBIX_RELEASE_VERSION}"
echo "========"x3


ZABBIX_RELEASE="zabbix-release_latest_${ZABBIX_RELEASE_VERSION}+ubuntu${UBUNTU_VERSION}_all"

echo "shell"
echo $ZABBIX_RELEASE
exit

echo "Change shell to root"
sudo -s

echo "Download zabbix version 7.4 source"
wget "https://repo.zabbix.com/zabbix/${UBUNTU_VERSION}/release/ubuntu/pool/main/z/zabbix-release/$ZABBIX_RELEASE.deb"

echo "Install the zabbix source package"
dpkg -i zabbix-release_latest_7.4+ubuntu24.04_all.deb

echo "Update the apt package manager"
apt update

echo "Install zabbix proxy with sqlite support"
apt install zabbix-proxy-sqlite3

rm $

echo "Set hostname"
read -p "Choose a hostname for zabbix proxy " yn
echo $yn

sed -i 's/DBName=(.*)/DBName=$yn/g' /etc/zabbix/zabbix-proxy

