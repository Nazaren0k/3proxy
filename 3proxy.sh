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
nserver 8.8.8.8  # DNS-сервер Google
nserver 8.8.4.4  # DNS-сервер Google
nserver 1.1.1.1  # DNS-сервер Cloudflare
nserver 1.0.0.1  # DNS-сервер Cloudflare

nscache 65536  # Размер кэша DNS запросов

timeouts 1 5 30 60 180 1800 15 60  # Таймауты соединений

daemon  # Запуск 3proxy в режиме демона

log /var/log/3proxy/3proxy.log D  # Настройка логирования в файл /var/log/3proxy/3proxy.log
logformat "- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T"  # Формат записей лога

auth strong  # Настройка строгой авторизации

allow * * * 80-88,8080-8088 HTTP  # Разрешение доступа для HTTP портов
allow * * * 443,8443 HTTPS  # Разрешение доступа для HTTPS портов

proxy -p53129 -n -a  # Настройка прокси-сервера с портом 53129 и параметрами -n (без DNS запросов) и -a (аутентификация всех пользователей)
users user:CL:P@ssv0rd  # Добавление пользователей с указанными учетными данными

EOF


# Настройка systemd unit файла 3proxy.service с помощью команды tee
sudo tee <<EOF >/dev/null /etc/systemd/system/3proxy.service
[Unit]
Description=3proxy Proxy Server  # Описание службы 3proxy

[Service]
Type=simple  # Тип службы - simple (простой)
ExecStart=/usr/bin/3proxy /etc/3proxy/3proxy.cfg  # Команда запуска службы
ExecStop=/bin/kill `/usr/bin/pgrep -u proxy3`  # Команда остановки службы
RemainAfterExit=yes  # Сохранение состояния после завершения
Restart=on-failure  # Перезапуск службы в случае ошибки

[Install]
WantedBy=multi-user.target  # Условие активации - multi-user.target (многопользовательский режим)
EOF

# Перезапуск службы 3proxy для применения изменений
systemctl restart 3proxy

# Настройка автозапуска службы 3proxy при старте системы
systemctl enable 3proxy
