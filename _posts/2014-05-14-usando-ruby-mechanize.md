---
layout: post
title: 'Usando Ruby y Mechanize para automatizar la descarga de archivos'
author: edmz
excerpt: 'Ruby, con la ayuda de Mechanize, nos permiten navegar la red programaticamente. Y es divertido.'
---

Vaya que la flojera es, paradojicamente, un excelente motivador para
poner a trabajar a los programadores.

En este micro-articulo, les voy a ensenar como la flojera de firmarme
a un sitio y navegarlo para descargar un archivo, me llevo a
automatizar el proceso.

De pasada, podremos ver el poder que el gem [1]Mechanize le da a ruby
para automatizar el acceso a sitios web.

Mechanize es una libreria originalmente de Perl pero ya disponible
para Ruby, Python y otros lenguajes que te permite navegar
programaticamente los sitios webs.

Operaciones clasicas del surfeo web como dar clic a links y llenar
formularios se pueden hacer con simples comandos de Mechanize.

Y eso fue justamente lo que hice con ruby y Mechanize para accesar
mi factura del sitio web de Gas Natural.

Sin mas, manos a la obra.

Lo primero y mas importante, es conocer y navegar bien el sitio Web
cuyo acceso te interesa automatizar. Mechanize necesita un URL de
partida. Idealmente, este URL es la pantalla de login, en caso de que
esto sea necesario. 


En el caso del sitio de Gas Natural hay pantalla de login. Asi que la visitamos
y tomamos nota de ella. 

    {% highlight ruby %}
    
    OFICINA_VIRTUAL = "http://www.gasnaturalfenosa.com.mx/mx/inicio/hogar/servicio+al+cliente/1285346043479/oficina+virtual.html"
  
    agent = Mechanize.new
    agent.get(OFICINA_VIRTUAL)
  
    {% endhighlight %}

De alguna manera tenemos que llenar nuestro usuario y password de Gas
Natural en el formulario de Login. Dado que no tenemos un mouse para
navegar el sitio web y escoger el campo en el que queremos escribir,
Mechanize nos ofrece la facilida de buscar elementos de la pagina web
de diferentes formas.

Una de ellas, y la que usaremos, es la de buscar un formulario en base
al atributo 'action' del form. Vemos el codigo HTML con el navegador,
y buscamos ese valor. Tomamos nota tambien del nombre de los campos
de usuario y password, en este caso "User" y "Password".

Llenar y enviar el formulario se convierte simplemente en este codigo:


    ```ruby
  
    LOGIN_FORM_ACTION = 'https://www.gnmextranet2.com/PortalSGC/Login.aspx'
  
    form = form_with(action: LOGIN_FORM_ACTION)
    form.field_with(name: "User").value     = 'miusuario'
    form.field_with(name: "Password").value     = 'mipassword'
    nueva_pagina = form.click_button
  
    ```

Al momento de ejecutar click_button(), estamos efectivamente haciendo que 
el "navegador" de Mechanize avance a la siguiente pagina, la cual capturamos
a la variable 'nueva_pagina'.

Si seguimos este proceso en nuestro navegador real, veremos que despues
de dar login, habra un iframe que muestra nuestra factura actual. 

Viendo el codigo HTML de esa pagina, podemos ver que la factura se encuentra
embebida en un iframe con nombre 'oFacturaPDF'. Si estuvieramos en el navegador
solamente habria que hacer click a la factura para luego grabarla.

Eso mismo haremos con la ayuda de Mechanize.

    ```ruby
  
    nueva_pagina.iframe_with(name: "oFacturaPDF").click.save(NOMBRE_QUE_LE_QUEREMOS_PONER_A_LA_DESCARGA)
    
    ```

Y listo. En tan solo unos clics hemos automatizado el proceso de
descargar el PDF de tu factura mas reciente de Gas Natural. Algo quiza
de poco valor. Pero hemos visto el poder de la automatizacion web que
permite Mechanize, algo que definitivamente nos ofrece muchas
posibilidades de uso.


NOTA: El script de ruby final esta programado usando los metodos de
Mechanize que aceptan bloques de ruby. Tambien aproveche que muchos
metodos de Mechanize regresa un tipo de objeto que facilita mucho el
encadenar metodos. El resultado es un codigo muy compacto y que, al
menos para mi, tiene un flujo facil de leer.

El codigo completo:

    ```ruby
    require "mechanize"
    require "date"
    require "logger" if ENV['DEBUG']
     
    OFICINA_VIRTUAL   = "http://www.gasnaturalfenosa.com.mx/mx/inicio/hogar/servicio+al+cliente/1285346043479/oficina+virtual.html"
    LOGIN_FORM_ACTION = 'https://www.gnmextranet2.com/PortalSGC/Login.aspx'
    FACTURA_FNAME     = "factura-#{Date.today.to_s}.pdf"
     
    abort("Error\n\tusage: #{$0} username password") if ARGV.empty? || ARGV.size != 2
     
    username = ARGV.shift
    password = ARGV.shift
     
     
    agent                          = Mechanize.new
    agent.verify_mode              = OpenSSL::SSL::VERIFY_NONE
    agent.log                      = Logger.new(STDOUT) if ENV['DEBUG']
    agent.pluggable_parser.default = Mechanize::Download
     
    agent.get(OFICINA_VIRTUAL).form_with(action: LOGIN_FORM_ACTION) do |form|
      form.field_with(name: "User").value     = username
      form.field_with(name: "Password").value = password
    end.click_button.iframe_with(name:"oFacturaPDF").click.save(FACTURA_FNAME)
    puts "Grabando archivo #{FACTURA_FNAME}."
    ```

  [1]: http://docs.seattlerb.org/mechanize/
