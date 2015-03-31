package ar.edu.telefonia.home

import ar.edu.telefonia.domain.Abonado
import ar.edu.telefonia.domain.Llamada
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.ArrayList
import java.util.List
import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.hbase.KeyValue
import org.apache.hadoop.hbase.client.HConnection
import org.apache.hadoop.hbase.client.HConnectionManager
import org.apache.hadoop.hbase.client.HTableInterface
import org.apache.hadoop.hbase.client.Result
import org.apache.hadoop.hbase.client.ResultScanner
import org.apache.hadoop.hbase.client.Scan
import org.apache.hadoop.hbase.util.Bytes

class HomeLlamadas {

	/**
	 * Demo de Telefonia
	 * 
	 * @author Adam Horvath
 	*/
	private static final String tablaLlamadas = "llamadas"

	static HConnection connection
	static Configuration config

	def static void main(String[] args) {
		// OJO, TIENEN QUE COINCIDIR LA VERSION DEL POM.XML CON LA QUE TIENE EL SERVER
		// hduser | pwd: hduser
		config = new Configuration(true)

		//config.set("hbase.zookeeper.quorum", "localhost")
		//config.setInt("hbase.zookeeper.property.clientPort", 2181) 
		connection = HConnectionManager.createConnection(config)
		println("Connection establecida con HBase: " + connection)

		//	conf = HBaseConfiguration.create
		// Without pooling, the connection to a table will be reinitialized.
		// Creating a new connection to a table might take up to 5-10 seconds!
		//pool = new HTablePool(conf, 10)
		// If you don't have tables or column families, HBase will throw an
		// exception. Need to pre-create those. If already exists, it will throw
		// as well. Ah, tricky... :)
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
		val HTableInterface table = connection.getTable(tablaLlamadas)
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
			val llamada = new Llamada
			llamada.origen = abonadoOrigen 
			llamada.destino =  abonadoDestino
			llamada.fechaInicio = getFecha(getDato(result, "llamada", "inicio"))
			llamada.fechaFin = getFecha(getDato(result, "llamada", "fin"))
			llamada.estado = getDato(result, "llamada", "estado")
			llamadas.add(llamada)
			
			// For each de columnas variables
			val KeyValue[] datos = result.raw
			for (KeyValue kv : datos) {

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
