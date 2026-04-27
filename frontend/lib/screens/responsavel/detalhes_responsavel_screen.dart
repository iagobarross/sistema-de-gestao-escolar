import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/responsavel.dart';
import 'package:gestao_escolar_app/screens/aluno/detalhes_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/responsavel/form_responsavel_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/responsavel_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class DetalhesResponsavelScreen extends StatefulWidget {
  final int responsavelId;
  const DetalhesResponsavelScreen({super.key, required this.responsavelId});

  @override
  State<DetalhesResponsavelScreen> createState() =>
      _DetalhesResponsavelScreenState();
}

class _DetalhesResponsavelScreenState extends State<DetalhesResponsavelScreen> {
  Responsavel? _responsavel;
  List<Map<String, dynamic>> _alunos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      // Busca perfil do responsável e seus alunos em paralelo
      final results = await Future.wait([
        ResponsavelService().getResponsavelById(widget.responsavelId),
        http.get(
          Uri.parse(
            '${ApiClient.baseDomain}/aluno?responsavelId=${widget.responsavelId}&size=50',
          ),
          headers: await ApiClient.getHeaders(),
        ),
      ]);

      final responsavel = results[0] as Responsavel;
      final resAlunos = results[1] as http.Response;

      List<Map<String, dynamic>> alunos = [];
      if (resAlunos.statusCode == 200) {
        final body = jsonDecode(utf8.decode(resAlunos.bodyBytes));
        alunos = List<Map<String, dynamic>>.from(body['content'] ?? []);
      }

      if (mounted) {
        setState(() {
          _responsavel = responsavel;
          _alunos = alunos;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _deletar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir responsável'),
        content: const Text(
          'Atenção: só é possível excluir responsáveis sem alunos vinculados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ResponsavelService().deleteResponsavel(widget.responsavelId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // ── AppBar expandido ──────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 160,
                  pinned: true,
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  actions: [
                    if (_responsavel != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () async {
                          final ok = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormResponsavelScreen(
                                responsavelParaEditar: _responsavel,
                              ),
                            ),
                          );
                          if (ok == true) _carregar();
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _deletar,
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00695C), Color(0xFF26A69A)],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                          child: _responsavel == null
                              ? const SizedBox()
                              : Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white.withOpacity(
                                        0.25,
                                      ),
                                      child: Text(
                                        _responsavel!.nome[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _responsavel!.nome,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_alunos.length} aluno${_alunos.length != 1 ? 's' : ''} vinculado${_alunos.length != 1 ? 's' : ''}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Conteúdo ──────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Card de dados pessoais
                      _card('Dados de contato', [
                        _row(
                          Icons.email_outlined,
                          'E-mail',
                          _responsavel!.email,
                        ),
                        _row(
                          Icons.phone_outlined,
                          'Telefone',
                          _responsavel?.telefone ?? '—',
                        ),
                        _row(
                          Icons.badge_outlined,
                          'CPF',
                          _formataStr(_responsavel!.cpf, 11),
                        ),
                      ]),

                      const SizedBox(height: 16),

                      // Card de alunos vinculados
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'ALUNOS VINCULADOS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_alunos.length}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              if (_alunos.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: Text(
                                      'Nenhum aluno vinculado.',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ..._alunos.map(
                                  (a) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: AppTheme.primary
                                          .withOpacity(0.1),
                                      child: Text(
                                        (a['nome'] as String)[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      a['nome'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'RA: ${a['matricula']}  ·  ${a['nomeEscola'] ?? ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetalhesAlunoScreen(
                                          alunoId: a['id'],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  // Formata strings longas com separadores visuais (ex: CPF)
  String _formataStr(String s, int len) {
    if (s.length != len) return s;
    // CPF: 000.000.000-00
    if (len == 11) {
      return '${s.substring(0, 3)}.${s.substring(3, 6)}.${s.substring(6, 9)}-${s.substring(9)}';
    }
    return s;
  }

  Widget _card(String titulo, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const Divider(height: 16),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
