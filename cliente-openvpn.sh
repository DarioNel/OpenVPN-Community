#!/bin/bash

echo "vamos a crear los certificados y claves para un cliente"

# CREACION DE CERTIFICADOS Y CLAVES PARA EL CLIENTE

# Generaremos una clave privada para el cliente (.key)
# y un archivo de solicitud de firma de certificado (CSR).req 

cd /etc/openvpn/easy-rsa

echo "Ingrese un nombre para el cliente:"
read cliente

./easyrsa gen-req $cliente nopass

#req: /etc/openvpn/easy-rsa/pki/reqs/
#key: /etc/openvpn/easy-rsa/pki/private/

#"Presione Enter"

# Firmar el certificado del cliente con la (CA) en modo «client»:

./easyrsa sign-req client $cliente

#"Escriba yes para confirmar"
# Ingresese la contraseña del certificado (CA) para firmalo

# Copiando los cerfificados y claves firmados del cliente.

cp /etc/openvpn/easy-rsa/pki/ca.crt  /etc/openvpn/client/keys
cp /etc/openvpn/easy-rsa/pki/issued/$cliente.crt /etc/openvpn/client/keys
cp /etc/openvpn/easy-rsa/pki/private/$cliente.key /etc/openvpn/client/keys
cp /etc/openvpn/server/ta.key /etc/openvpn/client/keys

echo "Se han copiados los certificados y claves"

# Creando archivo de configuración para cliente

echo "Ingrese el mismo nombre que creo para cliente:"
read namecliente

/etc/openvpn/client/make_config.sh $namecliente

echo "Vaya al escritorio en /home/$USER/Desktop/OpenVPN-Clientes"