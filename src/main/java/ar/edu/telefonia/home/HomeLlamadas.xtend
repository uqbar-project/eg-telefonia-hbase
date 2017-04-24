package ar.edu.telefonia.home

import ar.edu.telefonia.domain.Abonado
import ar.edu.telefonia.domain.Llamada
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.ArrayList
import java.util.List
import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hbase.Cell
import org.apache.hadoop.hbase.HBaseConfiguration
import org.apache.hadoop.hbase.KeyValue
import org.apache.hadoop.hbase.TableName
import org.apache.hadoop.hbase.client.Connection
import org.apache.hadoop.hbase.client.ConnectionFactory
import org.apache.hadoop.hbase.client.Result
import org.apache.hadoop.hbase.client.ResultScanner
import org.apache.hadoop.hbase.client.Scan
import org.apache.hadoop.hbase.client.Table
import org.apache.hadoop.hbase.util.Bytes

class HomeLlamadas {

	/**
	 * Demo de Telefonia
	 * 
	 * @author Adam Horvath
 	*/	
	private static final String tablaLlamadas = "llamadas"

	static Connection connection
	static Configuration config

	def static void main(String[] args) {
		// OJO, TIENEN QUE COINCIDIR LA VERSION DEL POM.XML CON LA QUE TIENE EL SERVER
		// Si no te va a aparecer un mensaje como el siguiente:
		// org.apache.hadoop.hbase.client.NoServerForRegionException: Unable to find region for llamadas,,99999999999999 after 10 tries.
		// 	at org.apache.hadoop.hbase.client.HConnectionManager$HConnectionImplementation.locateRegionInMeta(HConnectionManager.java:1095)
		// su hduser | pwd: hduser
		// En home/hduser/apps/hbase-0.98.7-hadoop2/bin hacer ./start-hbase.sh
		// config = new Configuration(true)
		config = HBaseConfiguration.create()

		config.set("hbase.cluster.distributed", "false")
		config.set("hbase.zookeeper.quorum", "localhost")
		config.setInt("hbase.zookeeper.property.clientPort", 2181) 
		connection = ConnectionFactory.createConnection(config)
		println("Connection establecida con HBase: " + connection)

		try {
			println ("************* LLAMADAS EN OBJETOS *********************")
			new HomeLlamadas().getLlamadas(new Abonado("46710080", "Walter White")).forEach [
				llamada | println(llamada.toString)				
			]
		} catch (IOException e) {
			e.printStackTrace
			println("ERROR IO")
		}
	}

	/**
	 * @return Lista de llamadas de un abonado
	 * @throws IOException
 	*/
	def List<Llamada> getLlamadas(Abonado abonado) {
		val Table table = connection.getTable(TableName.valueOf(tablaLlamadas))
		val scan = new Scan()
		scan.addFamily(Bytes.toBytes("origen"))
		scan.addFamily(Bytes.toBytes("destino"))
		scan.addFamily(Bytes.toBytes("llamada"))

		// Vamos a buscar todas las llamadas de un abonado
		// como la clave se compone del número que llama + la hora
		// utilizamos un scan que nos devuelve múltiples resultados
		val clave = abonado.numero
		scan.setStartRow(Bytes.toBytes(clave))
		scan.setStopRow(Bytes.toBytes(clave + "z"))
		val llamadas = new ArrayList<Llamada>()
		val ResultScanner resultScanner = table.getScanner(scan)

		// For each x fila
		for (Result result : resultScanner) {
			// podemos acceder por clave
			val abonadoOrigen = crearOUsarAbonado(result, "origen")
			val abonadoDestino = crearOUsarAbonado(result, "destino")
			new Llamada => [
				origen = abonadoOrigen
				destino =  abonadoDestino
				fechaInicio = getFecha(getDato(result, "llamada", "inicio"))
				fechaFin = getFecha(getDato(result, "llamada", "fin"))
				estado = getDato(result, "llamada", "estado")
				llamadas.add(it)
			]
			
			// For each de columnas variables
			val Cell[] datos = result.rawCells
			for (Cell kv : datos) {
				// TODO: En xtend setear los valores
				// Los abonados hay que sacarlos de un home especial
				println("family: " + Bytes.toString(kv.family))
				println("qualifier: " + Bytes.toString(kv.qualifier))
				println("value: " + Bytes.toString(kv.value))
				println("row: " + Bytes.toString(result.row))
			}

			println("*****************************************************")
		}

		resultScanner.close()
		table.close()
		llamadas
	}
	
	def crearOUsarAbonado(Result result, String familia) {
		val abonado = this.getAbonado(result, familia)
		val abonadoPosta = HomeAbonados.instance.getAbonado(abonado) 
		if (abonadoPosta == null) {
			HomeAbonados.instance.addAbonado(abonado)
			abonado
		} else {
			abonadoPosta
		}
	}

	def getAbonado(Result result, String familia) {
		val nombre = getDato(result, familia, "nombre")
		val numero = getDato(result, familia, "numero")
		val domicilio = getDato(result, familia, "domicilio")
		new Abonado(numero, nombre, domicilio)
	}

	def getFecha(String fechaString) {
		if (fechaString == null) {
			return null
		} else {
			new SimpleDateFormat("yyyyMMddhhmmss").parse(fechaString)	
		}
	}
	
	def getDato(Result result, String familia, String campo) {
		val dato = result.getValue(Bytes.toBytes(familia), Bytes.toBytes(campo))
		if (dato != null) {
			new String(dato)
		} else {
			null
		} 
	}

}
