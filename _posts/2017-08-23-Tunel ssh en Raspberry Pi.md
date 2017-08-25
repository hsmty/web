---
layout: post
title: "Túnel ssh para RaspberryPi"
author: Edén Candelas
---

# El objetivo.

Acceder a una RaspberryPi[1] que está detrás de una IP dinámica (lo más
común para proveedores de Internet en hogares) sin necesidad de configurar
algún servicio de NATing[2] en el modem y/o router.

Un caso de uso sería monitorear nuestros equipos remotamente, revisando que
su funcionamiento sea el correcto.

Cómo funciona esto es que creamos un túnel inverso (eng. reverse SSH tunel)
utilizando SSH[3], esto crea una conexión encriptada desde la Raspberry Pi
al servidor, la configuramos de tal manera que esta conexión inicie
automáticamente cada que se enciende la máquina, así podemos asegurarnos
que la conexión se reestablesca si se llegase a interrumpir.


# Asumpciones

* Se tiene acceso a un servidor con IP pública y SSH
* Se tiene una PC (Workstation/Desktop/Mac/Laptop).
* Se tiene una Raspberry Pi.
* Se tiene una salida a Internet.
* Se tiene una red local (LAN).
* La PC y Raspberry están conectadas a la LAN.

# Configuración para usuarios
## Preparar usuario para túnel la Raspberry

* Habilitar SSH en raspberry.

	$ sudo raspy-config

[imagen raspy-config menu]
[imagen raspy-config opcion]

* Crear usuario para el tunel en Raspberry.

	$ sudo adduser tunnel

[imagen alta-usuario]

* Cambiar de usuario a tunnel.

	$ su tunnel

* Crear un par de llaves SSH para el usuario Tunnel.

	$ ssh-keygen

* Obtener la dirección IP asignada a la Raspberry.

	$ ip addr show

Esto desplegara una lista de tus interfaces, busca la dirección IP
como un juego de cuatro números junto la etiqueta 'inet'.

e.g.

	4: wlan1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc mq state UP group default qlen 1000
	    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
	    inet 192.168.0.2/24 brd 192.168.0.255 scope global wlan1
	    valid_lft forever preferred_lft forever
	    inet6 fe80::c66e:1fff:fe16:49e3/64 scope link
	    valid_lft forever preferred_lft forever

En este caso la dirección sería `192.168.0.2`

## Preparar usuario para túnel en servidor

* Crear usuario para túnel en server

	$ sudo adduser tunnel

[imagen alta-usuario]

* Crear carpeta .ssh

	$ su tunnel
	$ cd ~
	$ mkdir .ssh
	$ cd .ssh

##Pasar archivo id_rsa.pub de raspberry pi a server y guardar sus contenidos en el archivo authorized_keys.

Existen varias formas de hacer esto, la manera en la que hare esto es mediante scp:

* Copiar el archivo id_rsa.pub desde la raspy a mi laptop.
`$scp usuarioTunel@<ip-raspberry>:/home/usuarioTunel/.ssh/id_rsa.pub /home/<usuario-pc/`

* Una ves ahi copiar el archivo de mi laptop a mi cuenta del server.
`$scp /home/<usuario-pc>/id_rsa.pub <usuario-server>@<ip-server>:/home/<usuario-server>`
 hago esto por que no se creo en mi laptop llaves para el usuarioTunelServer.

* Ingresar a servidor como usuario-server
`$ssh <usuario-server>@<ip-server>`

* Cambiar a usuarioTunelServer.
`$su usuarioTunelServer`
`$cd ~`


* Crear archivo authorized_keys en carpteta .ssh
	$ touch .ssh/authorized_keys

* Copiar contenidos de id_rsa.pub a authorized_keys
	$ cat /home/<usuario-server>/id_rsa.pub >> .ssh/authorized_keys

Con esto debemos tener nuestra llave publica que se creo en la raspberry pi dentro de
la cuenta usuarioTunelServer dentro del servidor.

Para validar esto validamos que el contenido de el archivo .ssh/authorized_keys sea el mismo
en el usuarioTunel de la raspberrypi y el usuarioTunelServer del servidor.

	$ cat .ssh/authorized_keys

# Crear tunel
## Crear y probar comando tunel.

* Ingresar a raspberrypi con el usuarioTunel desde pc/laptop.
`$ssh usuarioTunel@<ip-raspberry>`

* Probar comando para tunel.
`$ssh -NTC -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=no -i /home/usuarioTunel/.ssh/id_rsa -R 12345:localhost:22 usuarioTunelServer@<ip-server>`

Si el comando fue bien la terminal se quedara en stand-by esperando conexiones
Se puede agregar la opcion `-v` para ver lo que ocurre con las conexiones.

Para probar esto accedenmos al server y cambiamos a usuarioTunelServer, con ese usuario
seleccionado ejecutamos
`$ssh localhost -p 12345`

Si todo sale bien nuestro prompt cambia hacia el prompt de nuestra raspberrypi.
`usuarioTunel@raspberrypi$`

## Crear servicio de tunel.

Una ves validado el comando el tunnel lo que falta es hacer que el mismo se inicialice
cada que la raspberrypi realize un boot. Para ello usamos systemd para crear un servicio
que realize esta tarea.

* Crear el archivo del servicio
`$sudo nano /etc/systemd/system/servicio-tunel`

* Añadimos el siguiente texto al archivo.
```
[Unit]
Description=Servicio de tunel ssh
ConditionPathExists=|/usr/bin
After=network.target

[Service]
User=usuarioTunel
ExecStart=/usr/bin/ssh -NTC -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=no -i %h/.ssh/id_rsa -R 12345:localhost:22 usuarioTunelServer@<ip-server>

RestartSec=3
Restart=always

[Install]
WantedBy=multi-user.target
```
Guardamos el archivo antes de salir (Ctrl-o)

* Iniciamos el servicio.
`$sudo systemctl restart servicio-tunel`

Si el resultado es positivo veremos el siguiente log en pantalla

[imagen log de systemctl restart]

* Habilitamos al servicio para que se ejecute desde boot.
`$sudo systemctl enable servicio-tunel`

# Probar tunel.

Con estos pasos realizados accedemos con cualquier usuario al server y cambiamos
al usuarioTunelServer.
Reiniciamos la raspberrypi y una ves reiniciada accedemos al tunel
`usuarioTunelServer@<nombre-server>$ssh localhost -p 12345`

Con ello debemos aparecer en la terminal de nuestra raspberrypi.


# Recomendaciones.
* cambiar el nombre de la raspberrypi a uno que sea mas especifico a nuestra aplicacion
(podemos tener muchas raspies regadas por ahi).
* Asignar ip statica a la raspberrypi (si por alguna razon estamos en el sitio y tenemos
que acceder a la misma nos ahorramos el paso de buscar la ip asignada por la red)
* Usar un usuario diferente para cada tunel en el server para una mejor administracion.
* Se puede validar si el tunel esta vivo del lado del server si buscamos por conexiones
ssh en modo LISTEN
`$netstat -l | grep ssh`
