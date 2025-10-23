package com.fateczl.sistemaDeGestaoEscolar.escola;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/escola")
public class EscolaController {

	@Autowired
	private EscolaService escolaService;
	
	@GetMapping
	public String loadFormPage (Model model) {
		model.addAttribute("listaEscola", escolaService.findAll());
		return "escola/listagem";
	}
	

}
