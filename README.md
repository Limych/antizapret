# AntiZapret

Прозрачный обход блокировок для локальной сети.

Мне это решение особенно нравится тем, что оно корректно отрабатывает любой трафик. В том числе и HTTPS. При этом никаких настроек на клиентах делать не надо.

Система отлично работает с роутерами на базе **OPNsense** (на роутерах на базе **pfSense** не проверял, но также должно работать без проблем). Возможно, также будет работать с другими роутерами, т.к. используются только базовые возможности файрвола.

## Установка и настройка

* [Настройка на основе TOR](TOR.md) — *увы, на февраль 2022 года этот метод не работает из-за блокировок TOR в России и отсутствии в плагине для OPNsense поддержки obfs4-мостов.*

* [Настройка на основе WireGuard VPN](WireGuard.md) — *для работы этого метода необходимо иметь сервер WireGuard на внешнем хостинге.* 
