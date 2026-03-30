package com.fateczl.sistemaDeGestaoEscolar.chat;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/chat")
public class ChatRestController {

    @Autowired
    private MensagemRepository mensagemRepository;

    @GetMapping("/conversas/{conversaId}/mensagens")
    public ResponseEntity<List<Map<String, Object>>> getHistorico(@PathVariable Long conversaId) {

        List<Mensagem> mensagens;

        if (conversaId == 1L) {
            mensagens = mensagemRepository.findMensagensPublicas();
        } else {
            mensagens = new ArrayList<>();
        }

        List<Map<String, Object>> resposta = new ArrayList<>();
        for (Mensagem m : mensagens) {
            Map<String, Object> dto = new HashMap<>();
            dto.put("id", m.getId());
            dto.put("conteudo", m.getConteudo());

            // Criamos um mapa interno para o remetente, assim o Flutter consegue ler:
            // msg['remetente']['id'] e msg['remetente']['nome']
            Map<String, Object> remetenteMap = new HashMap<>();
            if (m.getRemetente() != null) {
                remetenteMap.put("id", m.getRemetente().getId());
                remetenteMap.put("nome", m.getRemetente().getNome());
            }
            dto.put("remetente", remetenteMap);

            dto.put("dataEnvio", m.getDataEnvio() != null ? m.getDataEnvio().toString() : "");

            resposta.add(dto);
        }

        // Devolvemos o JSON limpo e sem o problema do Proxy do Hibernate!
        return ResponseEntity.ok(resposta);
    }

    @GetMapping("/conversas")
    public ResponseEntity<List<Map<String, Object>>> getListaConversas() {
        // O ideal numa fase posterior é buscar as conversas através do utilizador logado.
        // Para já, vamos devolver sempre o "Mural Público" para que apareça na lista de todos!

        List<Map<String, Object>> lista = new ArrayList<>();

        Map<String, Object> mural = new HashMap<>();
        mural.put("id", 1L);
        mural.put("tipo", "GERAL");

        // Colocamos o mesmo nome nos dois campos para o Flutter ler independentemente de quem faz login
        mural.put("nomeProfessor", "Mural da Escola");
        mural.put("nomeResponsavel", "Mural da Escola");
        mural.put("nomeEscola", "Canal Público"); // Usado como subtítulo
        mural.put("naoLidas", 0);

        // (Opcional) Podemos buscar a última mensagem do banco para mostrar como resumo:
        // mural.put("ultimaMensagem", ...);

        lista.add(mural);

        // TODO: Futuramente, adicionaremos as conversas PRIVADAS aqui
        // Ex: lista.addAll(mensagemRepository.findConversasPrivadas(utilizadorLogadoId));

        return ResponseEntity.ok(lista);
    }
}