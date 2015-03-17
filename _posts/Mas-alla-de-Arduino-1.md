---
layout: post
title: "Mas alla de Arduino - parte 1"
author: Edén Candelas
---
##Mas alla de Arduino
###Programacion de AVR attiny desde una raspberry.

![img1][completo]

Hay un momento en la vida de todo maker en el que se madura y se empiezan a explorar otras plataformas.
El explorar lo que nos ofrece ATMEL y su plataforma AVR es el paso natural a seguir despues de arduino.
Cabe mencionar que todo el toolchain es opensource y podremos utilizarlo desde linux/raspberry sin chistar.

<!--more-->

Hay tantas technologias alla afuera, que rebasan nuestra capacidad para poder conocerlas y utilizarlas todas, sin embargo, existe una necesidad natural de ir llendo mas alla de los conocimientos que se tienen, de forma que se puedan completar mas cosas.
Este pensamiento nos ha llevado a manejar directamente los otros microcontroladores de la familia AVR, para esta seria de post iniciaremos con el attiny85.
De este uC exploraremos sus funciones principales: i/o, pwm, i2c, spi e interrupts. Es un micropequeño en memoria, tamaño y tambien en costo, sin embargo, esos 8 pines pueden ofrecer mas que suficiente para algunas tareas o el aprendizaje de la plataforma.

El segundo punto en el que nos adentraremos es utilizar la Raspberry como el medio en el que escribiremos, compilaremos y cargaremos el software a el uC, utilizando solo la terminal y las herramientas que existen en el ecosistema linux para esta tarea.

La razon de esto son un par de proyectos de los miembros del Hackerspace, en el que raspberries y uC son la parte principal.

###Requerimientos.

Hardware.

