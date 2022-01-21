# Установка и запуск web-приложения на локальном web-server

## Получение web-server

**Windows**

Для запуска web-приложения скачай один из http-серверов c сетевого диска _A:\Интернет и сеть\webserver_:
- Apache httpd
- Nginx

Или скачай из [сборки](https://github.com/argustelecom/tasklist_lite/actions/workflows/build.yml) артефакт httpd-2.4-win32-tasklist-lite, в котором находится приложение + httpd для Windows и переходи к пункту настройки httpd.

**Linux**

Если есть доступ в интернет проще установить с помощью менеджера пакетов своей системы.
 
## Apache httpd 2.4
### Настройка

**Windows**

1. Распакуй архив с httpd. Скопируй в свой каталог содержимое Apache24.
2. Из корневого каталога httpd перейди в каталог conf.
3. В конфигурационном файле httpd.conf
- Найди строку с переменной `define SRVROOT "c:/Apache24/"`. Замени на свой путь к каталогу httpd.
- В строке `Listen 80` укажи свой ip адрес и порт, на котором будет доступно web-приложение.
- Сохрани изменения.
4. Заверши настройку
- Если взял артефакт httpd-2.4-win32-tasklist-lite, то переходи к запуску сервера. 
- Скопируй в каталог *[SRVROOT]/htdocs* содержимое:
  - из build/web - если ты собрал проект локально.
  - артефакта web из [сборки](https://github.com/argustelecom/tasklist_lite/actions/workflows/build.yml).

**Linux**

1. Изменение настроек в httpd.conf аналогично п.3 Windows, дополнительно указать в параметре DocumentRoot путь до каталога, в котором будут расположены файлы web-приложения. Например, `DocumentRoot /var/www/`.
2. Создать каталог `mkdir <путь>`, указанный в параметре DocumentRoot. 
3. Назначить владельцем каталога группу и пользователя из под которого работает apache httpd. Команда `sudo chown -R имя_пользователя:имя_группы <путь>`
5. Расположить в каталоге файлы web-приложения.

### Запуск

**Windows**

Запуск httpd выполняется из каталога [SRVROOT]/bin командой в консоли `start httpd` или зажатый shift + двойной клик ЛКМ по httpd.exe.

**Linix**

Запускается как сервис, если установлен через межеджер пакетов. 
Альтенативный пример команды запуска:
```
apachectl -k start
``` 
с указанием пути до конфигурационного файла:
```
/usr/local/apache2/bin/apachectl -f /usr/local/apache2/conf/httpd.conf
```

Дополнительная информация:
- [настройка и запуск httpd на OS Winfows](https://httpd.apache.org/docs/current/platform/windows.html)
- [установка и запуск httpd на OS Linux](https://httpd.apache.org/docs/2.4/install.html)

### Завершить работу

Завершить работу httpd можно закрыв консоль httpd или завершив процесс (в диспетчере задач или командой в терминале, зависит от ОС).

## Nginx
### Настройка

**Windows**

1. Распакуй архив с nginx в свой каталог.
2. Из корневого каталога nginx перейди в каталог conf.
3. В конфигурационном файле nginx.conf
- В структуре http -> server в параметре listen указать порт.
- В параметре server_name указать ip адрес. 
- Сохрани изменения.
4. Скопируй в каталог *nginx_home/htdocs* содержимое:
- из build/web - если ты собрал проект локально.
- из артефакта web из [сборки](https://github.com/argustelecom/tasklist_lite/actions/workflows/build.yml).

### Запуск

Запуск сервера выполнятеся из корневого каталога (nginx_home) командой в консоли `start nginx`.

Дополнительная информация по настройке и запуску nginx на Windows доступна на сайте [Nginx](https://nginx.org/ru/docs/windows.html)

### Завершить работу

Завершить работу nginx можно через диспетчер задач или консоль, найдя id процессов и выполнив их завершение:
- найти процессы командой  `tasklist /fi "imagename eq nginx.exe"`
- завершить процессы командой `taskkill /PID pid_id /F`

TODO: добавить информацию для Linux
