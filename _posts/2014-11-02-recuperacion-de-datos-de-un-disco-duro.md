---
layout: post
title: 'Recuperacion de datos de un disco duro dañado con Mac OS X 10.10 Yosemite'
author: heronog
---
_¡RING!_

_-¿Bueno?_

_-¡Hola amor! oye, ¿me puedes ayudar? mi computadora no prende, aparece un simbolo de
prohibido en la pantalla y me urge sacar lo de mi C.V. para enviarlo antes de la
entrevista_

<!--more-->

¡Por fin sucedió! ¡Otra vez!!11||!!!unoª!! Se dañó tu disco duro (o el de
tu pareja) justo cuando estabas terminando de rediseñar tu C.V. para una
entrevista importante. Obviamente no tienes un respaldo. _ddrescue_ to the rescue!


##[_Lasciate ogni speranza, voi ch'entrate._](https://www.google.com/?gws_rd=ssl#q=lasciate+ogni+speranza+voi+ch'entrate)

Hay que ser muy claros, desde el principio, __no hay garantía de que se pueda recuperar
la información de un disco dañado__. No con las técnicas que están accesibles
a cualquiera con una computadora y que se mostrarán aqui. Existen métodos avanzados
que utilizan equipo especializado pero son **muy** caros. [Lifehacker tiene un buen artículo sobre recuperación de datos](http://lifehacker.com/5982339/diy-data-recovery-tricks-for-when-your-hard-drive-goes-belly-up)
con mucha información relevante.

##El proceso a grandes rasgos

Afortunadamente el daño del disco no era grave y aproveché para actualizar a un SSD.

En mi caso, la historia se desenvolvió así:

* [_Diagnóstico_](#diagnostico)

  El caso era que la computadora no prendía y ya, para decidir el siguiente paso,
  es necesario hacer un diagnóstico y evaluar si es factible recuperar la información.

* [_Copiar el disco_](#copiar)

  ¡El soporte físico está dañado! pero la información es para siempre.

* [_Diagnóstico de los daños a los datos_](#datos)

  Es de esperarse que si el soporte físico falla, no toda la información podrá
  recuperarse ya que no es posible accederla o las lecturas son erróneas.
  ¿Cuánta información se perdió debido a esta falla?

* [_Preparación para acceder a los datos_](#prep)

  Dependiendo del sistema donde se ejecute la operación, la preparación puede variar.

* [_#win_](#win)

## El diagnóstico {#diagnostico}

Mi novia tiene una macbook, por lo que tuve que sacar el disco y colocarlo en un
adaptador USB-SATA.

El problema que se presentaba era que el sistema de archivos principal estaba dañado y no podia
montarse. El daño físico del disco se hacía evidente por los ruidos que venian de
su interior.

Una vez conectado el disco a otra máquina, tratar de identificar el dispositivo
en el sistema:

~~~~ bash
$ diskutil list
/dev/disk0
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *240.1 GB   disk0
   1:                        EFI EFI                     209.7 MB   disk0s1
   2:                  Apple_HFS FakeRecoverySystem      239.2 GB   disk0s2
   3:                 Apple_Boot Recovery HD             650.0 MB   disk0s3
/dev/disk1
  #:                       TYPE NAME                    SIZE       IDENTIFIER
  0:      GUID_partition_scheme                        *160.0 GB   disk1
  1:                        EFI EFI                     209.7 MB   disk1s1
  2:                  Apple_HFS FakeFailedDisk          159.2 GB   disk1s2
  3:                 Apple_Boot Recovery HD             650.0 MB   disk1s3
~~~~

Aquí se muestra como obtener el identificador o dispositivo que hay que usar
para ejecutar la recuperación.

El disco _/dev/disk1_ es el identificador de todo el disco, mientras _/dev/disk1s2_
es el identificador de la partición que contiene la información. Es importante notar
que la salida de este comando varia entre computadoras, pero es fácil identificar
la partición que queremos recuperar.

Afortunadamente el dispositivo si se reconoce y regresa información completa de
identificación y particiones pero no es posible acceder a los archivos.

__Conclusión:__ Sí hay daño físico. Todo indica que no es extenso.

__Solución:__ Cambiar el disco duro. En este caso compramos un disco SSD nuevo e
instalamos Mac OS X 10.10. Hay que reconfigurar todo el software como
email, dropbox, mensajeria, etc.

##Copiar el disco {#copiar}

El primer paso en la recuperación de información es cambiar el soporte físico donde
se encuentran los datos. Esto se hace haciendo una "copia binaria" del disco duro.

Lo que esto signfica es que hay que pasar la información, bit por bit, en el mismo
orden en el que se encuentran en el soporte dañado a otro distinto.

Si tienes dos discos duros iguales, mucha gente recomienda copiar directo de disco
a disco, esto tiene la ventaja de que la nueva copia puede reconectarse y funcionar
directamente como reemplazo del original.

Si no tienes dos discos iguales, _es necesario contar con espacio libre suficiente
para contener la totalidad del disco a recuperar_.

En este caso: el original era de 160GB y el disco del sistema donde se ejecuto la
recuperación de 240GB, más que suficiente espacio libre para contener la "imagen"
de disco.

Para este proceso necesitamos una herramienta llamada [GNU _ddrescue_](http://www.gnu.org/software/_ddrescue_/)

Para instalarla en Mac OS X hay que instalar [Homebrew](http://brew.sh) lo cual
requiere las utilidades de linea de comandos de XCode:

~~~ bash
xcode-select --install
~~~

Después de esto, hay que seguir el proceso de instalación de [Homebrew](http://brew.sh)

~~~
Ve a la pagina de homebrew http://brew.sh y sigue las instrucciones
~~~

y finalmente, instalar _ddrescue_

~~~~ bash
brew install ddrescue
~~~~

Así armados vamos a leer la partición que nos interesa rescatar y, en orden, copiar
todos los bits a un archivo.

~~~~ bash
$ sudo ddrescue --retrim /dev/disk1s2 recovery.dmg recoverylog
~~~~

Este comando asume que estás en un directorio con suficiente espacio en disco.
Se generan dos archivos: _recovery.dmg_ que es el que contiene los datos y _recoverylog_
que tiene información sobre la recuperación con _ddrescue_.

Debido a que el disco estaba conectado por un adaptador USB, la lectura fue muy
lenta, alrededor de 16 horas para completarla. Afortunadamente _ddrescue_ puede ser
interrumpido y reiniciado. Hay muchas ventajas sobre la estrategia de recuperación
que utiliza _ddrescue_. Para saber mucho más puedes leer su manual [man _ddrescue_](https://www.gnu.org/software/ddrescue/manual/ddrescue_manual.html)

__Conclusión:__ Evitar hacerlo por USB, si se puede, usar una conexión interna a
SATA o eSATA.
__Resultados:__ 16 horas para recuperar 160GB, el log de _ddrescue_ indicaba que no podia
recuperar alrededor de 750KB. 99.54% de recuperación.

## Diagnóstico de los daños a los datos {#datos}

Dieciséis horas después y con un archivo de 160 GB en mi computadora, vamos a tratar de diagnosticar
el daño a los datos. El disco duro podemos guardarlo por si se necesita volver a
correr el proceso. __Desconecta el disco duro en este paso para evitar correr comandos
sobre él__.

En primer lugar, hay que tratar de montar el sistema de archivos. En una Mac un
simple "doble click" debería funcionar en la mayoría de los caso; obviamente
no ocurrió en este.

Después de tratar de reparar el disco usando _Disk Utility_ sin resultados decidí
usar fsck para obtener más información. Pero hay un pequeño detalle en OSX: __fsck__
 __no funciona sobre archivos normales, es necesario usar un dispositivo de bloque__.

Hay que indicar al sistema que vamos a crear un archivo de bloques a partir de un
archivo en el sistema de archivos. ¿Confudido? Yo sí.

~~~ bash
$ hdid -nomount -autofsck recovery.dmg 
/dev/disk1 
~~~

_hdid_ nos regresa el identificador de un archivo de bloques que _fsck_
 puede usar. En este caso: _/dev/disk1_ . Finalmente tratamos de reparar
el sistema de archivos que recuperamos

~~~ bash
$ fsck_hfs -f -y /dev/disk1
~~~

Una vez que este comando termina, si acaso llega a terminar sin errores, podremos
montar el sistema de archivos y leer la información que buscamos.

En mi caso la reparación aún era incompleta. Afortunadamente fue lo suficiente
para obtener los archivos específicos que nos interesaban.

__Conclusión:__ Descubrir que hay que usar _hdid_ con la opción _-nomount_ para
crear un archivo de bloques para el kernel es una verdadera revelación. 

__Solución:__ Escribir un post en el blog para documentar esto.

## Preparación para acceder a los datos {#prep}

Tenemos los datos y ya reparamos el sistema de archivos. Al montar la imagen
de disco con un doble click no es posible aún, la imagen presenta datos perdidos y
otros problemas que evitan su funcionamiento normal. Pero no hay que temer: podemos
montar el sistema de archivos en modo de sólo lectura y acceder la 
información que necesitamos recuperar.

~~~~ bash
$ mkdir /Volumes/Recovery
$ mount_hfs -j -o rdonly /dev/disk1 /Volumes/Recovery/
$ cd /Volumes/Recovery
$ open .
~~~~

## #win {#win}  
__¡BAM!__ se abre una ventana de Finder con los archivos del disco que estaba
dañado. Ahora, a copiarlos a un lugar seguro y preparar una estrategia de respaldos.

_-Amor, ¡ya recuperé tus archivos!_

_-¡Que bueno! ¡Muchas gracias! ¡Eres el mejor!_
