#!/bin/bash

# -------------------------------------------- Balanceador --------------------------------------------
# Configuracion del scritp
set -x
# Actualizamos los repositorios
apt update

# Instalamos apache
apt install apache2 -y 

# Habilitamos los módulos de apache para configurarlo como proxy
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

# Aplicamos nuestro archivo default.conf con las funciones de proxy inverso activadas.
cp 000-default.conf /etc/apache2/sites-enabled/

# Reiniciamos apache para que se apliquen los cambios
sudo systemctl restart apache2
