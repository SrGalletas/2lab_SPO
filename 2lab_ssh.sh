#!bin/bash
if [[ $EUID -ne 0]]
then
echo "You can't run the script"
exit 1
fi 

case "$1" in
-init
echo "Uninstall if installed vsftpd"
sudo apt purge --auto-remove vsftpd
echo "Install vsftpd"
sudo apt install vsftpd

echo "Autostart"
sudo systemctl start vsftpd
sudo systemctl enable vsftpd

echo "Open port 20 and 21"
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp

echo "Copy default config"
sudo mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/ftp_access_date+$m.conf.backup
sudo touch /etc/vsftpd/vsftpd.conf
echo "Edit config"
sudo sed -i 's/.*local_enable.*/local_enable=YES/' /etc/vsftpd.conf
sudo sed -i 's/.*write_enable.*/write_enable=YES/' /etc/vsftpd.conf
sudo bash -c 'echo "local_root=/home" >> /etc/vsftpd.conf'

echo "Restart vsftpd"
sudo service vsftpd restart

echo "Create group pibd"
sudo groupadd pibd

echo "Read users list and create users"
while read line; do
sudo adduser $line --ingroup pibd --gecos "" -disabled-password
echo "$line:passwrod" | sudo chpasswd
echo "USER: $line CREATED"
done < "./userList.txt";;

-backup)
echo "Copy config"
cp /etc/vsftpd.conf ./;;
esac