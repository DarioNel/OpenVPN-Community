
Script para instalar OpenVPN Community en Debian y Ubuntu

Fecha: 03/07/2024
Autor: DarioNel

INSTALACIÓN DE OPENVPN

1- Editar el script 

nano install-openvpn.sh

Podemos modificar el puerto si deseamos 

# CONFIGURACION DEL SERVIDOR

# Puerto
port 1194 <--- modificamos o dejamos por defecto

# CONFIGURACION DEL CLIENTE

remote 123.456.789.10 1194 <---- Ponemos la ip Publica del servidor y el puerto

# CONFIGURACION DE FIREWALL E IPTABLES

Aca cambiamos el nombre del adaptador de red "enp2s0f5" por el nuestro

salimos y guardamos los cambios.

2- Ingresar con permisos privilegiados como usuario Root

sudo su

3- Dar permisos de ejecución

chmod +x install-openvpn.sh

4- Ejecutar el script install-openvpn.sh

./install-openvpn.sh

5- Ingresamos una contraseña para el certificado (CA) que nos servira 
para firmar el servidor y cliente también establecemos un nombre

Enter New CA Key Passphrase:      your_password
Re-Enter New CA Key Passphrase:   your_password

Enter PEM pass phrase:              your_password
Verifying - Enter PEM pass phrase:  your_password


Common Name (eg: your user, host, or server name) [Easy-RSA CA]: OpenVPN-CA  <-- Por ejemplo use este nombre

6- Ingrese un nombre para el servidor: servidor-vpn <-- Por ejemplo use este nombre

7- Cuando apresca este mensaje y tenga el nombre que le difinimos 

Common Name (eg: your user, host, or server name) [servidor-vpn]:"Presionar Enter"

8- Luego pedira una confirmacion escribimos "yes"

Confirm request details: yes

9- Nos pedira la contraseña para el certificado (CA) que definimos en el punto 5

Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key: your_password

10- Terminada la instalacion ingresamos al script de nuevo y modificamos el nombre del certificado y la clave en la configuracion del servidor

cert servidor-vpn.crt <--- si pusimos otro nombre en el punto 5 modificar manteriendo su extension
key servidor-vpn.key  <--- si pusimos otro nombre en el punto 5 modificar manteriendo su extension

salimos y guardamos los cambios.

# CREACION DE ARCHIVOS OVPN PARA LOS CLIENTES 

11 - Dar permisos de ejecución

chmod +x cliente-openvpn.sh

12- Ejecutar el script cliente-openvpn.sh

./cliente-openvpn.sh

14 - Creamos el nombre del cliente 

Ingrese un nombre para el cliente:
cliente <-- Por ejemplo use este nombre

15- Cuando apresca este mensaje y tenga el nombre que le difinimos 

Common Name (eg: your user, host, or server name) [cliente]: "Presionar Enter"

16- Luego pedira una confirmacion escribimos "yes"

Confirm request details: yes

17- Nos pedira la contraseña para el certificado (CA) que definimos en el punto 5

Enter pass phrase for /etc/openvpn/easy-rsa/pki/private/ca.key: your_password

18- Volvemos a escribir el nombre del cliente 

Se han copiados los certificados y claves

Ingrese el mismo nombre que creo para cliente:
cliente

19- Vaya a el directorio de su Usuario /home/$USER/OpenVPN-Clientes

cliente.ovpn <-- Este archivo nos servira para conectarnos al servidor VPN

20- Si estamos en linux  ejecutamos los siguientes comandos

apt install openvpn
apt install openvpn-systemd-resolved

Añadimos las siguientes lineas a este fichero al final del archivo 

nano cliente.ovpn

script-security 2
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE .

16 - Ejecutamos este comando en la terminal

sudo openvpn cliente.ovpn
