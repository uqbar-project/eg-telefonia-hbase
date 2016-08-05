# Llamadas telefónicas

## Objetivo
muestra cómo se modela un conjunto de llamadas entre abonados de una compañía telefónica. 

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

Dado que HBase funciona sólo en Linux recomendamos correr el ejemplo desde una instalación en dicho sistema operativo
(desde Windows podés correr una VM Linux).

## Instalación
Antes de correr el main, tenés que instalar una base de datos HBase y levantar el server (ejecutable start-hbase.sh). 

En la carpeta [scripts](scripts) del directorio vas a encontrar dos archivos:

* [Script Llamadas](scripts/scriptLlamadas) para ejecutarlo en el shell de HBase (ejecutable hbase shell del directorio $HBASE_DIR/bin). 
Este script inserta datos de varias llamadas.
* [Queries llamadas](scripts/queriesLlamadas) resuelve varias consultas (cada uno se explica dentro del mismo archivo). Se puede copiar y pegar en el shell uno por uno.
