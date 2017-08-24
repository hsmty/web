---
layout: post
title: "Tunel ssh para RaspberryPi"
author: Edén Candelas
---

#objetivo.
Permitir a un usuario el poder acceder a una raspberry que esta detras de una ip dinamica
la cual no provee algun servicio de nating para accesder a la raspy remotamente.

En nuestro caso requerimosesto para monitorear remotamente que algunos de nuestros
equipos esten en funcionamiento y obtener logs para ver si se comportan como deberian.

Lo que hacemos con un tunnel ssh (especificamente reverse ssh tunnel) es crear una
conexion encriptada desde la raspy al server de manera que esta conexion se inicialice
cuando se enciende la raspy y se reconecte si la conexion se cae. Asi cuando se accese
al server como usuario del tunel podamos tener acceso a la raspberry.


#asumpciones.
* Se tienen una pc/laptop conectada a una red con salida a internet.
* Se tiene una raspberry conenctada a la misma red  que la pc/laptop.
* Se tiene un server accesible publicamente al cual nos podemos conectar por ssh

#Setup usuarios
##preparar usuario para tunel en raspberry

* Habilitar ssh en raspberry.
`$sudo raspy-config`

[imagen raspy-config menu]
[imagen raspy-config opcion]

* Crear usuario para tunel en raspberry
`$sudo adduser usuarioTunel`

[imagen alta-usuario]

* Cambiar a usuarioTunel
`$su usuarioTunel`

* Crear llaves ssh para usuarioTunel

`$ssh-keygen`

* Obtener ip asignada ala raspberry.

`$ifconfig`- Guardar ip asignada ala interface con la que estemos conectados ala red
local.

##preparar usuario para tunel en servidor

* Crear usuario para tunel en server
`$sudo adduser usuarioTunelServer`

[imagen alta-usuario]

* Crear carpeta .ssh

`$su usuarioTunelServer`
`$cd ~`
`$mkdir .ssh `
`$cd .ssh`

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
`$touch .ssh/authorized_keys`

* Copiar contenidos de id_rsa.pub a authorized_keys
`$cat /home/<usuario-server>/id_rsa.pub >> .ssh/authorized_keys`

Con esto debemos tener nuestra llave publica que se creo en la raspberry pi dentro de
la cuenta usuarioTunelServer dentro del servidor.

Para validar esto validamos que el contenido de el archivo .ssh/authorized_keys sea el mismo
en el usuarioTunel de la raspberrypi y el usuarioTunelServer del servidor.

`$cat .ssh/authorized_keys`

#Crear tunel
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
