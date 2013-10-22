#! /usr/bin/env bash

source $(pwd)/samba.info

apt-get install -y samba-common samba
apt-get install expect -y

#### create user information to access smb
if [[ ! `cat /etc/passwd | grep -i $SAMBA_USER` ]]
then
 /usr/sbin/useradd $SAMBA_USER
fi
sed -i 's/set password [[:alnum:]]*/set password '$SAMBA_PW'/' $(pwd)/insert_smb_pass.exp
sed -i 's/set sambauser [[:alnum:]]*/set sambauser '$SAMBA_USER'/' $(pwd)/insert_smb_pass.exp
$(find / -wholename "$(pwd)/insert_smb_pass.exp")

#### create the share folder
if [[ ! -d /$SAMBA_DIR ]]
then
 mkdir -p /$SAMBA_DIR
 chmod 777 /$SAMBA_DIR
 chown $SAMBA_USER.$SAMBA_USER /$SAMBA_DIR
fi

#### configuration for samba.conf file
smb_config="/etc/samba/smb.conf"
echo "[ $SAMBA_DIR ]" >> $smb_config
echo "   comment = $SAMBA_USER Directory" >> $smb_config
echo "   path = /$SAMBA_DIR" >> $smb_config
echo "   guest ok = yes" >> $smb_config
echo "   browseable = yes" >> $smb_config
echo "   read only = no" >> $smb_config
echo "   create mask = 0777" >> $smb_config
echo "   writable = yes" >> $smb_config
echo "   directory mask = 0777" >> $smb_config
echo "   valid users = $SAMBA_USER" >> $smb_config

#### restart the samba
/etc/init.d/smbd stop
/etc/init.d/smbd restart
