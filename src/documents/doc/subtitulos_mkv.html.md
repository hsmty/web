---
title: 'Extraer subtitulos de un .mkv'
---

#Extraer subtitulos de un .mkv
---

Para extraer un subtitulo de un archivo matroska _(.mkv)_ desde linux se necesita le herramienta [mkvtoolnix][1]

Esta herramienta contiene dos subprogramas que nos permitiran realizar la tarea:

__mkvmerge__: Dentro de las opciones que este programa maneja nos lista los tracks de audio y video contenidos en un archivo matroska y los codec utilizados para su creacion
__mkvextract__: Nos permite extraer cualquiera de los tracks contenidos en el matroska.

###Instalacion
---

La instalacion en cualquier sistema basado en [debian][2] no require mas que una linea de codigo:

`$sudo apt-get install mkvtoolnix`

###Uso
---

Instalado el programa nos movemos a la ubicacion donde este el archivo del que necesitamos extraer los subtitulos.

Para ver la informacion del archivo ingresamos en la terminal el comando:

`$mkvmerge -i _nombre_archivo_`

Aparecera un texto como el siguiente:

```
File 'aot_08.mkv': container: Matroska
Track ID 0: video (V_MPEG4/ISO/AVC)
Track ID 1: audio (A_AAC)
Track ID 2: subtitles (S_TEXT/ASS)
```

Eso nos permitio identificar cual de los Tracks es el de los subtitulos. Para extraerlos utilizaremos el comando:

`$mkvextract tracks nombre_delarchivo IDtrack:destinoTrack`

Se desplegara en la pantalla los siguiente:

```
Extracting track 2 with the CodecID 'S_TEXT/ASS' to the file 'destinoTrack'. Container format: SSA/ASS text subtitles
Progress: 100%
```

Ahora si buscamos dentro del folder donde estamos trabajando veremos el archivo _destinoTrack_.

Listo.

@elmundoverdees

[1]: https://www.bunkus.org/videotools/mkvtoolnix/
[2]: www.debian.org
