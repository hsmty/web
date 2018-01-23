---
layout: post
title: "Instalacion de toolchanin para nRF51 en linux"
author: Edén Candelas
---

# Instalacion de toolchain para nRF51 en linux
La razon para este tutorial es la necesidad de utilizar el nRF51822 en un proyecto.
Al momento de escribir esto tengo una tarjeta [Carbon de 96boards] que contiene un nRF51822 con la interface SWD expuesta, y un ST Link V2 a modo de programador.

![stlinkCarbon][imgstlink]


Querer mantener trabajandome en linux me obliga a manejar el toolchain con herramientas abiertas. Lo bueno es que se tiene lo necesario para poder hacer esto:

* GNU arm embedded toolchain provee el compilador y el debugger
* Nordic nRF51_SDK provee las herramientas especificas y codigos para el manejo de los nRF51
* openOCD la herramienta para comunicarnos directamente con el nRF51.

## Instrucciones

### Una carpeta para controlarlos a todos.
Crear una carpeta para trabajar los proyectos con este toolchain: `~$mkdir opt`
eso crea una carpeta en home llamada opt: `/home/<usuario>/opt`

### GNU arm toolchain
* Descargar, descomprimir y poner en la carpeta `opt` el [GNU arm toolchain]
* No se necesita modificar nada del path.

### Nordic nRF51_SDK
* Descargar, descomprimir y poner en la carpeta `opt` el [SDK de nordic para nRF51]
* Se modifica el archivo `/home/<usuario>/opt/<SDK>/componentes/toolchain/gcc/Makefile.posix`. Originalmente contiene la direccion de la instalacion global del arm-none-eabi-gcc, pero queremos usar la que descargamos, asi que lo cambiamos por el path absoluto del GNU arm toolchain

    ~~~~
    GNU_INSTALL_ROOT := /home/<usuario>/opt/gcc-arm-none-eabi-7-2017-q4-major
    GNU_VERSION := 4.9.3
    GNU_PREFIX := arm-none-eabi
    ~~~~

Con esto al momento de ejecutar el comando `make` desde alguno de los ejemplos del SDK  se llama al executable `arm-none-eabi-gcc` contenido en `opt`

### openOCD

* Instalar libusb-1.0
`sudo apt-get install git autoconf libtool make pkg-config libusb-1.0-0 libusb-1.0-0-dev`
libusb debe estar instalado ya que al configurar openocd se valida libusb para activar las configuraciones de los dongles usb

* Descargar, descomprimir [openOCD]
`git clone git://git.code.sf.net/p/openocd/code openocd-code`

* Realizar el proceso de instalacion:
`./bootstrap`
`./configure`
`make`
`sudo make install`

openocd queda instalado en `/usr/local/share/openocd`

## Validacion

### Compilacion de ejemplos.

* Ir a un ejemplo especifico, en este caso: `/home/<usuario>/opt/<SDK>/examples/ble_peripheral/ble_app_beacon/`
* Ir a la carpeta que contine el codigo especifico para la aplicacion. `<>/ble_app_beacon/pca10028/s130/` se escogio este ejemplo ya que es compatible con una tarjeta custom sin elementos extras utilizando el softdevice 130.
* Ejecutamos `make`
* Como resultado al make se crea la carpeta `_build` en la que reciden el `.bin` y el `.hex`. Este .hex es el que usaremos mas tarde para cargarlo a la tarjeta.

### Conexion STLink <-> Carbon
La interface SWD en el carbon tienen los pines: 3.3v - GND - CLK - DIO - RST.
* Conectamos a los pines correspondientes en el conector del stlink v2

                            |   CARBON SWD  |   STLINK V2   |
                            |---------------|---------------|
                            |   3.3v        |   PIN 2       |
                            |   GND         |   PIN 6       |
                            |   CLK         |   PIN 9       |
                            |   DIO         |   PIN 7       |
                            |   RST         |   PIN 15      |
                            |---------------|---------------|

* Alimentamos la Carbon mediante el puerto otg.
* Conectamos el stlink con el cable microusb.

### Iniciamos openocd

Creamos una carpeta para hacer esta prueba y colocar un archivo openocd.cfg  que contenga los parametros que utilizara openocd para la conexion.
* Interface: stlink-v2.cfg
* Target:    nrf51.cfg
* Transport: hla_swd

`$mkdir /home/<usuario>/opt/test`

* Abrimos el archivo `nano openocd.cfg`
* Agregamos el siguiente texto
~~~~
# nRF51822 Target

# Using stlink as SWD programmer
source [find interface/stlink-v2.cfg]

# SWD as transport
transport select hla_swd

# Use nRF51 target
set WORKAREASIZE 0x4000
source [find target/nrf51.cfg]
~~~~

