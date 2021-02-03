# AntiZapret

Прозрачный обход блокировок для локальной сети.

Мне это решение особенно нравится тем, что оно корректно отрабатывает любой трафик. В том числе и HTTPS. При этом никаких настроек на клиентах делать не надо.

Система отлично работает с роутерами на базе **OPNsense** (на роутерах на базе **pfSense** не проверял, но также должно работать без проблем). Возможно, также будет работать с другими роутерами, т.к. используются только базовые возможности файрвола.

## Установка и настройка

*NB.* Для настройки системы понадобится доступ к командной строке через консоль или SSH. Все команды надо исполнять от имени **root**, т.к. иначе часть не сработает!

1.  Установите и настройте Tor.

    **Для OPNsense ...**\
    сначала установите плагин `os-tor` через вкладку *System > Firmware > Plugins*. После перейдите на вновь появившуюся вкладку *Services > Tor > Configuration* и настройте его:\
    Включить *Advanced mode* в верхнем левом углу.\
    Включить *Enable*.\
    При желании указать интерфейсы локальной сети в *Listen Interfaces* (надо, если вы планируете использовать Tor как-то ещё; для данного обхода блокировок поле можно оставить пустым)\
    Включить *Enable Transparent Proxy*.
   
    **Для других систем ...**\
    к сожалению, точно описать настройку не могу. Но нужно сделать всё по-аналогии.

1.  Установите этот плагин.

    Самое простое, зайдя в консоль (обязательно как **root**!) исполнить команды
    ```bash
    cd ~
    git clone https://github.com/Limych/antizapret.git
    cd antizapret
    ```

2.  Настройте регулярное обновление списков блокировки.

    **Для OPNsense ...**\
    просто запустите скрипт
    ```bash
    sh opnsense/install.sh
    ```
    После этого в настройках cron (*System > Settings > Cron*) добавить новую задачу на ежесуточное обновление списка:\
    Command = *Renew AntiZapret IP-list*.
   
    **Для других систем ...**\
    необходимо в cron добавить что-то типа
    ```
    0   0   *   *   *   /root/antizapret/antizapret.pl >/usr/local/www/ipfw_antizapret.dat
    ```
    после, чтобы не ждать сутки первого обновления списка, в консоле исполняем команду
    ```
    antizapret.pl >/usr/local/www/ipfw_antizapret.dat
    ```
   
4.  Настройте правила файрвола.

    **Для OPNsense ...**\
    сначала в настройках файрвола на вкладке *Firewall > Aliases* создайте алиас для удобства использования списка.\
    Name = *AntiZapret_IPs*\
    Type = *URL Table (IPs)*\
    Expiration > *Hours = 3*\
    Content = `/usr/local/www/ipfw_antizapret.dat`
    
    Дальше на вкладке *Firewall > NAT > Port Forward* создаём новое правило:\
    Interface = *LAN*\
    Protocol = *TCP*\
    Destination = *AntiZapret_IPs*\
    Destination port range = *any*\
    Redirect target IP = *127.0.0.1* (адрес, где запущен Tor; в данном случае — та же машина)\
    Redirect target port = *9040* (порт, на котором Tor принимает запросы как прозрачный прокси)\
    Description = *Anti-Zapret*
   
    **Для других систем ...**\
    к сожалению, точно описать настройку не могу. Но нужно сделать всё по-аналогии.
    
5.  Всё. :)
    
    Через некоторое время система сама подгрузит список и файрвол начнёт прозрачно перенаправлять любые обращения к заблокированным сайтам на Tor. В то же время весь прочий трафик будет идти напрямую, как обычно.

При необходимости вы всегда можете получать список заблокированных адресов со своего файрволла по адресу `https://<firewall_ip>/ipfw_antizapret.dat`

## Troubleshooting

Если при создании алиаса вы получили сообщение `Invalid argument`, загляните на вкладку *Firewall> Settings> Advanced*, найдите там поле *Firewall Maximum Table Entries* и измените его значение.

Известно, что на текущей версии OPNsense (v21.1) есть явный баг. При значении по-умолчанию мы имеем почему-то лимит в 32 768 адресов (хотя в справке написано, что по-умолчанию он 200 000 записей). Если явно указать там лимит в 200 000 записей, по факту он будет 131 072 записи...
