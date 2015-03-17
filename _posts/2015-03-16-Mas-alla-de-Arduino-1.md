---
layout: post
title: "Mas allá de Arduino - parte 1"
author: Edén Candelas
---

## Programación de AVR ATtiny desde una Raspberry Pi.

![img1][completo]

Hay un momento en la vida de todo _maker_ en el que madura y empiezan a explorar otras plataformas,
como todo lo que nos ofrece Atmel. Su plataforma AVR es el paso natural a seguir después de Arduino.
Cabe mencionar que todo el _toolchain_ de AVR es _open_ _source_ y podremos utilizarlo desde Linux
en la Raspberry Pi sin chistar.

<!--more-->

Con tantas tecnologías alla afuera,  existe una necesidad natural de ir mas allá de los conocimientos
que se tienen, de forma que se puedan completar mas cosas. Este pensamiento nos ha llevado a explorar
esas otras opciones microcontroladores de la familia AVR, para esta serie de artículos iniciaremos
con el microcontrolador ATtiny85. De este microcontrolador exploraremos sus funciones principales:
I/O, PWM, I2C, SPI e _interrupts_ . Es un micro pequeño en memoria, tamaño y también en costo, sin
embargo esos 8 pines pueden ofrecer mas que suficiente para algunas tareas o el aprendizaje de la
plataforma.

El segundo punto en el que nos adentraremos es utilizar la Raspberry como el medio en el que
escribiremos, compilaremos y cargaremos el software a el microcontrolador, utilizando solo la
terminal y las herramientas que existen en el ecosistema Linux para esta tarea.

La razón de esto son un par de proyectos de los miembros del Hackerspace, en el que Raspberries y
los microcontroladores son la parte principal.


### Requerimientos.

Hardware:

