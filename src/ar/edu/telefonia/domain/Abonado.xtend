package ar.edu.telefonia.domain

class Abonado {
	
	@Property String numero
	@Property String nombreTitular
	@Property String domicilio

	new(String numero, String nombreTitular) {
		this(numero, nombreTitular, "")
	}
	
	new(String numero, String nombreTitular, String domicilio) {
		this.numero = numero
		this.nombreTitular = nombreTitular
		this.domicilio = domicilio
	}
	
	def prefijo() {
		numero.substring(0, 4)
	}
	
	override equals(Object otro) {
		if (otro == null) {
			return false
		}
		val otroAbonado = otro as Abonado
		nombreTitular.equalsIgnoreCase(otroAbonado.nombreTitular)
	}
	
	override hashCode() {
		nombreTitular.hashCode
	}
	
	override toString() {
		super.toString() + " [" + nombreTitular + "]"
	}
}