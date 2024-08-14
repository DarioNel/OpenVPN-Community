#!/bin/bash

# ACTUALIZACIÓN DEL SISTEMA

# Actualizamos el sistema
apt update && sudo apt upgrade -y

# INSTALACIÓN DEL SERVICIO OPENVPN Y EASEY-RSA

# Instalamos openvpn
apt install openvpn -y

# Instalamos easy-rsa, para los certificados y claves
apt install easy-rsa -y

# Copiamos los archivos easy-rsa a la siguiente ruta /etc/openvpn/ Por si
# una actualizacion borra los certificados y claves en /usr/share/easy-rsa

cp -r /usr/share/easy-rsa /etc/openvpn/

# CREACION DE CERTIFICADOS Y CLAVES PARA (CA)

# Ingresamos a la siguiente ruta para generar la PKI y CA

cd /etc/openvpn/easy-rsa

# Creamos la Infraestructura de Clave Pública (PKI)

./easyrsa init-pki

#ls -lh /etc/openvpn/easy-rsa/pki           ca.crt <------ clave publica
#ls -lh /etc/openvpn/easy-rsa/pki/private   ca.key <-------clave privada

# Creamos la Autoridad de Certificación (CA)

./easyrsa build-ca

# Ingresamos una contraseña para el certificado (CA) que nos servira para
# firmar el servidor y cliente también establecemos un nombre
# [Easy-RSA CA]: OpenVPN-CA    

# CREACION DE CERTIFICADOS Y CLAVES PARA EL SERVIDOR

# Generaremos una clave privada para el servidor (.key)
# y un archivo de solicitud de firma de certificado (CSR).req 

echo "Ingrese un nombre para el servidor:"
read servidor

./easyrsa gen-req $servidor nopass

#req: /etc/openvpn/easy-rsa/pki/reqs/
#key: /etc/openvpn/easy-rsa/pki/private/

#"Presione Enter"

# Firmar el certificado del servidor con la (CA) en modo «server»:

./easyrsa sign-req server $servidor

#"Escriba yes para confirmar"
# Ingresese la contraseña del certificado (CA) para firmalo

# Copiando los cerfificados y claves firmados del servidor.

cp /etc/openvpn/easy-rsa/pki/ca.crt  /etc/openvpn/server/
cp /etc/openvpn/easy-rsa/pki/issued/$servidor.crt /etc/openvpn/server/
cp /etc/openvpn/easy-rsa/pki/private/$servidor.key  /etc/openvpn/server/

# Crear la clave tls-crypt (tls-auth en sistemas antiguos) para obtener una capa de seguridad adicional
# (ta.key)

cd /etc/openvpn/server/

openvpn --genkey secret ta.key

#ls ca.crt  .crt  .key  ta.key

# C

mkdir /etc/openvpn/client/keys

chmod -R 700 /etc/openvpn/client

# CONFIGURACION DEL SERVIDOR

cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server/

echo "" > /etc/openvpn/server/server.conf

serverconf='
# Interfaz de escucha
;local a.b.c.d

# Puerto
port 1194

# Protocolo 
;proto tcp
proto udp

# Tipo de tunel : tun (Enrutamiento IP) o tap (Puente Ehernet)
;dev tap
dev tun
;dev-node MyTap

# Modificar el nombre de las claves por el que hemos creado

ca ca.crt
cert servidor-vpn.crt
key servidor-vpn.key  # This file should be kept secret

# Desactivar la directiva Diffie hellman 

;dh dh2048.pem
dh none

# Topologia de la red (Se recomienda subnet)

topology subnet

# Direcciones de la subred de la vpn (ip=servidor=10.8.0.1) solo para dev tun

server 10.8.0.0 255.255.255.0

# Configuramos para que los clientes tenga la misma ip siempre

ifconfig-pool-persist /var/log/openvpn/ipp.txt

# Configure server mode for ethernet bridging.
# Solo para dev tap
;server-bridge 10.8.0.4 255.255.255.0 10.8.0.50 10.8.0.100
;server-bridge