La ventaja del stlink v2 es que ya existe un archivo de configuracion para usarlo como interface y un archivo de configuracion del nrf51 como target.
* Ejecutamos openocd con el archivo que creamos: `openocd -f openocd.cfg`

Nos resulta el verbose de openocd que queda a la espera de conexiones

~~~~
Info : The selected transport took over low-level target control. The results might differ compared to plain JTAG/SWD
adapter speed: 1000 kHz
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Info : Unable to match requested speed 1000 kHz, using 950 kHz
Info : Unable to match requested speed 1000 kHz, using 950 kHz
Info : clock speed 950 kHz
Info : STLINK v2 JTAG v27 API v2 SWIM v6 VID 0x0483 PID 0x3748
Info : using stlink api v2
Info : Target voltage: 3.234714
Info : nrf51.cpu: hardware has 4 breakpoints, 2 watchpoints
Info : Listening on port 3333 for gdb connections
~~~~

## Control y carga de archivos
Con *openocd* corriendo y conectado al target podemos enviar la informacion al dispositivo.
En este caso en particular le cargaremos el softdevice 130 y despues el ble_app_beacon que compilamos.

* Abrimos un telnet al localhost (127.0.0.1) al puerto 4444 `telnet localhost 4444`
~~~~
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Open On-Chip Debugger
>
~~~~
* Reiniciamos y paramos el micro. `reset halt`
~~~~
target halted due to debug-request, current mode: Thread
xPSR: 0xc1000000 pc: 0x000006d0 msp: 0x000007c0
~~~~
* borramos el micro `nrf51 mass_erase`
~~~~
nRF51822-QFAC(build code: A1) 256kB Flash
~~~~
* Cargamos el softdevice `flash write_image erase /home/<usuario>/opt/<sdk>/components/softdevice/s130/hex/s130_nrf51_2.0.1_softdevice.hex`
~~~~
auto erase enabled
Padding image section 0 with 2112 bytes
using fast async flash loader. This is currently supported
only with ST-Link and CMSIS-DAP. If you have issues, add
"set WORKAREASIZE 0" before sourcing nrf51.cfg/nrf52.cfg to disable it
target halted due to breakpoint, current mode: Thread
xPSR: 0x61000000 pc: 0x2000001e msp: 0xfffffffc
wrote 110592 bytes from file /home/eden/opt/nRF5_SDK_12.3.0_d7731ad/components/softdevice/s130/hex/s130_nrf51_2.0.1_softdevice.hex in 4.837066s (22.328 KiB/s)
~~~~
* Cargamos el app `flash write_image erase /home/eden/opt/nRF5_SDK_12.3.0_d7731ad/examples/ble_peripheral/ble_app_beacon/pca10028/s130/armgcc/_build/nrf51422_xxac.hex`
~~~~
auto erase enabled
using fast async flash loader. This is currently supported
only with ST-Link and CMSIS-DAP. If you have issues, add
"set WORKAREASIZE 0" before sourcing nrf51.cfg/nrf52.cfg to disable it
target halted due to breakpoint, current mode: Thread
xPSR: 0x61000000 pc: 0x2000001e msp: 0xfffffffc
wrote 12288 bytes from file /home/eden/opt/nRF5_SDK_12.3.0_d7731ad/examples/ble_peripheral/ble_app_beacon/pca10028/s130/armgcc/_build/nrf51422_xxac.hex in 0.568909s (21.093 KiB/s)
~~~~
* reiniciamos el micro `reset`

Para validar que el firmware funciono abrimos algna app como el nRFConnect y validamos que el beacon este haciendo advertising.

![beacon][imgbeacon]


## Referencias.

Enlaces en los que me base para lograr la implementacion del toolchain.

Muestra la configuracion para un nrf51 vanilla y los comandos para cargar tanto el softdevice como la app
[Enlace 1][https://acassis.wordpress.com/2016/02/25/using-openocd-to-program-a-homebrew-nrf51822-board/]
Muestra tambien el comando para cargar el nrf51 vanilla y algunos errores
[Enlace 2][https://devzone.nordicsemi.com/question/70314/program-bluetooth-for-nrf51822-yunjia-board-with-stlink-v2/]


[GNU arm toolchain]: https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads "ARM-GCC"
[SDK de nordic para nRF51]: https://www.nordicsemi.com/eng/Products/Bluetooth-low-energy/nRF51822#software "nRF51-SDK"
[openOCD]: http://openocd.org/
[96boards]:  https://www.96boards.org/product/carbon/

[imgstlink]: /assets/post_img/nrf51toolchain/stlinkCarbon.jpg "stlink"
[imgbeacon]: /assets/post_img/nrf51toolchain/beacon.jpg "beacon"
