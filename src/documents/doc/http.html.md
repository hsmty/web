---
layout: 'default'
title: 'HTTP: El protocolo de la web'
---

# HTTP: El protocolo de la web

Este artículo pretende ser una guía a las diferentes partes de HTTP,
así como una exposición de las funcionalidades menos utilizadas de este,
empezaremos describiendo para que sirve el protocolo y como logra entregar
esa funcionalidad.

## Lo Básico

El protocolo funciona por medio de transferencia de texto llano, envia una 
sección de lineas con la metadata del [recurso] con el formato 
<code>identificador: valor</code> y delimitadas por el caractér \n (salto de 
línea, ASCII 32), esta sección es terminada por un doble salto de línea (\n\n)
y son conocidas como _headers_ o cabeceras, seguidas por el contenido mismo
del recurso, que puede variar en formatos, aunque lo más utilizados son HTML,
JSON y XML.

## Métodos

HTTP cuenta con cuatro métodos básicos que implementan las acciones CRUD
(Create, Read, Update y Delete), esto permite al protocolo ser usado para 
operaciones básicas, aunque hay que tomar en cuenta que los navegadores 
usualmente solo implementan dos: GET y POST de la forma convensional y el
resto (PUT y DELETE) solo son accedidos por medio de [XMLHttpRequest].

### GET

El método más ultilizado del protocolo, es el que se utiliza cada vez que se
hace una petición a un sitio web. GET pide un recurso al servidor, describiendo,
opcionalmente, varias características, como la codificación de texto preferida
(UTF-8, ISO-8859-1, SHIFT-JIS, etc) y el formato preferido (HTML, JSON, 
etc.)

e.g.

	GET http://example.com/pub/example HTTP/1.1 


### POST

### PUT

### DELETE

## Cabeceras