# Para permitir que los clientes accedan a otras redes privadas detras del servidor

push "route 192.168.0.0 255.255.255.0"
;push "route 192.168.20.0 255.255.255.0"

# Para asignar IPs especificas a los clientes

;client-config-dir ccd
;route 192.168.40.128 255.255.255.248

;client-config-dir ccd
;route 10.9.0.0 255.255.255.252

# (Avanzado) Para crear un script que modifique dinamicamente el firewall si queremos reglas diferentes

;learn-address ./script

# Configurar todos los clientes para redirigir su puerta de elnace del servidor 

push "redirect-gateway def1 bypass-dhcp"

# Configuraciones DNS a los clientes

push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"

# Habilitar la comunicacion entre los clientes

;client-to-client

# Para utilizar las mismas claves con todos los clientes
;duplicate-cn

# Habilitamos para saber si el tunel se ha caido, hace ping cada 10 segundos

keepalive 10 120

# Activamos una clave secreta extra

;tls-auth ta.key 0 # This file is secret
tls-crypt ta.key

# Tipo de cifrado

;cipher AES-256-CBC
cipher AES-256-GCM
auth SHA512

# versions see below)
;compress lz4-v2
;push "compress lz4-v2"

# Compresion
;comp-lzo

# Maximo de clientes simultaneos
max-clients 100

# Permisos de usuarios y grupos , ponemos que no para mayor seguridad

user nobody
group nogroup

# Clave y tunel persistente

persist-key
persist-tun

# Conexiones actuales

status /var/log/openvpn/openvpn-status.log

# Logs, dejamos comentado para usar syslog por defecto

;log         /var/log/openvpn/openvpn.log
;log-append  /var/log/openvpn/openvpn.log

# verbose
verb 3

# Silenciar registros de logs repetidos
;mute 20

# Notificacion de reinicio
explicit-exit-notify 1'

echo "$serverconf" > /etc/openvpn/server/server.conf

# CONFIGURACION DEL CLIENTE

cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client/

echo "" > /etc/openvpn/client/client.conf

clientconf="
# Configuración del cliente

client

# Tipo de tunel : tun (Enrutamiento IP) o tap (Puente Ehernet)

;dev tap
dev tun
;dev-node MyTap

# Protocolo 

;proto tcp
proto udp

# Ip del servidor y el puerto

remote [IP-Publica] 1194
;remote my-server-2 1194

# Conexion aleatoria a los servidores indicados

;remote-random

# Resolucion de nombres infinita

resolv-retry infinite

# Sin asociar puerto o servicio

nobind

# Sin usuario y grupo

user nobody
group nogroup

# Clave y tunel persistentes

persist-key
persist-tun

# Conexion al servidor a traves de un proxy

