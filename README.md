# Llamadas telefónicas

## Objetivo
muestra cómo se modela un [conjunto de llamadas entre abonados de una compañía telefónica](https://github.com/uqbar-project/eg-telefonia-hbase/wiki) en una base NoSQL de tipo clave-valor. 

## Modelo
La llamada tiene como información 

* datos del abonado que hace la llamada (número de teléfono, nombre y domicilio), 
* datos del abonado que recibe la llamada (también número, nombre y domicilio) 
* y datos propios de la llamada 
 * inicio (fecha y hora)
 * fin (fecha y hora)
 * un estado = "A": activo | "I": inactivo

El modelo se genera inicialmente en HBase para luego convertirlo a un modelo de objetos 
donde se representa una sola vez cada abonado.
Es decir: en HBase el modelo es desnormalizado mientras que en objetos es normalizado.

## Instalación
Antes de correr el main, tenés que instalar una base de datos [HBase en Linux](https://hbase.apache.org/book.html#quickstart) [o Windows](https://hbase.apache.org/cygwin.html) y levantar el server (ejecutable start-hbase.sh). 

Para visualizar la información de una manera menos áspera de lo que propone el shell de HBase, podés instalarte [HUE](http://gethue.com/hadoop-hue-3-on-hdp-installation-tutorial/).

## Correr el ejemplo

En la carpeta [scripts](scripts) del directorio vas a encontrar dos archivos:

* [Script Llamadas](scripts/scriptLlamadas) para ejecutarlo en el shell de HBase (ejecutable hbase shell del directorio $HBASE_DIR/bin). 
Este script inserta datos de varias llamadas.
* [Queries llamadas](scripts/queriesLlamadas) resuelve varias consultas (cada uno se explica dentro del mismo archivo). Se puede copiar y pegar en el shell uno por uno.
