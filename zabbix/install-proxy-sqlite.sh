echo "Change shell to root"
sudo -s

echo "Download zabbix version 7.4 source"
wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu24.04_all.deb

echo "Install the zabbix source package"
dpkg -i zabbix-release_latest_7.4+ubuntu24.04_all.deb

echo "Update the apt package manager"
apt update

echo "Install zabbix proxy with sqlite support"
apt install zabbix-proxy-sqlite3

echo "Set hostname"
read -p "Choose a hostname for zabbix proxy " yn
echo $yn

sed -i 's/DBName=(.*)/DBName=$yn/g' /etc/zabbix/zabbix-proxy

