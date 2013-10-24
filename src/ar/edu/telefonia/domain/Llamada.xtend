package ar.edu.telefonia.domain

import java.util.Date
import java.text.SimpleDateFormat

class Llamada {
	
	@Property Abonado origen
	@Property Abonado destino
	@Property Date fechaInicio
	@Property Date fechaFin
	@Property String estado
	
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