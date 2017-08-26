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

	rpi$ sudo raspy-config

[imagen raspy-config menu]
[imagen raspy-config opcion]

* Crear usuario para el tunel en Raspberry.

	rpi$ sudo adduser tunnel

[imagen alta-usuario]

* Cambiar de usuario a tunnel.

	rpi$ su tunnel

* Crear un par de llaves SSH para el usuario Tunnel.

	rpi$ ssh-keygen

* Obtener la dirección IP asignada a la Raspberry.

	rpi$ ip addr show

Esto desplegara una lista de tus interfaces, busca la dirección IP
como un juego de cuatro números junto la etiqueta 'inet'.

e.g.

	3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc mq state UP group default qlen 1000
	    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
	    inet 192.168.0.2/24 brd 192.168.0.255 scope global wlan1
	    valid_lft forever preferred_lft forever
	    inet6 fe80::c66e:1fff:fe16:49e3/64 scope link
	    valid_lft forever preferred_lft forever

En este caso la dirección sería `192.168.0.2`

## Preparar usuario para túnel en servidor

* Crear usuario para túnel en servidor

	servidor$ sudo adduser tunnel

[imagen alta-usuario]

* Crear carpeta .ssh

	servidor$ su tunnel
	servidor$ cd ~
	servidor$ mkdir .ssh
	servidor$ cd .ssh

## Copiar llave pública al servidor

El par de llaves criptográficas que acabamos de crear nos servirán para poder
conectarnos al servidor desde la Raspberry sin necesidad de tener que ingresar
la contraseña del usuario cada vez que tenemos que conectarnos al él.

* Copiamos la llave pública, id_rsa.pub, de la Raspberry al servidor, utilizando
  nuestra PC como intermediario. Reemplaza <raspberry-ip> con la dirección.

	PC$ scp tunnel@<raspberry-ip>:.ssh/id_rsa.pub raspberry_public_key

* Una vez hecho esto, copiamos la llave al servidor:
	PC$ scp raspberry_public_key tunnel@<servidor>:

* Ingresamos al servidor para colocar la llave pública de la Raspberry en la
  lista de llaves autorizadas para realizar identificar.

	PC$ ssh <servidor>
	servidor$ su tunnel
	servidor$ cat raspberry_public_key >> ~/.ssh/authorized_keys

Con esto debemos tener nuestra llave pública que se creo en la Raspberry Pi
dentro de la cuenta del usuario tunnel dentro del servidor. Para validar que
la llave se haya copiado correctamente,  desplegamos que el contenido del
archivo `~/.ssh/authorized_keys` y verificamos que sea el mismo que generamos
para el usuario tunnel en la Raspberry Pi.

	servidor$ cat ~.ssh/authorized_keys

# Crear túnel

## Probar el comando para el túnel.

* Ingresamos a raspberrypi con el tunnel desde pc/laptop.

	PC$ ssh tunnel@<ip-raspberry>

* Probamos correr manualmente el comando que crea el túnel

	rpi$ ssh -NTC -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=no \
	 -i ~/.ssh/id_rsa -R 12345:localhost:22 tunnel@<servidor>

Si el comando fue bien la terminal se quedara en "stand-by", esperando
conexiones. Se puede agregar la opción `-v` al comando para ver lo
que ocurre con las conexiones, esto nos ayuda en caso de que ocurra un error.

Para probar que realmente tenemos acceso, entramos al servidor y cambiamos de
usuario a "tunnel", con ese usuario activo ejecutamos:

	servidor$ ssh localhost -p 12345

Si todo sale bien nuestro prompt cambia hacia el prompt de nuestra Raspberry Pi:

	rpi$

## Crear servicio de túnel.

Una vez validado el comando de túnel, lo que falta es hacer que se ejecute
cada que la Raspberry Pi se encienda. Para ello usamos __systemd__[4] para
crear un servicio que realice esta tarea.

* Creamos el archivo del servicio

	rpi$ sudo nano /etc/systemd/system/tunnel-service

* Añadimos la siguiente configuración a este archivo

```
[Unit]
Description=SSH Tunnel Service
ConditionPathExists=|/usr/bin
After=network.target

[Service]
User=tunnel
ExecStart=/usr/bin/ssh -NTC -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=no -i %h/.ssh/id_rsa -R 12345:localhost:22 tunnel@<servidor>

RestartSec=3
Restart=always

[Install]
WantedBy=multi-user.target
```

Guardamos el archivo antes de salir (presionando Ctrl-o en Nano).

* Iniciamos el servicio.

	rpi$ sudo systemctl restart tunnel-service

Si el resultado es positivo veremos el siguiente mensaje en pantalla.

[imagen log de systemctl restart]

* Habilitamos al servicio para que se ejecute desde boot.

	rpi$ sudo systemctl enable tunnel-service

# Probar túnel.

Habiendo hecho esto, accedemos con cualquier usuario al servidor y cambiamos
al usuario tunnel. Reiniciamos la Raspberry Pi, una vez reiniciada accedemos
al túnel desde el servidor:

	servidor$ su tunnel
	servidor$ ssh localhost -p 12345

Con ello debemos aparecer en la terminal de nuestra Raspberry Pi.


# Recomendaciones.

* Cambia el nombre de la Raspberry Pi a uno que sea mas especifico a nuestra
aplicación (podemos tener muchas __raspies__ regadas por ahi).

* Asignar una dirección IP estática a la Raspberry, si por alguna razón
estamos en el sitio y tenemos que acceder a la misma nos ahorramos el paso
de buscar la dirección asignada por la red.

* Usar un usuario diferente para cada túnel en el server para una mejor
administración.

* Se puede validar si el túnel esta vivo del lado del servidor si buscamos
por conexiones ssh en modo **LISTEN** `servidor$ netstat -l | grep ssh`
