---
layout: post
title: "Rpi + Nginx + Uwsgi + Flask  "
author: Pdw. Carlos Salinas
---


#****Como montar una Aplicación Flask en un Servidor Nginx con Uwsgi como intermediario****#
<br>

*Nota: *En este tutorial se esta trabajando con un RaspberryPi(corriendo Raspbian)
y la mayor parte del trabajo se realizo desde una PC con Windows haciendo SSH con PUTTY* *

<br>



Ya que Raspbian cuenta con entorno gráfico resulta sencillo verificar que lo estamos haciendo correctamente pero la idea es que puedas hacerlo sin necesidad de dicho entorno.

Antes de empezar, hay que abrir la terminal.

![](http://imgur.com/tZfhhoz.png)


###  1.  Crear la carpeta para el proyecto  ###

**Recomendaria hacerlo por partes.* *

Comando 1: 
    
     $sudo mkdir /var/www/

![](http://imgur.com/1vam04V.png)


Comando 2: 

    $sudo mkdir /var/www/proyecto/

![](http://imgur.com/9bPvaVg.png)

(Ya tienes la carpeta de tu proyecto).

<br>

### 2. Instalar VirtualEnv (en la carpeta que recién has creado) ###

Para posicionarte en la carpeta que creaste debes usar el siguiente comando:

    $cd /var/www/proyecto/

![](http://i.imgur.com/8sF8o1n.png?1)

**(Así es como se ve cuando estas adentro de la carpeta)*

Una vez dentro de la carpeta puedes seguir por instalar el ambiente virtual con los siguientes comandos:

    $sudo pip install virtualenv
    $sudo virtualenv venv


<br>

### 3. Instalar NginX ###

El comando para instalar Nginx es:

    $sudo apt-get install nginx 


<br>

### 4. Iniciar el servicio de NginX ###

El comando para iniciar el servicio de Nginx es:

    sudo service nginx start

**Nota: Para probar la instalación abrimos el navegador y apuntamos a la IP del server. Si estamos en un sistema local apuntamos a localhost o 127.0.0.1,
Si el server esta bajo un dominio podemos hacer midominio.com o en su defecto la IP publica del server: 45.51.85.126 desde el navegador.* *

Esto es lo que aparecerá:
![](http://imgur.com/mQa6YhK.png)


<br>

### 5. Crear el archivo de Configuración de Nginx ###

La ruta base de los archivos de configuracion de Nginx  es ***/etc/nginx/*** , ahi se interactúa con dos carpetas ***/etc/nginx/sites-available*** y ***/etc/nginx/sites-enabled***.

**sites-available** contiene todos los archivos de configuración para los servers virtuales, puede haber multiples archivos, cada uno con uno o múltiples bloques. De esta forma cada server puede tener su archivo y podemos tener modularidad mediante la creacion de links hacia sites-enable.

**sites-enable** contiene enlaces a los archivos de configuracion en sites-available que queremos que nginx utilice, en caso que queramos quitar alguno borramos el enlace de esta carpeta, pero no es necesario borrarlo desde sites-available.

Para manejar nuestro servidor que servira los request a la aplicacion en flask, crearemos un archivo de configuracion dentro de *sites-available*:

Pero antes vamos a eliminar el archivo de configuración que viene por defecto con este comando: 

    $sudo rm /etc/nginx/sites-enabled/default

Para crear el archivo de configuración del Nginx debes ir a la carpeta **/etc/nginx/sites-available/**

    $cd /etc/nginx/sites-availabe

Después debes crear el archivo de configuración con el siguiente comando:


      $sudo nano config

Ahora tendrás en pantalla la linea donde puedes escribir el código de configuración que es es el siguiente:


    server {
    	listen 80;
    	server_name localhost;
    
    	location / {
    	include uwsgi_params;
    	uwsgi_pass unix:/var/www/proyecto/myapp.sock;
    	}
    
    } 


Puedes guardar el archivo presionando `ctrl + o`, hay que nombrar el archivo como flaskServer o config dependiendo el caso.

Ahora debes hacer el enlace del archivo de sites-available a sites-enabled con el siguiente comando: 

    $sudo ln -s /etc/nginx/sites-available/config /etc/nginx/sites-enabled/config



<br>
### 6. Instalando Uwsgi  ###

Para usar Uwsgi debes tener instalados lo siguientes componentes de Python:

    $sudo apt-get install build-essential python-dev

    $sudo apt-get install uwsgi-plugin-python

También debes activar el ambiente virtual y para esto debes estar en la carpeta **/var/www/proyecto** porque ahí es donde esta instalado el ambiente virtual si seguiste los pasos anteriores.

    $cd /var/www/proyecto
Una vez dentro de la carpeta podemos activar el ambiente virtual con el siguiente comando:

    $source venv/bin/activate

Ahora podrás ver (venv) en la linea de comando, así: 

![](http://imgur.com/SjLpBGW.png)

Ahora puedes instalar Uwsgi dentro del ambiente virtual

    $sudo pip install uwsgi

<br>

### 7.  Prueba de Uwsgi  ###

Para probar el Uwsgi puedes crear el siguiente archivo:

    $sudo nano uwsgiTest.py

Donde deberás escribir el siguiente script: 


    #!/venv/bin/python
    
    from flask import Flask
    application = Flask(__name__)
    
    @application.route("/")
    def hello():
    	return "Hello World!"
    
    if __name__ == "__main__":
    	application.run(host='0.0.0.0', port=8080)

Respeta la sangría y guarda el archivo .

Después de guardar el archivo con el script, deberás ejecutarlo con el siguiente comando:

    $uwsgi --socket 0.0.0.0:8000 --protocol=http -w uwsgiTest
*(Para salir de la prueba debes presionar `Ctrl+c`)*

También debes crear el archivo de `config.ini` **en la carpeta de tu proyecto.**

    $sudo nano config.ini

y escribe lo siguiente: 

    [uwsgi]
    
    module = uwsgiTest
    app = app
    
    master = true
    processes = 5
    
    socket = /var/www/project/myapp.sock
    chmod-socket = 666
    vacuum = true
    
    die-on-term = true
    
    plugin = python

Guárdalo y continua por instalar Flask.

<br>

### 8. Instalar Flask en el ambiente virtual ###


Probablemente tengas que cambiar el owner para instalar Flask

    $sudo chown -R pi venv

Ahora podras instalar Flask con el siguiente comando:


    $pip install flask

<br>

### 9. Prueba de Flask ###

Puedes utilizar el comando que se utilizo para probar que Uwsgi estuviera instalado

    $uwsgi --socket 0.0.0.0:8000 --protocol=http -w uwsgiTest
*verifica en el browser accediendo a 127.0.0.1:8000*

Se recomienda probar con otro puerto (Debe funcionar sin que cambies el script).

    $uwsgi --socket 0.0.0.0:7000 --protocol=http -w hello

*verifica en el browser.*



<br>
### 11. Probar Nginx con Uwsgi y Flask (que todo este en orden). ###

Ejecuta los siguientes comandos para reiniciar Nginx y Uwsgi

    $sudo service nginx restart

crear un archivo config en sites-available (carpeta de nginx)

    $cd /etc/nginx/sites-available
    $sudo nano config



Hacer el enlace del archivo config de sites-available a sites-enabled.

<br>

### 12. probar el config con: ###

    $sudo uwsgi --ini config.ini
<br>

### 13. probar en el browser con el IP del RaspberryPi donde veras un hermoso Hola Mundo! ###

### 14.- Iniciar el servidor al encender la RaspberryPi ###


**1. Deberás crear un script con el siguiente comando:**

    $sudo nano /etc/init.d/scriptTest

(en lugar de *scriptTest* puedes elegir el nombre que gustes).

Ahora deberas escribir lo siguiente:

    #! /bin/sh
    # /etc/init.d/scriptTest
    
    ### BEGIN INIT INFO
    # Provides:  scriptname
    # Required-Start:$remote_fs $syslog
    # Required-Stop: $remote_fs $syslog
    # Default-Start: 2 3 4 5
    # Default-Stop:  0 1 6
    # Short-Description: Start daemon at boot time
    # Description:   Enable service provided by daemon.
    ### END INIT INFO
    
    echo "Activando Ambiente Virtual"
    cd /var/www/proyecto
    source venv/bin/activate
    echo "Ejecutando configuracion"
    sudo uwsgi --ini config.ini

Deberás agregar tu script a `.bashrc`

Debes estar en root y hacer el siguiente comando para acceder a `.bashrc`


    $cd ~
    $sudo nano .bashrc

debes ir al final del archivo y agregar la siguiente linea 

    ./scriptTest

Guarda y sal `Ctrl` + `x` + `y`, `Enter`


#### 2. Hacer que el script sea ejecutable ####

Con el siguiente comando:

    $sudo chmod 755 /etc/init.d/scriptTest

Puedes probar el script con el siguiente comando:

    $sudo /etc/init.d/scriptTest start

Recuerda que para salir debes presionar `Ctrl` + `c`

#### 3. Registra el script para que corra al encender la RaspberryPi ####

    $sudo update-rc.d scriptTest defaults  

Listo! para este punto tu aplicación Flask en un servidor Nginx con Uwsgi como intermediario deberá estar funcionando cada vez que inicias tu RaspberryPi.