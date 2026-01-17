#!/bin/bash

# Comprobar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then 
  echo "Por favor, ejecuta el script con sudo: sudo ./instalar_lamp.sh"
  exit
fi

# Solicitar datos al usuario
read -p "Introduce el nombre del nuevo usuario Administrador de DB: " DB_USER
read -s -p "Introduce la contraseña para $DB_USER: " DB_PASS
echo ""

echo "--- 1. Actualizando sistema ---"
pacman -Syy --noconfirm

echo "--- 2. Instalando Apache ---"
pacman -S apache --noconfirm
systemctl enable httpd
systemctl start httpd

# Crear index de prueba
echo "<html><title>Manjaro</title><body><h2>Apache on Manjaro</h2></body></html>" > /srv/http/index.html

echo "--- 3. Instalando MariaDB (MySQL) ---"
pacman -S mariadb mariadb-clients libmariadbclient --noconfirm
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl enable mysqld
systemctl start mysqld

echo "--- 4. Configurando Usuario Admin DB ---"
mysql -e "GRANT ALL ON *.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

echo "--- 5. Instalando PHP ---"
pacman -S php php-apache --noconfirm

# Configurar httpd.conf para PHP
HTTPD_CONF="/etc/httpd/conf/httpd.conf"
sed -i 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/' $HTTPD_CONF
sed -i 's/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' $HTTPD_CONF

# Agregar módulos PHP al final si no existen
if ! grep -q "php_module" "$HTTPD_CONF"; then
    echo -e "\nLoadModule php_module modules/libphp.so\nAddHandler php-script php\nInclude conf/extra/php_module.conf" >> $HTTPD_CONF
fi

# Crear info.php
echo "<?php phpinfo(); ?>" > /srv/http/info.php

# Activar errores en php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php/php.ini

echo "--- 6. Instalando phpMyAdmin ---"
pacman -S phpmyadmin --noconfirm

# Activar extensiones en php.ini
sed -i 's/;extension=iconv/extension=iconv/' /etc/php/php.ini
sed -i 's/;extension=mysqli/extension=mysqli/' /etc/php/php.ini
sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/' /etc/php/php.ini

# Configurar Apache para phpMyAdmin
PM_CONF="/etc/httpd/conf/extra/phpmyadmin.conf"
echo -e "Alias /phpmyadmin \"/usr/share/webapps/phpMyAdmin\"\n<Directory \"/usr/share/webapps/phpMyAdmin\">\n    DirectoryIndex index.php\n    AllowOverride All\n    Options FollowSymlinks\n    Require all granted\n</Directory>" > $PM_CONF

if ! grep -q "phpmyadmin.conf" "$HTTPD_CONF"; then
    echo "Include conf/extra/phpmyadmin.conf" >> $HTTPD_CONF
fi

echo "--- 7. Reiniciando servicios ---"
systemctl restart mysqld
systemctl restart httpd

echo "--------------------------------------------------"
echo "¡INSTALACIÓN COMPLETADA!"
echo "Localhost: http://localhost"
echo "Info PHP: http://localhost/info.php"
echo "phpMyAdmin: http://localhost/phpmyadmin"
echo "Usuario DB: $DB_USER"
echo "--------------------------------------------------"