import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'conversa_screen.dart';
import 'nova_conversa_screen.dart';

class ListaConversasScreen extends StatefulWidget {
  const ListaConversasScreen({super.key});

  @override
  State<ListaConversasScreen> createState() => _ListaConversasScreenState();
}

class _ListaConversasScreenState extends State<ListaConversasScreen> {
  final String _base = '${ApiClient.baseDomain}/chat';
  late Future<List<Map<String, dynamic>>> _futureConversas;
  String? _minhaRole;
  int? _meuId;

  @override
  void initState() {
    super.initState();
    _carregarDadosDoToken();
    _carregar();
  }

  Future<void> _carregarDadosDoToken() async {
    final payload = await AuthService().getPayload();
    if (mounted) {
      setState(() {
        _minhaRole = payload?['role'];
        _meuId = payload?['id'];
      });
    }
  }

  void _carregar() {
    setState(() {
      _futureConversas = _buscarConversas();
    });
  }
  
  Future<List<Map<String, dynamic>>> _buscarConversas() async {
    final res = await http.get(
      Uri.parse('$_base/conversas'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(utf8.decode(res.bodyBytes)),
      );
    }
    throw Exception('Erro ao carregar conversas: ${res.statusCode}');
  }

  bool get _podeIniciarConversa => _minhaRole == 'RESPONSAVEL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureConversas,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _carregar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final conversas = snap.data ?? [];

          if (conversas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _podeIniciarConversa
                        ? 'Nenhuma conversa ainda.\nToque em + para iniciar.'
                        : 'Nenhuma mensagem recebida ainda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _carregar(),
            child: ListView.separated(
              itemCount: conversas.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (_, i) => _itemConversa(ctx, conversas[i]),
            ),
          );
        },
      ),
      floatingActionButton: _podeIniciarConversa
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NovaConversaScreen()),
                );
                _carregar();
              },
              backgroundColor: Colors.purple.shade800,
              foregroundColor: Colors.white,
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _itemConversa(BuildContext ctx, Map<String, dynamic> conversa) {
    final tipo = conversa['tipo'] as String;
    final naoLidas = conversa['naoLidas'] as int? ?? 0;
    final ultimaMensagem = conversa['ultimaMensagem'] as Map?;

    final String tituloExibido = _podeIniciarConversa
        ? _labelCanal(tipo, conversa['nomeProfessor'])
        : conversa['nomeResponsavel'] ?? 'Responsável';

    final String subtituloExibido = _podeIniciarConversa
        ? conversa['nomeEscola'] ?? ''
        : _labelCanal(tipo, conversa['nomeProfessor']);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: _corCanal(tipo).withOpacity(0.15),
        child: Text(
          tituloExibido.isNotEmpty ? tituloExibido[0].toUpperCase() : '?',
          style: TextStyle(color: _corCanal(tipo), fontWeight: FontWeight.bold),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              tituloExibido,
              style: TextStyle(
                fontWeight: naoLidas > 0 ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            _formatarHora(conversa['ultimaMensagemEm']),
            style: TextStyle(
              fontSize: 11,
              color: naoLidas > 0
                  ? Colors.purple.shade700
                  : Colors.grey.shade500,
              fontWeight: naoLidas > 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              ultimaMensagem != null
                  ? ultimaMensagem['texto'] ?? ''
                  : subtituloExibido,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: naoLidas > 0 ? Colors.black87 : Colors.grey.shade600,
                fontWeight: naoLidas > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (naoLidas > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$naoLidas',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () async {
        await Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => ConversaScreen(
              conversaId: conversa['id'],
              titulo: tituloExibido,
              subtitulo: subtituloExibido,
              meuId: _meuId ?? 0,
            ),
          ),
        );
        _carregar(); 
      },
    );
  }

  String _labelCanal(String tipo, String? nomeProfessor) => switch (tipo) {
    'SECRETARIA' => 'Secretaria',
    'COORDENACAO' => 'Coordenação',
    'PROFESSOR' => nomeProfessor ?? 'Professor',
    _ => tipo,
  };

  Color _corCanal(String tipo) => switch (tipo) {
    'SECRETARIA' => Colors.blue.shade700,
    'COORDENACAO' => Colors.purple.shade700,
    'PROFESSOR' => Colors.teal.shade700,
    _ => Colors.grey,
  };

  String _formatarHora(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final agora = DateTime.now();
      if (dt.day == agora.day &&
          dt.month == agora.month &&
          dt.year == agora.year) {
        return '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}