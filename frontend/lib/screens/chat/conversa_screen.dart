import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestao_escolar_app/services/chat_service.dart';

class ConversaScreen extends StatefulWidget {
  final int conversaId;
  final String titulo;
  final String subtitulo;
  final int meuId;

  const ConversaScreen({
    required this.conversaId,
    required this.titulo,
    required this.subtitulo,
    required this.meuId,
    super.key,
  });

  @override
  State<ConversaScreen> createState() => _ConversaScreenState();
}

class _ConversaScreenState extends State<ConversaScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Map<String, dynamic>> _mensagens = [];
  bool _enviando = false;
  bool _carregandoInicial = true; 
  
  late ChatService _chatService;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _carregarHistorico(); 
    _iniciarConexaoWebSocket(); 
  }

  Future<void> _carregarHistorico() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiClient.baseDomain}/chat/conversas/${widget.conversaId}/mensagens'),
        headers: await ApiClient.getHeaders(),
      );

      if (res.statusCode == 200 && mounted) {
        final lista = List<Map<String, dynamic>>.from(
          jsonDecode(utf8.decode(res.bodyBytes)),
        );
        setState(() {
          _mensagens.addAll(lista);
          _carregandoInicial = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Erro ao carregar histórico: $e');
      if (mounted) setState(() => _carregandoInicial = false);
    }
  }

  Future<void> _iniciarConexaoWebSocket() async {
    _chatService = ChatService(
      onMensagemRecebida: (mensagemJson) {
        if (mounted) {
          setState(() {
            _mensagens.add(mensagemJson);
          });
          _scrollToBottom();
        }
      },
    );

    String? token = await _authService.getToken();
    if (token != null) {
      _chatService.conectar(token);
    }
  }

  @override
  void dispose() {
    _chatService.desconectar();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty || _enviando) return;

    setState(() => _enviando = true);
    _ctrl.clear();

    try {
      if (widget.conversaId == 1) {
        _chatService.enviarMensagemPublica(texto);
      } else {
        _chatService.enviarMensagemPrivada(texto, widget.conversaId);
      }
    } catch (e) {
      if (mounted) {
        _ctrl.text = texto; 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.titulo, style: const TextStyle(fontSize: 15)),
            Text(
              widget.subtitulo,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _carregandoInicial
                ? const Center(child: CircularProgressIndicator())
                : _mensagens.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma mensagem ainda.\nSeja o primeiro a escrever!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: _mensagens.length,
                        itemBuilder: (_, i) => _buildMensagem(_mensagens[i]),
                      ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.purple.shade800,
                  child: _enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: _enviar,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensagem(Map<String, dynamic> msg) {
    final remetenteId = msg['remetente'] != null ? msg['remetente']['id'] : -1;
    final minha = remetenteId == widget.meuId;
    final texto = msg['conteudo'] as String? ?? '';
    final nomeAutor = msg['remetente'] != null ? msg['remetente']['nome'] : 'Usuário';
    final enviadaEm = msg['dataEnvio'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: minha
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!minha) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.purple.shade100,
              child: Text(
                nomeAutor.toString().isNotEmpty ? nomeAutor.toString()[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.purple.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: minha ? Colors.purple.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(minha ? 18 : 4),
                  bottomRight: Radius.circular(minha ? 4 : 18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!minha)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        nomeAutor,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ),
                  Text(
                    texto,
                    style: TextStyle(
                      color: minha ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (enviadaEm.isNotEmpty)
                    Text(
                      _formatarHora(enviadaEm),
                      style: TextStyle(
                        fontSize: 10,
                        color: minha ? Colors.white70 : Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarHora(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}