#!/bin/bash

#Declaración de todas las variables de utilidad
HTTPASSWD_DIR=/home/ubuntu
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario
IP_PRIVADA_MYSQL=172.31.84.134

### Contraseña aleatoria para el parámetro blowfish_secret de nuestro config.inc.php
BLOWFISH=`tr -dc A-Za-z0-9 < /dev/urandom | head -c 64`
# Habilitamos el modo de shell para mostrar los comandos que se ejecutan
set -x
#Actualizamos la lista de paquetes Ubuntu
apt update -y
#Actualizamos los paquetes instalados
apt upgrade -y

#----------------
#INSTALACIÓN PHP |
#----------------
apt install php libapache2-mod-php php-mysql -y
#Creamos el archivo info.php
echo "<?php
phpinfo();
?>" >> /var/www/html/info.php

#---------------------------
#INSTALACIÓN SERVIDOR APACHE|
#---------------------------
apt install apache2 -y

#-------------------
#INSTALACIÓN ADMINER|
#-------------------
#Creamos el directorio de apache donde irá instalado
mkdir /var/www/html/adminer
#Cambiamos al directorio de Adminer
cd /var/www/html/adminer
#Descargamos su repositorio de Github
wget https://github.com/vrana/adminer/releases/download/v4.7.7/adminer-4.7.7-mysql.php
#Movemos el contenido de la aplicación
mv adminer-4.7.7-mysql.php index.php

#-------------------------------
#INSTALACIÓN PAQUETES PHPMYADMIN|
#-------------------------------
#Instalamos los paquetes que necesita phpmyadmin
apt install php-mbstring php-zip php-gd php-json php-curl -y

#--------------------
#INSTALACIÓN GOACCESS| 
#--------------------
echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/goaccess.list
#Descargamos las claves y el certificado 
wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -
#Instalamos GoAccess
apt-get update 
apt-get install goaccess -y

#----------------------------------------
#DIRECTORIO PARA CONSULTA DE ESTADÍSTICAS|
#----------------------------------------
#Creamos un nuevo directorio llamado stats en el directorio de apache
mkdir /var/www/html/stats
#Hacemos que el proceso de GoAccess se ejecute en background y que genere los informes en segundo plano.
nohup goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html &
#Creamos el archivo de contraseñas para el usuario que accederá al directorio stats y lo guardamos en un directorio seguro. 
#En nuestro caso el archivo se va a llamar .htpasswd y se guardará en el directorio /home/usuario. 
#El usuario que vamos a crear tiene como nombre de usuario: usuario.
htpasswd -c -b $HTTPASSWD_DIR/.htpasswd $HTTPASSWD_USER $HTTPASSWD_PASSWD
#Cambiamos la cadena "REPLACE_THIS_PATH" por la ruta de la carpeta del usuario
sed -i 's#REPLACE_THIS_PATH#$HTTPASSWD_DIR#g' $HTTPASSWD_DIR/000-default.conf
#Copiamos el archivo de configuracion de Apache desde el directorio de usuario
cp $HTTPASSWD_DIR/000-default.conf /etc/apache2/sites-available/
#Reiniciamos el servicio Apache
systemctl restart apache2

#----------------------
#INSTALACIÓN PHPMYADMIN|
#----------------------
#Instalamos la utilidad unzip
apt install unzip -y
#Descargamos el código fuente de phpMyAdmin 
cd /home/ubuntu
rm -rf phpMyAdmin-5.0.4-all-languages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip
#Descomprimimos el archivo .zip
unzip phpMyAdmin-5.0.4-all-languages.zip
#Borramos el archivo .zip
rm -rf phpMyAdmin-5.0.4-all-languages.zip
#Movemos el directorio de phyMyAdmin al directorio /var/www/html
mv phpMyAdmin-5.0.4-all-languages/ /var/www/html/phpmyadmin
#Cambiamos al directorio de phpmyadmin para renombrar el archivo de configuración y configurarlo
cd /var/www/html/phpmyadmin
mv config.sample.inc.php config.inc.php
sed -i "s/localhost/$IP_PRIVADA/" /var/www/html/phpmyadmin/config.inc.php
sed -i "s/'blowfish_secret'] = '';/'blowfish_secret'] = '$BLOWFISH';/" /var/www/html/phpmyadmin/config.inc.php


#--------------------------
#INSTALACIÓN APLICACIÓN WEB| 
#--------------------------
# Clonamos el repositorio de la aplicación
cd /var/www/html 
rm -rf iaw-practica-lamp 
git clone https://github.com/josejuansanchez/iaw-practica-lamp

# Movemos el contenido del repositorio al home de html
mv /var/www/html/iaw-practica-lamp/src/*  /var/www/html/

# Configuramos el archivo php de la aplicacion. En https://linuxhint.com/bash_sed_examples/ podemos leer sobre las especificaciones del comando sed y el operador -i, que reemplazarán la línea. Ojo a las comillas, tienen que ser dobles.
sed -i "s/localhost/$IP_PRIVADA/" /var/www/html/config.php

# Eliminamos el archivo Index.html de apache
rm -rf /var/www/html/index.html
rm -rf /var/www/html/iaw-practica-lamp/

# Cambiamos permisos 
chown www-data:www-data * -R
