#!/bin/sh

# Modificado para funcionar com o livecd

# Criando um md em memoria ram:
mdconfig -a -t swap -s 5m -u 4
newfs -U md4
mount /dev/md4 /mnt

mkdir /mnt/ssh
cp /etc/ssh/sshd_config /mnt/ssh
sed -i '' 's|^AuthorizedKeysFile|#AuthorizedKeysFile|' /mnt/ssh/sshd_config

# gera as chaves do ssh
# No FreeBSD 11.2 mudou para rsa ecdsa ed25519

OSVERSION=`/sbin/sysctl -n kern.osreldate`
if [ ${OSVERSION} -lt 1102000 ]
then
  echo "PermitRootLogin yes" >> /mnt/ssh/sshd_config
  echo "HostKey /mnt/ssh/ssh_host_key" >> /mnt/ssh/sshd_config
  echo "HostKey /mnt/ssh/ssh_host_rsa_key" >> /mnt/ssh/sshd_config
  echo "HostKey /mnt/ssh/ssh_host_dsa_key" >> /mnt/ssh/sshd_config
  echo "AuthorizedKeysFile /mnt/ssh/authorized_keys2" >> /mnt/ssh/sshd_config

  ssh-keygen -t rsa1 -b 1024 -f /mnt/ssh/ssh_host_key -N ''
  ssh-keygen -t dsa -f /mnt/ssh/ssh_host_dsa_key -N ''
  ssh-keygen -t rsa -f /mnt/ssh/ssh_host_rsa_key -N ''
else
  echo "PermitRootLogin yes" >> /mnt/ssh/sshd_config
  echo "HostKey /mnt/ssh/ssh_host_rsa_key" >> /mnt/ssh/sshd_config
  echo "HostKey /mnt/ssh/ssh_host_ecdsa_key" >> /mnt/ssh/sshd_config
  echo "HostKey /mnt/ssh/ssh_host_ed25519_key" >> /mnt/ssh/sshd_config
  echo "AuthorizedKeysFile /mnt/ssh/authorized_keys2" >> /mnt/ssh/sshd_config

  ssh-keygen -t rsa -f /mnt/ssh/ssh_host_rsa_key -N ''
  ssh-keygen -t ecdsa -f /mnt/ssh/ssh_host_ecdsa_key -N ''
  ssh-keygen -t ed25519 -f /mnt/ssh/ssh_host_ed25519_key -N ''
fi

# hosts autorizados a conectar

cd /mnt/ssh
#fetch http://187.87.129.15/FreeBSD/authorized_keys2
fetch --no-verify-peer https://raw.githubusercontent.com/paulofragoso/freebsd/master/authorized_keys2
cp -p authorized_keys2 authorized_keys

# setup login shell for root

mkdir /mnt/root
echo "setenv PATH '/bin:/sbin:/usr/bin:/usr/sbin:/stand:/mnt2/stand:/mnt2/bin:/mnt2/sbin:/mnt2/usr/bin:/mnt2/usr/sbin'" > /mnt/root/.cshrc
echo "set prompt='Fixit# '" >> /mnt/root/.cshrc

# start sshd, conexoes baseadas em chaves:

# Inicializa o SSHD:
if [ ${OSVERSION} -lt 1102000 ]
then
  /usr/sbin/sshd -f /mnt/ssh/sshd_config -h /mnt/ssh/ssh_host_dsa_key 
else
  /usr/sbin/sshd -f /mnt/ssh/sshd_config -h /mnt/ssh/ssh_host_rsa_key
fi
