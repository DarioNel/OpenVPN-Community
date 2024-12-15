#!/bin/bash
echo ""
echo "BIENVENIDO VAMOS A CREAR EL ARCHIVO DE CONFIGURACION PARA EL CLIENTE OPENVPN"
echo ""
echo "A CONTINUACIÓN VAMOS A CREAR CERTIFICADOS Y CLAVES PARA EL CLIENTE"
echo ""

while true ; do
    echo ""
    read -p "Ingrese un nombre para el cliente: " c1
    read -p "Repita  el nombre para el cliente: " c2

    if [ "$c1" == "$c2" ]; then
        echo ""
        echo "¿Esta seguro que ha ingresado correnctamente?"
        read -p "Presione -y- para confirmar o cualquier tecla para volver a introducir: " t
        if [ $t == "y" ]; then
            cliente="$c1"
            break
        else
            echo ""
            echo "Volviendo a introducir el nombre para el cliente"
        fi
    else
        echo ""
        echo "Los datos no coinciden, vuelva a intentarlo"
    fi
done
echo ""

# CREACION DE CERTIFICADOS Y CLAVES PARA EL CLIENTE

# Generaremos una clave privada para el cliente (.key)
# y un archivo de solicitud de firma de certificado (CSR).req 

cd /etc/openvpn/easy-rsa

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

/etc/openvpn/client/make_config.sh $cliente

echo "LOS ARCHIVOS DE CONFIGURACIÓN DEL CLIENTE SE ENCUENTRA EN LA CARPETA DE SU USUARIO"
echo "Path /home/tu_usuario/"