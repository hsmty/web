Minicom y como utilizarlo como log - Parte 1.
===================================

Al estar desarrollando embebidos (aka jugando con arduino) nos vemos en la necesidad de estar monitoreando la actividad el puerto serial para recibir mensajes que nos sirvan para determinar que el programa se esta comportando como se espera, o si hay algun problema, tener la informacion suficiente para poder resolverlo.

Lo intrincado surge el hecho que el problema se puede presentar en cualquier momento o necesitamos validar que el desarrollo se mantiene en operacion durante largos periodos de tiempo. En esos casos no se puede tener la computadora siempre conectada y estar mirando la pantalla todo el tiempo esperando a que algo inusual o inesperado ocurra.

Para estas situaciones he encontrado en las raspberries mis mejores aliadas y junto a tmux y minicom las herramientas que me permiten validar el funcionamiento de mis dispositivos. 

En esta serie de entradas les dejo como hacer el setup de una raspberry para utilizarlo como unidad de loggeo remoto e independiente. El toolchain es el siguiente.

+Configura la raspy para que acepte conexiones *ssh*.
+Configura una *ip estatica* en la raspberry.
+Instala *tmux*.
+Instala *minicom*.
+Configura minicom.
+Crea una sesion de tmux dedicada para el logging.
+Inicia el loggeo.

###Configuracion ssh.

Probamos que ssh este corriendo:

'$sudo service ssh status'

debe de aparecer

'[ok] sshd is running' 

Si no es asi hay que habilitarlo, para esto corremos el comando

'$sudo raspi-config'

En el menu vamos a la opcion de ssh server y seleccionamos la opcion enable. 

[link imagenes]

Salimos del raspy-config y reiniciamos. El servicio ssh debe iniciar automaticamente en el boot del sistema. Podemos correr de nuevo 'sudo service ssh status' para validarlo.

###Configuracion ip statica.

Para configurar la ip estatica hay que modificar el archivo */etc/network/interfaces* para hacer que el sistema asigne los parametros de red que queremos.

La informacion que necesitamos para esto es

+La ip que le vamos a asignar al equipo
+La red con la que trabajaremos (va implicita en la ip)
+La mascara de subred con la que se trabaja
+El gateway que nos da salida a redes externas


En este ejemplo utilizare los parametros:

'''
  ip 192.168.100.50
  red 192.168.100.0
  mascara 255.255.255.0
  gateway 192.168.100.1
  broadcast 192.168.100.255

'''

Abrimos con nano el archivo de configuracion.

'$sudo nano /etc/network/interfaces'

y añadimos las siguientes lineas:

'''
iface eth0 inet static
  address 192.168.100.50
  netmask 255.255.255.0
  broadcast 192.168.100.255
  network 192.168.100.0
  gateway 192.168.100.1
'''

guardamos con 'Ctrl + o'

reiniciamos la raspi y mandamos el comando

'$ifconfig'

y tendremos la configuracion ya aplicada.

[link img ifconfig]

###Instalar tmux.

Para instalar tmux basta dar:

'$sudo apt-get install tmux'

Una ves instalado tendremos la posibilidad de tener diferentes paneles dentro de la misma pantalla, cada una siendo una terminal independiente; tambien permite el mantener una serie de ventanas cada una con sus diferentes paneles; y por si fuera poco tambien permite tener varias sesiones, cada una con sus ventanas y sus paneles. Una vista de arbol seria la siguiente:

    +Session 0:
        +Window 0:
            +Panel 0
            +Panel 1
            +Panel 2
        +Window 1
            +Panel 0
            +Panel 1
    +Session 1: 
        +Window 0
            +Panel 0
            +Panel 1

Todo eso se logra con shortcuts en el teclado como los encontrados aqui [link cheat sheet], tengo una breve descripiion de para que opera tumux.