* Raspberry pi (B, B+ o 2) con raspian preinstalado y configurada para trabajo en linea de comandos.
* Arduino uno con [arduinoISP](http://arduino.cc/en/Tutorial/ArduinoISP) cargado. 
* Microcontrolador avr ATTINY85
* 20 cables jumper machos.
* 2 leds con resistencias de 220 o 330 ohms
* Resistor 10k ohms.
* Protoboard.

![imgComp][componentes]

Software

* avr-gcc. Basicamente gcc con las opciones para compilar codigo especifico para AVRs.
* avrdude. Software para cargar el codigo maquina a los uC (attiny en este caso).

###Setup.

Comenzaremos por preparar el hardware.

* Paso uno conectar el arduino a unos de los puertos usb de la raspberry.
* Montamos el avr al proto y la resistencia de 10k
* Conectamos los cables jumper en la interface isp, asu vez GND y +5v.
* Conectamos los 6 jumpers de la interface isp al arduino.

    AVR - ARDUINO
    * SCK 	- pin 13
    * MISO 	- pin 12
    * MOSI 	- pin 11
    * RESET	- pin 10
    * VCC 	- 5v
    * GND 	- GND

* Añadimos un led con resistencia el puerto 4 (pin 3 del attiny) y otro al puerto 3 (pin 2 del attiny) para ayudarnos a validar que cargamos bien el software (al finalizar ambos leds deben empezar a parpadear altenadamente).

Aquí un [vine](https://vine.co/v/OV1Qin7JTqr) sobre el armado del sistema.

Ahora el software.

Un solo comando instalara en la raspberry lo necesario para nuestro proposito de desarrollo para AVRs. 
En la terminal de la raspy tecleamos:

`$sudo apt-get install avrdude avrdude-doc binutils-avr avr-libc gcc-avr gdb-avr`

una vez terminado de instalar y configurar este software, verificamos que las las dos piezas principales esten listas.
Para ello tecleamos:

`$ avrdude`

Nos debe mostrar la siguiente pantalla, en ella se listan las opciones disponibles y la version instalada.

![img7][avrdudeOptions]

`$ avr-gcc --help`

![img8][avrgccHelp]

Una ves hecho esto podemos probar el toolchain.

###Generacion de ejecutable.

Toolchain es el nombre con el que se le conoce a el flujo de trabajo que se sigue para realizar cierta tarea.
En este caso estamos hablando el programador, uC, editor, compilador y cargador de software.

Procedimento:

* En home creeamos una carpeta llamada hello. `$mkdir hello`
* Nos movemos a la nueva carpeta `$cd hello`
* Creamos un archivo llamado hello.c `$ touch hello.c`
* Accesamos el archivo para editarlo `$ nano hello.c`
 
 
*Para facilitar la prueba copien el siguiente codigo dentro de hello.c*

```
#include <avr/io.h>
#include <util/delay.h>


int main(){
    DDRB |= (1 << PB4);
    DDRB |= (1 << PB3);

    while(1){
        PORTB |= (1 << PB4);
        PORTB &= ~(1 << PB3);
        _delay_ms(500);
        PORTB &= ~(1 << PB4);
        PORTB |= (1 << PB3);
        _delay_ms(500);
    }

    return 0;

}
```

* Guardamos el archivo con Ctrl-O 
* Salimos con Ctrl-x

Al listar el contenido de la carpeta debemos tener algo asi:

![img][Hellols]

*ahora continuaremos con la compilacion.*

Obtener el archivo que cargaremos al avr consiste en tres pasos. 
1. generar el archivo objeto (*file.o*).
2. usando el archivo objeto generar el archivo elf (*file.elf*)
3. extraemos cierts seccions del archivo elf para generar el archivo hex que es el que cargaremos al AVR.

Pasos:

* Invocamos avr-gcc con el siguiente comando:
`avr-gcc -g -Os -Wall -DF_CPU=1000000L -mmcu=attiny85 -c hello.c -o hello.o`

    -g nos habilita 
    -Os 
    -Wall activa todas las notificaciones
    -DF_CPU asigna la velocidad del reloj interno del attiny
    -mmcu identifica que uC estamos utilizando
    -c es el archivo a compilar
    -o el archivo que generaremos 

Obtendremos el archivo hello.o en nuestro directorio

![img][helloObj]

* Invocamos de nuevo avr-gcc con el siguiente comando

`avr-gcc -g -Os -Wall -DF_CPU=1000000L -mmcu=attiny85 -o hello.elf hello.o`

>como veran solo cambiamos el archivo de entrada y salida

Con ello tendremos el archivo hello.elf en el directorio.

![img][helloElf]

* Extraemos el hello.hex con el comando:

`avr-objcopy -j .text -j .data -O ihex hello.elf hello.hex`

    -j .xxxx extrae esa seccion del archivo .elf, asi el comando indica que se extraeran las secciones .text y .data del archivo .elf
    -O determina el tipo de archivo de salida en base al parametro, en este caso [ihex](http://en.wikipedia.org/wiki/Intel_HEX).

Con ello tendremos el archivo hello.hex, el cual le pasaremos a avrdude para que lo cargue en nuestro avr.

###Carga de ejecutable

* Cargamos el archivo hello.hex al AVR con el comando

`avrdude -p attiny -c avrisp -P /dev/ttyACM0 -b 19200 -U flash:w:hello.hex:i`

    -p es el nombre del microcontrolador 
    -c tipo de programador (arduinoISP funciona como un programador tipo avrisp)
    -P puerto serial asignado al programador (en este caso es ACM0 ya que es una board arduino uno)
    -b velocidad con la que usaremos el puerto (en mi caso 9600 no funciono, por eso lo eleve a 19200)
    -U accion que vamos a realizar con el programador (se puede leer, copiar o borrar el target)

Al ejecutar el comando en la pantalla se mostrara el procedimiento. Al mismo tiempo podemos ver los leds del serial de arduino parpadeando y al finalizar la carga los leds conectados al pin 2 y 3 del avr empezaran a parpadear alternadamente.

![img][logCarga]

Un [vine](https://vine.co/v/OV127Vlb9PL) sobre la carga del programa.


[componentes]: /assets/post_img/avr/componentes.png "componentes"
[completo]: /assets/post_img/avr/completo.jpg "completo"




