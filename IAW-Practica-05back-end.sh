#!/bin/bash

#Declaración de todas las variables de utilidad
DB_ROOT_PASSWD=root
DB_USU_PASSWD=usuario
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
mysql -u root  <<< "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '$DB_ROOT_PASSWD';"
mysql -u root -p$DB_ROOT_PASSWD <<< "FLUSH PRIVILEGES;"
#Configuramos MySQL para permitir conexiones desde la IP privada de la instancia
sudo sed -i "s/127.0.0.1/$IP_PRIVADA_MYSQL/" /etc/mysql/mysql.conf.d/mysqld.cnf 
#Reiniciamos  MySQL 
systemctl restart mysql

# Clonamos el repositorio
cd /home/ubuntu
rm -rf iaw-practica-lamp 
git clone https://github.com/josejuansanchez/iaw-practica-lamp

# Introducimos la base de tados
mysql -u root -p$DB_ROOT_PASSWD < /home/ubuntu/iaw-practica-lamp/db/database.sql
