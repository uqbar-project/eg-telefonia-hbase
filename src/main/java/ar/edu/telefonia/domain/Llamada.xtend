package ar.edu.telefonia.domain

import java.text.SimpleDateFormat
import java.util.Date
import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Llamada {
	
	Abonado origen
	Abonado destino
	Date fechaInicio
	Date fechaFin
	String estado
	
	def boolean largaDistancia() {
		origen.prefijo != destino.prefijo
	}
	
	def getNumeroOrigen() {
		origen.numero
	}
	
	override toString() {
		"Llamada de " + origen + " a " + destino + " [" + new SimpleDateFormat("dd/MM/yyyy hh:mm:ss").format(fechaInicio) + "] - " + new SimpleDateFormat("dd/MM/yyyy hh:mm:ss").format(fechaFin)
	}
	
}