Uso de nmap.
*Cookbook*
=================================

###Encontrar hosts en la red.

Tipicamente necesitamos saber que otros dispositivos estan conectados en determinada red, posiblemente en la oficina, en la casa o en algun cafe. Una de las razones por las que personalmente hago esto es para encontrar la ip que fue asignada aun a raspberry, de esa forma puedo realizar la configuracion de la misma sin necesidad de un monitor y un teclado, sino accesando remotamente al shell.

'$nmap -sP 192.168.1.0/24'

El comando regresara un listado de los equipos que nmap detecta en la red especificada.

###Saber que puertos/servicios estan disponibles en determinado host

Me ha pasado querer conectarme a un dispositivo a traves de ssh (puerto 22) y este no responde, muchas veces la razon es que el servicio no esta habilitado, para checar esto el siguiente comando apuntando a la ip del dispositivo es util.

'$nmap -sS 192.168.1.254 ' 

El comando regresa un listado con el puerto, estado y el nombre del servicio (si es reconocido)

Otro caso de uso es ver si un servidor web (puerto 80) esta operativo, el comando tmb debe listar si este esta activo  o no.






