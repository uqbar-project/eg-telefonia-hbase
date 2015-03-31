package ar.edu.telefonia.home

import ar.edu.telefonia.domain.Abonado
import java.util.ArrayList
import java.util.List

class HomeAbonados {
	
	static HomeAbonados instance = null
	List<Abonado> abonados = new ArrayList<Abonado>()
	
	private new() {
	}
	
	def static getInstance() {
		if (instance == null) {
			instance = new HomeAbonados
		}
		instance
	}
	
	def getAbonado(Abonado unAbonado) {
		val abonadosDeIgualNombre = abonados.filter [ abonado | abonado.equals(unAbonado) ]
		if (abonadosDeIgualNombre.isEmpty) {
			null
		} else {
			abonadosDeIgualNombre.get(0)
		}
	}
	
	def addAbonado(Abonado abonado) {
		abonados.add(abonado)
	}
	
}