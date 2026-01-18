#!/bin/bash

# 1. Verificación de privilegios
# Si el usuario no es root, el script se reiniciará a sí mismo usando sudo
if [ "$EUID" -ne 0 ]; then 
  echo "Este script necesita permisos de administrador. Por favor, introduce tu contraseña:"
  exec sudo "$0" "$@"
fi

# OBTENER EL NOMBRE DEL SISTEMA OPERATIVO DINÁMICAMENTE
# Extraemos el nombre para personalizar el index de prueba (ej. Manjaro, Arch, CachyOS)
OS_NAME=$(grep -w "NAME" /etc/os-release | cut -d '"' -f 2)

# Solicitar datos al usuario para la base de datos
read -p "Introduce el nombre del nuevo usuario Administrador de DB: " DB_USER
read -s -p "Introduce la contraseña para $DB_USER: " DB_PASS
echo ""

echo "--- 1. Actualizando sistema ---"
pacman -Syy --noconfirm

echo "--- 2. Instalando Apache ---"
pacman -S apache --noconfirm
systemctl enable httpd
systemctl start httpd

# APLICAR PERMISOS RECURSIVOS 777 A /srv/http/
echo "Configurando permisos recursivos 777 en /srv/http/..."
chmod -R 777 /srv/http/

# Crear index de prueba DINÁMICO usando el nombre del S.O. detectado
echo "<html><title>$OS_NAME</title><body><h2>Apache on $OS_NAME</h2></body></html>" > /srv/http/index.html

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

if ! grep -q "php_module" "$HTTPD_CONF"; then
    echo -e "\nLoadModule php_module modules/libphp.so\nAddHandler php-script php\nInclude conf/extra/php_module.conf" >> $HTTPD_CONF
fi

# Activar errores y extensiones en php.ini
PHP_INI="/etc/php/php.ini"
sed -i 's/display_errors = Off/display_errors = On/' $PHP_INI
sed -i 's/;extension=iconv/extension=iconv/' $PHP_INI
sed -i 's/;extension=mysqli/extension=mysqli/' $PHP_INI
sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/' $PHP_INI

echo "--- 6. Instalando phpMyAdmin ---"
pacman -S phpmyadmin --noconfirm

PM_CONF="/etc/httpd/conf/extra/phpmyadmin.conf"
echo -e "Alias /phpmyadmin \"/usr/share/webapps/phpMyAdmin\"\n<Directory \"/usr/share/webapps/phpMyAdmin\">\n    DirectoryIndex index.php\n    AllowOverride All\n    Options FollowSymlinks\n    Require all granted\n</Directory>" > $PM_CONF

if ! grep -q "phpmyadmin.conf" "$HTTPD_CONF"; then
    echo "Include conf/extra/phpmyadmin.conf" >> $HTTPD_CONF
fi

echo "--- 7. Reiniciando servicios ---"
systemctl restart mysqld
systemctl restart httpd

echo "--------------------------------------------------"
echo "INSTALACIÓN COMPLETADA EN: $OS_NAME"
echo "Localhost: http://localhost (Apache on $OS_NAME)"
echo "phpMyAdmin: http://localhost/phpmyadmin"
echo "Usuario DB: $DB_USER"
echo "--------------------------------------------------"

# 2. Auto-eliminación de la carpeta del repositorio
# Identifica la ruta donde se encuentra el script actual
REPO_DIR=$(dirname "$(readlink -f "$0")")

echo "Limpiando archivos de instalación en: $REPO_DIR"
# Borrar la carpeta del repositorio y finalizar
rm -rf "$REPO_DIR"