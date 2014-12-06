---
layout: post
title: 'Extraer subtitulos de un .mkv'
author: eden
---
Para extraer un subtitulo de un archivo matroska _(.mkv)_ desde linux se necesita le herramienta [mkvtoolnix][1]

Esta herramienta contiene dos subprogramas que nos permitiran realizar la tarea:

* __mkvmerge__: Dentro de las opciones que este programa maneja nos lista los tracks de audio y video contenidos en un archivo matroska y los codec utilizados para su creacion.
* __mkvextract__: Nos permite extraer cualquiera de los tracks contenidos en el matroska.

<!--more-->

### Instalación


La instalación en cualquier sistema basado en [debian][2] no require mas que una línea de código:

`$ sudo apt-get install mkvtoolnix`

### Uso

Instalado el programa nos movemos a la ubicación donde este el archivo del que necesitamos extraer los subtítulos.

Para ver la información del archivo, podemos hacerlo desde un _shell_ ingresando el
comando: 

`$ mkvmerge -i <archivo>`

En donde <archivo> es el archivo _.mkv_ del cual queremos extraer los
subtítulos.

Aparecera un texto como el siguiente (aquí <archivo> es video.mkv):

```
$ mkvmerge -i video.mkv

File 'video.mkv': container: Matroska
Track ID 0: video (V_MPEG4/ISO/AVC)
Track ID 1: audio (A_AAC)
Track ID 2: subtitles (S_TEXT/ASS)
```

Eso nos permitio identificar cual de los _Tracks_ es el de los subtítulos, en el caso
de este archivo es el _Track_ 2 que podemos extraer utilizando el comando:

`$ mkvextract tracks <archivo> 2:subs.ass`

Aquí archivo sería video.mkv, 2 es el número del _Track_ en donde se encuentran
nuestros subtítulos y subs.ass es el archivo que vamos a crear con los
subtítulos extraidos (ASS siendo un formato de subtítulos).

Se desplegará en la pantalla la información del _Track_ que está siendo
extraido.

```
Extracting track 2 with the CodecID 'S_TEXT/ASS' to the file 'destinoTrack'. Container format: SSA/ASS text subtitles
Progress: 100%
```

Ahora si buscamos dentro de la carpeta donde estamos trabajando veremos el archivo subs.ass (o como lo hayan llamado).

Listo.

@elmundoverdees

[1]: https://www.bunkus.org/videotools/mkvtoolnix/
[2]: www.debian.org
