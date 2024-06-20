# Как использовать свой сервер в качестве прокси для антидетект браузера
```
bash <(curl -s https://raw.githubusercontent.com/Nazaren0k/3proxy/main/3proxy.sh)
```
# После установки можете подключать свой браузер к прокси
```
ip = ip сервера
port=53129
user=user
pass=P@ssv0rd
```
# Удалить прокси
```
systemctl stop3proxy
systemctl disable 3proxy
rm -f /etc/systemd/system/3proxy.service
```
