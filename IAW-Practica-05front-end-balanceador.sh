#!/bin/bash

# -------------------------------------------- Balanceador --------------------------------------------
# Configuracion del scritp
# IPs Servidores Apache
IPHTTPSERVER1=172.31.95.155
IPHTTPSERVER2=172.31.26.108
set -x
cp -r /home/ubuntu/IAW-Practica05/* /home/ubuntu/
# Actualizamos la lista de paquetes
apt update
apt upgrade -y
# Instalamos el servidor web Apache 
apt install apache2 -y

# Activamos módulos necesarios en Apache
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_ajp
a2enmod rewrite
a2enmod deflate
a2enmod headers
a2enmod proxy_balancer
a2enmod proxy_connect
a2enmod proxy_html
a2enmod lbmethod_byrequests

# Movemos el archivo de configuración ya modificado previamente
cp 000-default.conf /etc/apache2/sites-enabled/

# Reiniciamos el servicio de Apache
/etc/init.d/apache2 restart

# -------------------------------------------------------------------------------------------------------