;http-proxy-retry # retry on connection failures
;http-proxy [proxy server] [proxy port #]

# Silenciar los avisos duplicados

;mute-replay-warnings

# Claves y certificados

;ca ca.crt
;cert client.crt
;key client.key

# Comprovar la identidad del servidor
remote-cert-tls server

# Clave secretea
;tls-auth ta.key 1

# Cifrado

cipher AES-256-GCM
auth SHA512

# Compresion

;comp-lzo

# verbosidad
verb 3

# Silenciar registros de logs repetidos

;mute 20
"
echo "$clientconf" > /etc/openvpn/client/client.conf

# CREACION DE LA PLANTILLA DEL ARCHIVO DE CONFIGURACION DEL CLIENTE, PARA GENERAR CLIENTES.OVPN

cp /etc/openvpn/client/client.conf /etc/openvpn/client/plantilla.conf

mkdir -p /home/$USER/OpenVPN-Clientes

# SCRIPT MAKE_CONFIG PARA CREAR ARCHIVOS OVPN PARA LOS CLIENTES

touch /etc/openvpn/client/make_config.sh

# Borramos el archivo make_config.sh, con un echo vacio.

echo "" > /etc/openvpn/client/make_config.sh

# Creamos una variable donde ponemos las configuraciones en un string
makeconf='
#!/bin/bash

# Frist argument: Client identifier
KEY_DIR=/etc/openvpn/client/keys
OUTPUT_DIR=/home/$USER/OpenVPN-Clientes
BASE_CONFIG=/etc/openvpn/client/plantilla.conf

cat ${BASE_CONFIG} \
    <(echo -e "<ca>") \
    ${KEY_DIR}/ca.crt \
    <(echo -e "</ca>\n<cert>") \
    ${KEY_DIR}/${1}.crt \
    <(echo -e "</cert>\n<key>") \
    ${KEY_DIR}/${1}.key \
    <(echo -e "</key>\n<tls-crypt>") \
    ${KEY_DIR}/ta.key \
    <(echo -e "</tls-crypt>") \
    > ${OUTPUT_DIR}/${1}.ovpn'

# Imprimimos el contenido dentro del archivo make_config con todas las configuraciones.
echo "$makeconf" > /etc/openvpn/client/make_config.sh

cd /etc/openvpn/client/

chmod 700 make_config.sh

# CONFIGURACION DE FIREWALL E IPTABLES

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

echo 1 > /proc/sys/net/ipv4/ip_forward

apt install iptables -y

# Abrimos los puertos en el sistema operativo del servidor

iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -A OUTPUT -p udp --sport 1194 -j ACCEPT

# Aplicamos las reglas para la VPN en el firewall Iptables

iptables -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o enp2s0f5 -j MASQUERADE
iptables -I INPUT 1 -i tun0 -j ACCEPT
iptables -I FORWARD 1 -i enp2s0f5 -o tun0 -j ACCEPT
iptables -I FORWARD 1 -i tun0 -o enp2s0f5 -j ACCEPT
iptables -I INPUT 1 -i enp2s0f5 -p udp --dport 1194 -j ACCEPT

# Habilitar ICMP
iptables -A OUTPUT -o tun0 -p icmp -j ACCEPT 
iptables -A INPUT -i tun0 -p icmp -j ACCEPT 

#iptables -L -nv
#iptables -t nat -L -nv
apt install iptables-persistent -y
netfilter-persistent save
systemctl -f enable openvpn-server@server
service openvpn-server@server restart

#!/bin/bash

#echo "vamos a crear los certificados y claves para un cliente"

# CREACION DE CERTIFICADOS Y CLAVES PARA EL CLIENTE

# Generaremos una clave privada para el cliente (.key)
# y un archivo de solicitud de firma de certificado (CSR).req 

#echo "Ingrese un nombre para el cliente:"
#read cliente

#./easyrsa gen-req $cliente nopass

#req: /etc/openvpn/easy-rsa/pki/reqs/
#key: /etc/openvpn/easy-rsa/pki/private/

#"Presione Enter"

# Firmar el certificado del cliente con la (CA) en modo «client»:

#./easyrsa sign-req client $cliente

#"Escriba yes para confirmar"
# Ingresese la contraseña del certificado (CA) para firmalo

# Copiando los cerfificados y claves firmados del cliente.

#cp /etc/openvpn/easy-rsa/pki/ca.crt  /etc/openvpn/client/keys
#cp /etc/openvpn/easy-rsa/pki/issued/$cliente.crt /etc/openvpn/client/keys
#cp /etc/openvpn/easy-rsa/pki/private/$cliente.key /etc/openvpn/client/keys
#cp /etc/openvpn/server/ta.key /etc/openvpn/client/keys

#echo "Se han copiados los certificados y claves"

# Creando archivo de configuración para cliente

#echo "Ingrese el mismo nombre que creo para cliente:"
#read namecliente

#/etc/openvpn/client/make_config.sh $namecliente

#echo "Vaya a el directorio de su Usuario /home/$USER/OpenVPN-Clientes"