* Raspberry pi (B, B+ o 2 B) con Raspian pre-instalado y configurada para trabajo en linea de comandos.
* Arduino uno con [arduinoISP](http://arduino.cc/en/Tutorial/ArduinoISP) cargado. 
* Microcontrolador AVR ATTiny85
* 20 cables jumper machos.
* 2 leds con resistencias de 220 o 330 ohms
* Resistor 10k ohms.
* Protoboard.

![imgComp][componentes]

Software:

* avr-gcc: Basicamente gcc con las opciones para compilar código especifico para AVRs.
* avrdude: Software para cargar el código maquina al microcontrolador  (ATTiny en este caso).

### Setup.

Comenzaremos por preparar el hardware:

* Conectamos el Arduino a unos de los puertos usb de la raspberry.
* Montamos el AVR al proto y la resistencia de 10k
* Conectamos los cables jumper en la interface ISP, GND y +5v.
* Conectamos los 6 jumpers de la interface ISP al arduino.

<table>
    <thead>
        <tr>
        <td>AVR</td>
        <td></td>
        <td>Arduino</td>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>SCK</td>
            <td>-</td>
            <td>Pin 13</td>
        </tr>
        <tr>
            <td>MISO</td>
            <td>-</td>
            <td>Pin 12</td>
        </tr>
        <tr>
            <td>MOSI</td>
            <td>-</td>
            <td>Pin 11</td>
        </tr>
        <tr>
            <td>RESET</td>
            <td>-</td>
            <td>Pin 10</td>
        </tr>
        <tr>
            <td>VCC</td>
            <td>-</td>
            <td>5V</td>
        </tr>
        <tr>
            <td>GND</td>
            <td>-</td>
            <td>GND</td>
        </tr>
    </tbody>
</table>

* Añadimos un LED con la resistencia a el puerto 4 (pin 3 del ATTiny) y otro al puerto 3 (pin 2 del
ATTiny) para ayudarnos a validar que cargamos bien el software (al finalizar ambos LEDs deben
empezar a parpadear altenadamente).

Aquí un [vine](https://vine.co/v/OV1Qin7JTqr) sobre el armado del sistema.

![img6][armado]

## Software.

Un solo comando instalará en la Raspberry lo necesario para nuestro proposito de desarrollar para AVRs. 
En la terminal de la raspy tecleamos:

`$ sudo apt-get install avrdude avrdude-doc binutils-avr avr-libc gcc-avr gdb-avr`

Una vez terminado de instalar y configurar este software, verificamos que las dos piezas
principales esten listas.

Para ello tecleamos:

`$ avrdude`

Nos debe mostrar la siguiente pantalla, en ella se listan las opciones disponibles y la versión instalada.

![img3][avrdude]

`$ avr-gcc --help`

![img4][avrgcc]

Con esto probamos que tenemos el software para trabajar y podemos probar el _toolchain_ .

### Generación de ejecutable.

_Toolchain_ es el nombre con el que se le conoce a el flujo de trabajo que se
sigue para realizar cierta tarea. En este caso estamos hablando el programador,
microcontrolador, editor, compilador y cargador de software.

**Archivo fuente**

* En _home_ creeamos una carpeta llamada "hello". `$ mkdir hello`
* Nos movemos a la nueva carpeta `$ cd hello`
* Creamos un archivo llamado "hello.c" `$ touch hello.c`
* Accesamos el archivo para editarlo `$ nano hello.c`
 
 
**Para facilitar la prueba copien el siguiente codigo dentro de hello.c**


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


* Guardamos el archivo con Ctrl-O 
* Salimos con Ctrl-x
* Vemos el archivo con `$ ls`

En este momento tenemos en nuestra carpeta de projecto un único archivo
"hello.c".

### Compilación

Obtener el archivo que cargaremos al AVR consiste en tres pasos. 

1. Generar el archivo objeto (*file.o*).
2. Usando el archivo objeto generar el archivo elf (*file.elf*)
3. Extraemos ciertas secciones del archivo _.elf_ para generar el archivo
_.hex_ que es el que cargaremos al AVR.

Procedimiento:

* Invocamos avr-gcc con el siguiente comando:

`$ avr-gcc -g -Os -Wall -DF_CPU=1000000L -mmcu=attiny85 -c hello.c -o hello.o`

    -g produce informacion para el gdb en formato del os. 
    -Os optimiza para el tamaño
    -Wall activa todas las notificaciones
    -DF_CPU asigna la velocidad del reloj interno del attiny
    -mmcu identifica que uC estamos utilizando
    -c es el archivo a compilar
    -o el archivo que generaremos 

*Obtendremos el archivo "hello.o" en nuestro directorio*

* Invocamos de nuevo avr-gcc con el siguiente comando

`$ avr-gcc -g -Os -Wall -DF_CPU=1000000L -mmcu=attiny85 -o hello.elf hello.o`

como veran solo cambiamos el archivo de entrada y salida

*Con ello tendremos el archivo "hello.elf" en el directorio.*

* Extraemos el hello.hex con el comando:

`$ avr-objcopy -j .text -j .data -O ihex hello.elf hello.hex`

    -j .xxxx extrae esa seccion del archivo .elf, asi el comando indica que se extraeran las secciones .text y .data del archivo .elf
    -O determina el tipo de archivo de salida en base al parametro.

*Con ello tendremos el archivo hello.hex, el cual le pasaremos a avrdude para que lo cargue en nuestro avr.*

ahora tendemos los archivos en el directorio.

![img5][archivos]

### Carga de ejecutable

* Cargamos el archivo "hello.hex" al AVR con el comando:

`$ avrdude -p attiny -c avrisp -P /dev/ttyACM0 -b 19200 -U flash:w:hello.hex:i`

    -p es el nombre del microcontrolador 
    -c tipo de programador (arduinoISP funciona como un programador tipo avrisp)
    -P puerto serial asignado al programador (en este caso es ACM0 ya que es una board arduino uno)
    -b velocidad con la que usaremos el puerto (en mi caso 9600 no funciono, por eso lo eleve a 19200)
    -U accion que vamos a realizar con el programador (se puede leer, copiar o borrar el target)

Al ejecutar el comando en la pantalla se mostrara el procedimiento. Al mismo tiempo podemos ver los LEDs del serial de arduino parpadeando y al finalizar la carga los leds conectados al pin 2 y 3 del avr empezaran a parpadear alternadamente.

![img6][carga]

Un [vine](https://vine.co/v/OV127Vlb9PL) sobre la carga del programa.

La imagen muestra el uso de `$ make flash`, en vez del comando directo, 
el próximo artículo hablará de **make** y el uso de **makefiles** para
automatizar el proceso de compilación y carga.*


@elmundoverdees

[componentes]: /assets/post_img/avr/componentes.png "componentes"
[completo]: /assets/post_img/avr/completo.jpg "completo"
[avrdude]: /assets/post_img/avr/avrdude.png "avrdude"
[avrgcc]: /assets/post_img/avr/avrgcc.png "avrgcc"
[archivos]: /assets/post_img/avr/archivos.png "archivos"
[carga]: /assets/post_img/avr/carga.png "carga"
[armado]: /assets/post_img/avr/armado.png "armado"
