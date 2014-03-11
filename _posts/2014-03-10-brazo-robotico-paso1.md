---
layout: post
title: 'Brazo robotico - Paso 1'
author: eden
excerpt: 'Resulto ser que el famoso brazo de steren solo es una serie de motores, cables y engranes astutamente conectados que permiten al usuario el controlar el brazo a traves de interruptores en un control.
'
---

#Brazo robótico

Resulto ser que el famoso brazo de steren solo es una serie de motores, cables y engranes astutamente conectados que permiten al usuario el controlar el brazo a traves de interruptores en un control.

![original][img1]

La decisión es modificarlo para volverlo inteligente, y pueda ser controlado desde algun dispositivo externo (puerto serial, servicio web, etc.), mandarle un ciclo de instrucciones para que realice una serie de tareas precisas y continuas

###Primer paso: Potencia.

Para controlar un motor en dos direcciones se utiliza un puente H, el cual es un arreglo de transistores que permite el que mediante dos señales la corriente fluya en una dirección o en otra. Alex y Moises, quienes están realizando el proyecto, ensamblaron el circuito en un proto, y mediante un arduino implementaron una interface serial para controlar uno de los motores del brazo.

Aqui se muestra el circuito montado en *proto*: 

![puenteH][img2]

La siguiente imagen es el arreglo previo al montaje:

![Ensamble][img2]

Y este ultimo link muestra el video de la primera prueba.

 [Prueba][1]

 **__@elmundoverdees__**

[1]: http://youtu.be/qByaTxZ2sZg
[img1]: /assets/post_img/brazo/original "Brazo"
[img2]: /assets/post_img/brazo/puenteh "Puente H"
[img3]: /assets/post_img/brazo/brazoPuente "Ensamble"
