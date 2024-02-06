#!/bin/bash

pass="$1"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y openssh-server git sudo figlet bc zsh update-motd curl wget neofetch git zip imagemagick unzip

cd /usr/src || exit

if [ ! -d "/usr/src/motd" ]; then
    git clone https://github.com/fvzy/motd
    ln -s /usr/src/motd/motd.sh /etc/update-motd.d/10-motd
    chmod 777 /usr/src/motd/motd.sh
    cd /etc/update-motd.d/ || exit
    rm -f 50-motd-news 60-unminimize 10-help-text
fi

# Nama file skrip
if [ ! -f /usr/bin/menu ]; then
    cd /usr/local/bin/ || exit
    wget https://raw.githubusercontent.com/fvzy/req/main/menu
    chmod +x /usr/local/bin/menu
fi


if [ ! -f /usr/share/figlet/smblock.tlf ]; then
    cd /usr/share/figlet/ || exit
    wget https://raw.githubusercontent.com/fvzy/motd/main/smblock.tlf
fi

if [ ! -d "/var/run/sshd" ]; then
    echo 'root:$pass' | chpasswd
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
    sed -i 's/^#AllowTcpForwarding yes/AllowTcpForwarding yes/; s/^#PasswordAuthentication yes/PasswordAuthentication yes/; s/^#Port 22/Port 22/' /etc/ssh/sshd_config
    /usr/sbin/sshd -D
fi

# Install Spaceship theme and additional plugins for Zsh
sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -p git \
    -p ssh-agent \
    -t duellj \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

mkdir -p /root/.config
touch /root/.config/motd.legal-displayed
echo 'DONE'
sed -i 's/^.*root:.*$/root:\/bin\/zsh/' /etc/passwd
