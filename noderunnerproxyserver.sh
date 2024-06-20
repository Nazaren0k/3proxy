#!/bin/bash

# Обновление пакетов и установка необходимых зависимостей
apt update
apt-get install build-essential -y

# Загрузка и распаковка 3proxy
wget https://github.com/z3APA3A/3proxy/archive/0.9.3.tar.gz
tar xzf 0.9.3.tar.gz
cd 3proxy-*

# Изменение имени в исходном коде
sed -i '1s/^/#define ANONYMOUS 1\n/' ./src/proxy.h

# Компиляция
make -f Makefile.Linux

# Создание каталогов для логов и конфигураций
mkdir -p /var/log/noderunnerproxy
mkdir /etc/noderunnerproxy

# Копирование исполняемого файла
cp bin/3proxy /usr/bin/noderunnerproxy

# Создание конфигурационного файла noderunnerproxy.cfg
sudo tee <<EOF >/dev/null /etc/noderunnerproxy/noderunnerproxy.cfg
nserver 8.8.8.8
nserver 8.8.4.4
nserver 1.1.1.1
nserver 1.0.0.1

nscache 65536
timeouts 1 5 30 60 180 1800 15 60

daemon

log /var/log/noderunnerproxy/noderunnerproxy.log D
logformat "- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T"
rotate 30

auth strong

allow * * * 80-88,8080-8088 HTTP
allow * * * 443,8443 HTTPS

proxy -p53129 -n -a
users user:CL:P@ssv0rd

EOF

# Создание systemd unit файла для noderunnerproxy.service
sudo tee <<EOF >/dev/null /etc/systemd/system/noderunnerproxy.service
[Unit]
Description=Noderunnerproxy Proxy Server

[Service]
Type=simple
ExecStart=/usr/bin/noderunnerproxy /etc/noderunnerproxy/noderunnerproxy.cfg
ExecStop=/bin/kill `/usr/bin/pgrep -u noderunnerproxy`
RemainAfterExit=yes
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Перезапуск сервиса и настройка автозапуска
systemctl restart noderunnerproxy
systemctl enable noderunnerproxy
