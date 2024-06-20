#!/bin/bash

# Установка и настройка 3proxy
apt update
apt-get install build-essential -y
wget https://github.com/z3APA3A/3proxy/archive/0.9.3.tar.gz
tar xzf 0.9.3.tar.gz
mkdir -p /var/log/3proxy
mkdir /etc/3proxy
cp bin/3proxy /usr/bin/

# Настройка конфигурационного файла 3proxy.cfg с помощью команды tee
sudo tee <<EOF >/dev/null /etc/3proxy/3proxy.cfg
nserver 8.8.8.8
nserver 8.8.4.4
nserver 1.1.1.1
nserver 1.0.0.1

nscache 65536

timeouts 1 5 30 60 180 1800 15 60

daemon

log /var/log/3proxy/3proxy.log D
logformat "- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T"

auth strong

allow * * * 80-88,8080-8088 HTTP
allow * * * 443,8443 HTTPS

proxy -p53129 -n -a
users user:CL:P@ssv0rd

EOF


# Настройка systemd unit файла 3proxy.service с помощью команды tee
sudo tee /etc/systemd/system/3proxy.service <<EOF >/dev/null
[Unit]
Description=3proxy Proxy Server

[Service]
Type=simple
ExecStart=/usr/bin/3proxy /etc/3proxy/3proxy.cfg
ExecStop=/bin/kill \`/usr/bin/pgrep -u proxy3\`
RemainAfterExit=yes
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Перезапуск службы 3proxy для применения изменений
systemctl restart 3proxy

# Настройка автозапуска службы 3proxy при старте системы
systemctl enable 3proxy
