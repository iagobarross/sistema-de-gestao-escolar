import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:http/http.dart' as http;

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
  final String _base = '${ApiClient.baseDomain}/chat';
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<Map<String, dynamic>> _mensagens = [];
  Timer? _pollingTimer;
  bool _enviando = false;
  bool _carregandoInicial = true;

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && _mensagens.isNotEmpty) _verificarNovas();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _carregarMensagens() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/conversas/${widget.conversaId}/mensagens'),
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
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (_) {
      if (mounted) setState(() => _carregandoInicial = false);
    }
  }

  Future<void> _verificarNovas() async {
    if (_mensagens.isEmpty) return;
    try {
      final desde = _mensagens.last['enviadaEm'] as String;
      final res = await http.get(
        Uri.parse(
          '$_base/conversas/${widget.conversaId}/mensagens/novas?desde=$desde',
        ),
        headers: await ApiClient.getHeaders(),
      );
      if (res.statusCode == 200 && mounted) {
        final novas = List<Map<String, dynamic>>.from(
          jsonDecode(utf8.decode(res.bodyBytes)),
        );
        if (novas.isNotEmpty) {
          setState(() => _mensagens.addAll(novas));
          _scrollToBottom();
        }
      }
    } catch (_) {}
  }

  Future<void> _enviar() async {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty || _enviando) return;

    setState(() => _enviando = true);
    _ctrl.clear();

    try {
      final res = await http.post(
        Uri.parse('$_base/conversas/${widget.conversaId}/mensagens'),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode({'texto': texto}),
      );
      if (res.statusCode == 201 && mounted) {
        final nova = Map<String, dynamic>.from(
          jsonDecode(utf8.decode(res.bodyBytes)),
        );
        setState(() => _mensagens.add(nova));
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        // Devolve o texto para o campo se falhou
        _ctrl.text = texto;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
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
          // Lista de mensagens
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

          // Campo de envio
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
    final minha = (msg['autorId'] as int) == widget.meuId;
    final texto = msg['texto'] as String? ?? '';
    final nomeAutor = msg['nomeAutor'] as String? ?? '';
    final enviadaEm = msg['enviadaEm'] as String? ?? '';

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
                nomeAutor.isNotEmpty ? nomeAutor[0].toUpperCase() : '?',
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
