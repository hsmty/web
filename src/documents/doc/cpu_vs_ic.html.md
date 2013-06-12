---
layout: 'default'
title: 'Microprocesado != Microcontrolador'
---

# Microprocesador != Microcontrolador 
## (No es lo mismo decir arduino que raspberrypi)

Frecuentemente se escuchan estos conceptos y muchas veces se utilizan 
indistintamente, pero existen grandes diferencias entre ellos. En estos dias 
tenemos dos plataformas muy conocidas Arduino y Raspberry las cuales manejan 
microcontroladores y microprocesadores respectivamente, y hay quienes comparan 
a las dos directamente cuando sus capacidades y nichos estan muy separados.

Los microcontroladores estan diseñados para tener en un solo chip todo lo 
necesario para funcionar. El target de estos dispositivos son aplicaciones 
dedicadas. Puede tener diferentes configuraciones pero usualmente contienen un 
cpu, manejadores de pines digitales, convertidores análogos/digitales, memoria 
ROM y RAM, timers, reloj internos, puertos seriales y en los mas recientes 
USBs y I/O pins dinámicos.

Una vez cargado el código en un microC solo requiere ser alimentado para que 
el código comience su ejecución, tal es el caso que la versión del hello word 
en el mundo de la electrónica es hacer que un led parpadee y para ello no se 
necesita mas que la alimentaron una resistencia y un led.

Los microprocesadores están diseñados para recibir datos e instrucciones, 
procesarlos y regresar un resultado. Son circuitos especializados para ello. 
Carecen de memoria RAM y ROM, usualmente no tienen entradas digitales ni 
convertidores ADC/DAC o UARTS, por eso se requiere una serie de periféricos 
para ponerse en funcionamiento. Como ventaja su especialización pueden 
realizar operaciones de una alta complejidad, sus perifericos al ser 
especializados tambien son de una alta capacidad.

Estas dos imagenes muestran la arquitectura de ambos dispositivos:

Como se puede ver hay una gran diferencia en estructura la arquitectura ARM (
microP) tiene interfase para datos y mediante ella se comunica al mundo 
exterior, la arquitectura MEGA (microC) se comunica al exterior mediante los 
periféricos embebidos en el mismo diseño del chip.

Otro de los grandes factores es la velocidad, los microP alcanzan velocidades 
de GHz con un standar actual de 800 Mhz a 1 GHz mientras los microC manejan 
velocidades de entre 4 Mhz a 80 MHz como estandar dependiendo de la capacidad.

Por ejemplo a un arduino se le carga un código precompilado en la memoria 
interna del microC, se utiliza una computadora para realizar esa acción, el 
código es enviado a través de una interfaz USB. El raspberry en su lugar corre 
una versión ligera de linux capaz de desplegar un escritorio completo, 
navegador web, servicios de red, etc. 

Actualmente la linea divisora entre ambas plataformas se diluye ya que hay 
microC con gran capacidad de procesamiento y microP con periféricos integrados
, pero aun así cada uno sigue un nicho especifico y se han desarrollado 
technologias alrededor de cada uno de ellos para realizar sus funciones.

Les dejo estos links para que conozcan un poco mas de estas plataformas:

 * http://learn.adafruit.com/category/raspberry-pi
 * https://www.sparkfun.com/tutorials/182

@elmundoverdees
