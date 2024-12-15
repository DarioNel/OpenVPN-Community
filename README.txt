
Script para instalar OpenVPN Community en Debian y Ubuntu

Fecha: 03/07/2024
Autor: DarioNel

INSTALACIÓN DE OPENVPN


1- Ingresar con permisos privilegiados como usuario Root

sudo su

2- Dar permisos de ejecución

chmod +x install-openvpn.sh

3- Ejecutar el script install-openvpn.sh

./install-openvpn.sh

4- Ingresamos una contraseña para el certificado (CA) que nos servira 
para firmar el servidor y cliente también establecemos un nombre

Enter New CA Key Passphrase:      your_password
Re-Enter New CA Key Passphrase:   your_password

Enter PEM pass phrase:              your_password
Verifying - Enter PEM pass phrase:  your_password


Common Name (eg: your user, host, or server name) [Easy-RSA CA]: OpenVPN-CA  <-- Por ejemplo use este nombre

5- Cuando apresca este mensaje y tenga el nombre que le difinimos 

Common Name (eg: your user, host, or server name) [servidor-vpn]:"Presionar Enter"

6- Luego pedira una confirmacion escribimos "yes"

Confirm request details: yes

7- Nos pedira la contraseña para el certificado (CA) que definimos en el punto 4

Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key: your_password


# CREACION DE ARCHIVOS OVPN PARA LOS CLIENTES 

8 - Dar permisos de ejecución

chmod +x cliente-openvpn.sh

9- Ejecutar el script cliente-openvpn.sh

./cliente-openvpn.sh

Common Name (eg: your user, host, or server name) [cliente]: "Presionar Enter"

10- Luego pedira una confirmacion escribimos "yes"

Confirm request details: yes

11- Nos pedira la contraseña para el certificado (CA) que definimos en el punto 4

Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key: your_password

12- Nos generara una carpeta en nuestro usuario donde tendra los archivos de configuracion

cliente.ovpn <-- Este archivo nos servira para conectarnos al servidor VPN

13- Si estamos en linux  ejecutamos los siguientes comandos

apt install openvpn
apt install openvpn-systemd-resolved

14- Añadimos las siguientes lineas a este fichero al final del archivo 

nano cliente.ovpn

script-security 2
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE 

15 - Ejecutamos este comando en la terminal

sudo openvpn cliente.ovpn
