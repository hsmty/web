---
layout: post
title: 'Brazo robotico - Paso 1'
author: eden
excerpt: 'Resultó ser que el famoso brazo de Steren es solo un conjunto de motores, cables y engranes astutamente conectados de tal manera que permiten al usuario el controlar el brazo a traves de interruptores fijados a una caja plástica.
'
---

Al investigar el funcionaminento del famoso brazo robótico de Steren, reusultó
ser un conjunto de motores, cables y engranes astutamente conectados de tal
manera que permiten al usuario controlar el brazo a través de interruptores 
fijados a una caja plástica, el interruptor sólo provee energía directamente al
motor y para revertir la dirección sólo es un segundo interruptor que conecta la
potencia al motor con la polaridad invertida.

![original][img1]

La decisión es modificarlo para volverlo inteligente, y pueda ser controlado desde algun dispositivo externo (puerto serial, servicio web, etc.), mandarle un ciclo de instrucciones para que realice una serie de tareas precisas y continuas

###Primer paso: Potencia.

Para controlar un motor en dos direcciones se utiliza un puente H, el cual es un arreglo de transistores que permite el que mediante dos señales la corriente fluya en una dirección o en otra. Alex y Moises, quienes están realizando el proyecto, ensamblaron el circuito en un proto, y mediante un arduino implementaron una interface serial para controlar uno de los motores del brazo.

Aqui se muestra el circuito montado en *proto*: 

![puenteH][img2]

La siguiente imagen es el arreglo previo al montaje:

![Ensamble][img3]

Y este ultimo link muestra el video de la primera prueba.

<iframe class="youtube" width="640" height="360" src="//www.youtube-nocookie.com/embed/qByaTxZ2sZg" frameborder="0" allowfullscreen></iframe>

 **__@elmundoverdees__**

[img1]: /assets/post_img/brazo/original.jpg "Brazo"
[img2]: /assets/post_img/brazo/puenteh.jpg "Puente H"
[img3]: /assets/post_img/brazo/brazoPuente.jpg "Ensamble"
