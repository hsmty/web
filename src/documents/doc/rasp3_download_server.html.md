---
title: 'Servidor de descargas - RaspberryPi'
---

### Introduccion
---

Para convertir la raspi en un excelente servidor de descargas solo hay que instalar y configurar [Transmission][1].

Transmission cumple con todo lo necesario para ser considerado el mejor cliente de torrents en linux, su consumo de memoria es muy bajo, usa muy poco procesamiento y su uso es muy intuitivo; lo que lo llevo a ser usado por Ubuntu como app default de torrents ademas que compañías comerciales (FON y Belkin) lo utilizan en sus productos y nosotros lo tenemos al alcance de un apt-get install.

La ventaja que presenta para su uso en un server es que trabaja como [daemon][2]; así, mientras la raspi este encendida estará siempre activo, a parte que tiene implementada una práctica interface web desde la cual podemos cargar torrents/magnets, ver su avance, detener la descarga, borrar los torrents. Por sí fuera poco podemos configurar horarios de descarga, velocidades, modo tortuga , puertos, etc.

![webinterface][imgweb]

Además para los amantes de las terminales hay un CLI remoto que lo podremos instalar en nuestra máquina y con el que podremos administrar y operar el transmission sin necesidad de abrir un navegador (hermoso).

![remotecli][imgrem]

### Instalación
---
Ahora lo bueno, como instalarlo y dejarlo operativo.

Partiremos del punto donde ya se tiene una raspberry configurada (acceso por ssh, ip statica y rootfs expandido).

Lo que haremos es ingresar por medio de ssh desde la terminal (o atravez de putty en windows) a la ip que le hayamos asignado a nuesto dispositivo (recuerden que debemos tener los equipos en la misma red).

`$ssh pi@192.168.1.2` _//Utilice el usuario pi (default en la raspi) y la ip que le asigne al equipo._

Debemos ver algo como:

`pi@192.168.1.2$ ` _//Esto indica que ya estamos operando directamente sobre la raspi._

Estando aqui actualizaremos los repositorios con:

`$sudo apt-get update`

Una ves actualizados los repositorios installamos el transmission:

`$sudo apt-get install transmission-daemon` //asi de facil.

![inst1][imginst1]

![inst2][imginst2]


### Set up
---

Ahora crearemos dos folders:

`$mkdir /home/pi/completed`

`$mkdir /home/pi/progress`

Estos folders nos serviran para mantener separados los archivos que estan siendo descargados de los que ya estan completados.

Ahora va la parte tricky del processo, hay que configurar ciertos permisos para que el transmission pueda tener acceso a las carpetas que acabamos de crear. (Eso de los permisos merece un post aparte).

Lo primero que aremos es modificarel usuario que tenemos (en este caso __pi__) para que sea parte del grupo creado por el transmission tras su instalacion:

`$sudo usermod -a -G debian-transmission pi` _// se traduce como modifica el usario pi agregandolo al grupo debian-transmission_

A las carpetas que creamos hay que agregarlas al grupo debian-transmission para que el transmission pueda acceder y guardar los archivos en ellas.

`$sudo chgrp debian-transmission /home/pi/progress`  _//añade el folder /home/pi/progress al grupo transmission_

`$sudo chgrp debian-transmission /home/pi/completed` _//añade el folder /home/pi/completed al grupo transmission_

`$sudo chmod 770 /home/pi/progress` _//dale permisos de todo al usuario y al grupo del folder /home/pi/progress_

`$sudo chmod 770 /home/pi/completed`  _//dale permisos de todo al usuario y al grupo del folder /home/pi/completed_


![permisos][imgperm]


Listos los permisos hay que configurar los algunos parametros del transmission, esto se hace en:

`sudo nano /etc/transmission-daemon/settings.json` _//abre el archivo settings.json en el editor de archivos nano_

![set1][imgset1]

![set2][imgset2]

![set3][imgset3]

![setEnd][imgsetEnd]

Del archivo settings.jason modificaremos los sigueintes parametros:

* download-dir - aqui pondremos el path del folder donde se guardaran las descargas completadas en nuestro caso "/home/pi/completed"
* incomplete-dir - aqui pondremos el path del folder donde se guardaran las descargas en proceso en nuestro caso "/home/pi/progress"
* incomplete-dir-enable - este campo define si queremos utilizar un directorio especial para los archivos que estan en progreso, como si lo usaremos le damos el valor "true"
* rpce-whitelist - este parametro indica que ips pueden conectarse a la interface web, en este caso usamos la red en la que esta instalada la raspi (e.i. "192.168.1.*"). // asterisco indica que las ips desde 192.168.1.0 hasta 192.168.1.255 se podran conectar.

Modificados los parametros guardamos `ctrl-o` y salimos `ctrl-x`, despues de eso recargamos el transmission para que tome las configuraciones. 

`$sudo service transmission-daemon reload` // ojo de usar reload y no restart, ya que restart reinicia los parametros a valores iniciales.

Ya con esto tendremos un servidor de descargas listo para funcionar.

> __Notas__
>
> * Usen la SD de tamaño mas grande disponible ya que se vuelve un problema el sacar los archivos, en otro post explicare como hacer el setting de una unidad externa
>
> * Para accesar a la interface web las credenciales default son transmission:transmission ; si lo queremos modificar hay que cambiar los valores _rpc-password_ y _rpc-username_ en el archivo settings.json

**__@elmundoverdees__**

[1]: http://www.transmissionbt.com/
[2]: http://en.wikipedia.org/wiki/Daemon_(computing)
[imgweb]:
[imgrem]:
[imginst1]: /images/blog/rasp3/inst_transmission.png "Instalacion 1"
[imginst2]: /images/blog/rasp3/inst_transmission_complete.png "Instalacion 2"
[imgperm]: /images/blog/rasp3/permisos.png "Permisos"
[imgset1]: /images/blog/rasp3/setsOri-1.png "Settings 1"
[imgset2]: /images/blog/rasp3/setsOri-2.png "Settings 2"
[imgset3]: /images/blog/rasp3/setsOri-3.png "Settings 3"
[imgsetEnd]: /images/blog/rasp3/setsMod-1.png "Settings Modificados"


