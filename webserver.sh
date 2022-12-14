#!/bin/bash
sudo yum install -y epel-release && sudo yum install -y nginx mod_ssl vsftpd
sudo rm -rf /etc/vsftpd/*
sudo mkdir /etc/nginx/ssl /etc/vsftpd/users /mnt/backups
echo "root" | sudo tee /etc/vsftpd/chroot_list
echo "root" | sudo tee /etc/vsftpd/user_list
for i in {1,2}; do sudo mkdir /usr/share/nginx/kalyujniy-s$i.local && echo "kalyujniy-s$i test suite" | sudo tee /usr/share/nginx/kalyujniy-s$i.local/index.html; echo -en "server {\n        listen 80;\n        root /usr/share/nginx/kalyujniy-s$i.local;\n        index index.html index.htm;\n        server_name kalyujniy-s$i.local;\n        try_files \$uri \$uri/ = 404;\n}\n\nserver {\n        listen 443 ssl;\n        root /usr/share/nginx/kalyujniy-s$i.local;\n        index index.html index.htm;\n        server_name kalyujniy-s$i.local;\n        ssl_certificate /etc/nginx/ssl/kalyujniy-s$i.crt;\n        ssl_certificate_key /etc/nginx/ssl/kalyujniy-s$i.key;\n        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;\n        ssl_ciphers HIGH:!aNULL:!MD5;\n}\n" | sudo tee /etc/nginx/conf.d/kalyujniy-s$i.local.conf; echo -e "RU\n\nYaroslavl\ntestorg\n\n\n" | openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/nginx/ssl/kalyujniy-s$i.key -out /etc/nginx/ssl/kalyujniy-s$i.crt; sudo useradd -s /sbin/nologin kalyujniy-s$i && echo -e "kalyujniy-s$i\nkalyujniy-s$i" | sudo passwd kalyujniy-s$i; echo "local_root=/usr/share/nginx/kalyujniy-s$i.local/" | sudo tee /etc/vsftpd/users/kalyujniy-s$i; sudo chown -R kalyujniy-s$i. /usr/share/nginx/kalyujniy-s$i.local; echo "kalyujniy-s$i" | sudo tee -a /etc/vsftpd/user_list; done
echo -en "\n# Запуск сервера в режиме службы\nlisten=YES\n# Работа в фоновом режиме\nbackground=YES\n# Имя pam сервиса для vsftpd\npam_service_name=vsftpd\n\n# Запрещает подключение анонимных пользователей\nanonymous_enable=NO\n# Каталог, куда будут попадать анонимные пользователи, если они разрешены\n#anon_root=/ftp\n# Разрешает вход для локальных пользователей\nlocal_enable=YES\n# Разрешены команды на запись и изменение\nwrite_enable=YES\n# Включение специальных ftp команд, некоторые клиенты без этого могут зависать\nasync_abor_enable=YES\n# Локальные пользователи по-умолчанию не могут выходить за пределы своего домашнего каталога\nchroot_local_user=YES\n\nchroot_list_enable=YES\n# Список пользователей, которым разрешен выход из домашнего каталога\nchroot_list_file=/etc/vsftpd/chroot_list\n# Разрешить запись в корень chroot каталога пользователя\nallow_writeable_chroot=YES\n# Контроль доступа к серверу через отдельный список пользователей\nuserlist_enable=YES\n# Файл со списками разрешенных к подключению пользователей\nuserlist_file=/etc/vsftpd/user_list\n# Пользователь будет отклонен, если его нет в user_list\nuserlist_deny=NO\n# Директория с настройками пользователей\nuser_config_dir=/etc/vsftpd/users\n\n# Входящие соединения контроллируются через tcp_wrappers\ntcp_wrappers=YES\n# Указывает исходящим с сервера соединениям использовать 20-й порт\nconnect_from_port_20=YES\n# Порты для пассивного режима работы\npasv_min_port=49000\npasv_max_port=55000\n\n# Логирование всех действий на сервере\nxferlog_enable=YES\n# Путь к лог-файлу\nxferlog_file=/var/log/vsftpd.log\n\n# Показывать файлы, начинающиеся с точки\nforce_dot_files=YES\n# Маска прав доступа к создаваемым файлам\nlocal_umask=022\n\n" | sudo tee /etc/vsftpd/vsftpd.conf
sudo touch /var/log/vsftpd.log && sudo chmod 600 /var/log/vsftpd.log
sudo sed -i '/pam_shells.so/d' /etc/pam.d/vsftpd
sudo systemctl enable nginx --now
sudo systemctl enable vsftpd --now
sudo firewall-cmd --zone=public --permanent --add-service=http --add-service=https --add-service=ftp
sudo firewall-cmd --reload
sudo sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo setenforce 0
sudo hostname web-server
sudo echo web-server > /etc/hostname
echo '*/1 * * * * root /usr/bin/tar -zcf /mnt/backups/kalyujniy-s1-`date +\%d-\%m-\%Y`.tar.gz -P /usr/share/nginx/kalyujniy-s1.local' | sudo tee -a /etc/crontab
echo '*/1 * * * * root /usr/bin/tar -zcf /mnt/backups/kalyujniy-s2-`date +\%d-\%m-\%Y`.tar.gz -P /usr/share/nginx/kalyujniy-s2.local' | sudo tee -a /etc/crontab
#примонтировать папку как на лекции
#надо добавить в fstab
#sudo mount -t nfs 192.168.1.3:/mnt/nfs_shares/backups /mnt/backups

