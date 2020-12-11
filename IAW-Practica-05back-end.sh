#!/bin/bash

#Declaración de todas las variables de utilidad
DB_ROOT_PASSWD=root
IP_PRIVADA_MYSQL=172.31.42.252
#Activamos la depuración del script
set -x
#Actualizamos la lista de paquetes Ubuntu
apt update -y
#Actualizamos los paquetes instalados
apt upgrade -y

#-----------------------
#INSTALACIÓN MySQLSERVER|
#-----------------------
apt install mysql-server -y
#Cambiamos la contraseña root del servidor
mysql -u root <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';"
#Configuramos MySQL para permitir conexiones desde la IP privada de la instancia
sudo sed -i "s/127.0.0.1/$IP_PRIVADA_MYSQL/" /etc/mysql/mysql.conf.d/mysqld.cnf 
#Reiniciamos  MySQL 
systemctl restart mysql

#-------------------------------------------------------
#EJECUTAMOS SCRIPT DE BASE DE DATOS DE LA APLICACIÓN WEB| 
#-------------------------------------------------------
#Vamos al directorio en el que se instalará la aplicación
cd /home/ubuntu
#Ejecutamos este comendo por si la carpeta de la aplicación existe, que sea eliminada
rm -rf iaw-practica-lamp
#Descargamos el repositorio
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git
#Conseguimos el script de creación para la base de datos
mysql -u root -p$DB_ROOT_PASSWD < /home/ubuntu/iaw-practica-lamp/db/database.sql
