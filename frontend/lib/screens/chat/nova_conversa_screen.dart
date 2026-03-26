import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'conversa_screen.dart';

class NovaConversaScreen extends StatefulWidget {
  const NovaConversaScreen({super.key});

  @override
  State<NovaConversaScreen> createState() => _NovaConversaScreenState();
}

class _NovaConversaScreenState extends State<NovaConversaScreen> {
  final String _base = '${ApiClient.baseDomain}/chat';
  List<Map<String, dynamic>> _escolas = [];
  List<Map<String, dynamic>> _professores = [];
  Map<String, dynamic>? _escolaSelecionada;
  bool _carregando = true;
  int? _meuId;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    _meuId = await AuthService().getId();
    final payload = await AuthService().getPayload();

    try {
      final res = await http.get(
        Uri.parse('${ApiClient.baseDomain}/escola'),
        headers: await ApiClient.getHeaders(),
      );
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _escolas = List<Map<String, dynamic>>.from(
            jsonDecode(utf8.decode(res.bodyBytes)),
          );
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _carregarProfessores(int escolaId) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiClient.baseDomain}/funcionario?escolaId=$escolaId'),
        headers: await ApiClient.getHeaders(),
      );
      if (res.statusCode == 200 && mounted) {
        final lista = List<Map<String, dynamic>>.from(
          jsonDecode(utf8.decode(res.bodyBytes)),
        );
        setState(() {
          // Filtra apenas professores
          _professores = lista.where((f) => f['role'] == 'PROFESSOR').toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _abrirConversa(String tipo, {int? professorId}) async {
    if (_escolaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a escola primeiro.')),
      );
      return;
    }

    try {
      final body = {
        'tipo': tipo,
        'escolaId': _escolaSelecionada!['id'],
        if (professorId != null) 'professorId': professorId,
      };

      final res = await http.post(
        Uri.parse('$_base/conversas/iniciar'),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 && mounted) {
        final conversa = Map<String, dynamic>.from(jsonDecode(res.body));

        final titulo = tipo == 'PROFESSOR' && professorId != null
            ? _professores.firstWhere(
                (p) => p['id'] == professorId,
                orElse: () => {'nome': 'Professor'},
              )['nome']
            : _labelCanal(tipo);

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConversaScreen(
              conversaId: conversa['id'],
              titulo: titulo,
              subtitulo: _escolaSelecionada!['nome'],
              meuId: _meuId ?? 0,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova mensagem'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Selecionar escola
                const Text(
                  'Com qual escola você quer falar?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: _escolaSelecionada,
                  hint: const Text('Selecione a escola'),
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: _escolas.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(e['nome'], overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (e) {
                    setState(() {
                      _escolaSelecionada = e;
                      _professores = [];
                    });
                    if (e != null) _carregarProfessores(e['id']);
                  },
                ),

                if (_escolaSelecionada != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Com quem você quer falar?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  // Canal: Secretaria
                  _opcaoCanal(
                    'Secretaria',
                    'Documentos, matrículas, dados cadastrais',
                    Icons.admin_panel_settings_outlined,
                    Colors.blue,
                    () => _abrirConversa('SECRETARIA'),
                  ),

                  // Canal: Coordenação
                  _opcaoCanal(
                    'Coordenação',
                    'Desempenho, comportamento e assuntos pedagógicos',
                    Icons.school_outlined,
                    Colors.purple,
                    () => _abrirConversa('COORDENACAO'),
                  ),

                  // Canal: Professor (expandível)
                  if (_professores.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        'Professores',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ..._professores.map(
                      (prof) => _opcaoCanal(
                        prof['nome'],
                        prof['cargo'] ?? 'Professor',
                        Icons.person_outline,
                        Colors.teal,
                        () => _abrirConversa(
                          'PROFESSOR',
                          professorId: prof['id'],
                        ),
                      ),
                    ),
                  ] else if (_escolaSelecionada != null)
                    _opcaoCanal(
                      'Professor',
                      'Carregando professores...',
                      Icons.person_outline,
                      Colors.teal,
                      null,
                    ),
                ],
              ],
            ),
    );
  }

  Widget _opcaoCanal(
    String titulo,
    String subtitulo,
    IconData icon,
    Color cor,
    VoidCallback? onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor.withOpacity(0.12),
          child: Icon(icon, color: cor, size: 20),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitulo, style: const TextStyle(fontSize: 12)),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
        onTap: onTap,
      ),
    );
  }

  String _labelCanal(String tipo) => switch (tipo) {
    'SECRETARIA' => 'Secretaria',
    'COORDENACAO' => 'Coordenação',
    'PROFESSOR' => 'Professor',
    _ => tipo,
  };
}
