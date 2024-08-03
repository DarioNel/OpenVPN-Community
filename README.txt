
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

Enter New CA Key Passphrase:      your_password
Re-Enter New CA Key Passphrase:   your_password

Enter PEM pass phrase:              your_password
Verifying - Enter PEM pass phrase:  your_password


Common Name (eg: your user, host, or server name) [Easy-RSA CA]: OpenVPN-CA  <-- Por ejemplo use este nombre

5- Ingrese un nombre para el servidor: servidor-vpn <-- Por ejemplo use este nombre

6- Cuando apresca este mensaje y tenga el nombre que le difinimos 

Common Name (eg: your user, host, or server name) [servidor-vpn]:"Presionar Enter"

7- Luego pedira una confirmacion escribimos "yes"

Confirm request details: yes

8- Nos pedira la contraseña para el certificado (CA) que definimos en el punto 4

Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key: your_password

9- Una ves finalizado la instalación ingresar al script 

nano install-openvpn.sh

Podemos modificar el puerto si deseamos en las siguientes lineas 96, 247 y 356 en 

# CONFIGURACION DEL SERVIDOR

# Puerto
port 1194 <--- modificamos o dejamos por defecto, linea 96

# CONFIGURACION DEL CLIENTE

remote 123.456.789.10 1194 <---- Ponemos la ip Publica del servidor y el puerto, linea 247

# CONFIGURACION DE FIREALL E IPTABLES

ufw allow 1194/udp <--- modificamos o dejamos por defecto, linea 356

Aca cambiamos el nombre del adaptador de red "eth0" por el nuestro

10- En # CONFIGURACION DEL SERVIDOR linea 110 y 111

cert servidor-vpn.crt <--- si pusimos otro nombre en el punto 5 modificar manteriendo su extension
key servidor-vpn.key  <--- si pusimos otro nombre en el punto 5 modificar manteriendo su extension

salimos y guardamos los cambios.

11 - Dar permisos de ejecución

sudo chmod +x cliente-openvpn.sh

12- Ejecutar el script cliente-openvpn.sh

./cliente-openvpn.sh

14 - Creamos el nombre del cliente 

Ingrese un nombre para el cliente:
cliente <-- Por ejemplo use este nombre

15- Cuando apresca este mensaje y tenga el nombre que le difinimos 

Common Name (eg: your user, host, or server name) [cliente]: "Presionar Enter"

16- Luego pedira una confirmacion escribimos "yes"

Confirm request details: yes

17- Nos pedira la contraseña para el certificado (CA) que definimos en el punto 4

Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key: your_password

18- Volvemos a escribir el nombre del cliente 

Se han copiados los certificados y claves

Ingrese el mismo nombre que creo para cliente:
cliente

19- Vaya al directorio /home/OpenVPN-Clientes

cliente.ovpn <-- Este archivo nos servira para conectarnos al servidor VPN

20- Si estamos en linux  ejecutamos los siguientes comandos

sudo apt install openvpn
sudo apt install openvpn-systemd-resolved

Añadimos las siguientes lineas a este fichero al final del archivo 

nano cliente.ovpn

script-security 2
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE .

16 - Ejecutamos este comando en la terminal

sudo openvpn cliente.ovpn
