---
layout: post
title: "Instalación de Arduino y Processing en RPi"
author: Pdw. Alonso C. Monraz
---

#[Arduino](https://www.arduino.cc/) y [Processing](https://processing.org/) en tu [RPi](https://www.raspberrypi.org/)#

**Antes de empezar, ¿Que se necesita?**
	
	- Un raspberryPi (en éste caso se uso el modelo 2 de 1gb)
	- MicroSd de 8gb con Raspbian instalado
	- monitor con entrada hdmi (o que soporte el adaptador a usar)
	- Cable hdmi (en éste caso se usó un adaptador con el otro extremo a dBi)
	- adaptador de corriente para alimentar tu RPi
	- teclado
	- mouse
	- conexión a internet
	- Arduino uno y su cable usb
	
*Teniendo lo anterior estamos listos para empezar...*

----------

----------

## Spoiler-Disclaimer ##

La instalación será por comandos a través de la terminal, aquí se mostraran los comandos necesarios para la instalación de éstas plataformas de desarrollo.


- No nos hacemos responsables de cualquier adicción adquirida durante la instalación o después de.
- Cualquier fallo o duda presente durante la instalación de las dos plataformas es responsabilidad de cada una respectivamente ([Arduino](https://www.arduino.cc/) y [Processing](https://processing.org/)) el brindar soporte y/o facilitar foros para consultas.


----------

----------


## Manos a la obra ##

Es sencillo instalar estas dos plataformas ya proporcionan información detallada del proceso y algunas recomendaciones para tener una mejor experiencia dentro de su plataforma de desarrollo.

Lo primero que haremos es encender nuestro **raspberry** y en el escritorio abriremos una nueva terminal lo siguiente sera instalar el IDE de [Arduino](https://www.arduino.cc/).
	
	#Para instalar el IDE de arduino solo hace falta escribir lo siguiente en la terminal.

	$pi@raspberrypi:~ $ sudo apt-get install arduino

Después de dar "*enter"* mostrará una pregunta de si quieres continuar con la instalación pondremos que si escribiendo una **Y** , seguido daremos "*enter*" y continuará con la instalación hasta terminar (al finalizar sólo permitirá introducir un nuevo comando) .

	#Para instalar el IDE Processing solo debemos escribir lo siguiente en la terminal.

	$pi@raspberrypi:~ $ curl https://processing.org/download/install-arm.sh | sudo sh

Una ves finalizado va a permitir introducir un nuevo comando, ya con esto si lo deseamos solo hacer falta escribir el nombre de la plataforma en la terminal.
	
	$pi@raspberrypi:~ $ arduino
O bien de la misma forma podemos llamar directamente processing.

	$pi@raspberrypi:~ $ processing

*De otra forma podemos ir y abrirla de forma gráfica en el menú desplegable superior izquierdo en el la lista de aplicaciones para programación.*
	
![](http://imgur.com/KVNViGx.png)

![](http://imgur.com/9NvElct.png)


### Para mas información  ###

Para dudas sobre arduino has clic [aquí](https://forum.arduino.cc/).

Para dudas sobre Processing has clic [aquí](https://forum.processing.org/two/).





