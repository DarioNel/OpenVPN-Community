
Script para instalar OpenVPN Community en Debian y Ubuntu

Fecha: 03/07/2024
Autor: DarioNel

INSTALACIÓN DE OPENVPN

1- Ingresar con permisos privilegiados como usuario Root

sudo su

2- Dar permisos de ejecución

sudo chmod +x install-openvpn.sh

3- Ejecutar el script install-openvpn.sh

./install-openvpn.sh

4- Ingresamos una contraseña para el certificado (CA) que nos servira 
para firmar el servidor y cliente también establecemos un nombre

[Easy-RSA CA]: OpenVPN-CA  <-- Por ejemplo use este nombre

5- Ingrese un nombre para el servidor: servidor-vpn <-- Por ejemplo use este nombre

6- Cuando apresca este mensaje y tenga el nombre que le difinimos 

[seridor-vpn]: "Presionar Enter"

7- Luego pedira una confirmacion escribimos "yes"

8- Nos pedira la contraseña para el certificado (CA) que definimos en el punto 4

9- Una ves finalizado ingresar al script 

nano install-openvpn.sh

Podemos modificar el puerto si deseamos en la linea 96, 247 , 356 en 

# CONFIGURACION DEL SERVIDOR

# Puerto
port 1194

# CONFIGURACION DEL CLIENTE

remote 123.456.789.10 1194 # en la linea 247 ponemos la ip Publica y el puerto

# CONFIGURACION DE FIREALL E IPTABLES

10- En # CONFIGURACION DEL SERVIDOR linea 110 y 111

cert servidor-vpn.crt <--- si pusimos otro nombre en el punto 5 modificar manteriendo su extension
key servidor-vpn.key  <--- si pusimos otro nombre en el punto 5 modificar manteriendo su extension

salimos y guardamos los cambios.

11 - Dar permisos de ejecución

sudo chmod +x cliente-openvpn.sh

12- Ejecutar el script cliente-openvpn.sh

./cliente-openvpn.sh

14 - Creamos el nombre del cliente , ponemos la contraseña del punto 4, confirmamos yes
volvemos a escribir el nombre del cliente y se generara el archivo de configuracion en

/home/OpenVPN-Clientes

cliente.ovpn <-- Este archivo nos servira para conectarnos al servidor.

15- Ejecutar este comando en la terminal 

sudo openvpen cliente.ovpn
