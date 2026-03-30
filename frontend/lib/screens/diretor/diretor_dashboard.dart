import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/aluno/lista_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/escola/lista_escola_screen.dart';
import 'package:gestao_escolar_app/screens/turma/lista_turmas_screen.dart';
import 'package:gestao_escolar_app/screens/chat/lista_conversas_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import '../chat/lista_conversas_screen.dart';

class DiretorDashboard extends StatefulWidget {
  const DiretorDashboard({super.key});

  @override
  State<DiretorDashboard> createState() => _DiretorDashboardState();
}

class _DiretorDashboardState extends State<DiretorDashboard> {
  String _nomeUsuario = '';
  Map<String, dynamic>? _resumo;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final nome = await AuthService().getNome();
    final payload = await AuthService().getPayload();
    final escolaId = payload?['escolaId'];

    setState(() => _nomeUsuario = nome ?? '');

    if (escolaId == null) {
      setState(() => _carregando = false);
      return;
    }

    try {
      final resAlunos = await http.get(
        Uri.parse('${ApiClient.baseDomain}/aluno?size=1&escolaId=$escolaId'),
        headers: await ApiClient.getHeaders(),
      );
      final resTurmas = await http.get(
        Uri.parse('${ApiClient.baseDomain}/turma'),
        headers: await ApiClient.getHeaders(),
      );
      final resFuncionarios = await http.get(
        Uri.parse('${ApiClient.baseDomain}/funcionario?escolaId=$escolaId'),
        headers: await ApiClient.getHeaders(),
      );

      if (mounted) {
        setState(() {
          _resumo = {
            'totalAlunos': resAlunos.statusCode == 200
                ? jsonDecode(resAlunos.body)['totalElements'] ?? 0
                : 0,
            'totalTurmas': resTurmas.statusCode == 200
                ? (jsonDecode(resTurmas.body) as List).length
                : 0,
            'totalFuncionarios': resFuncionarios.statusCode == 200
                ? (jsonDecode(resFuncionarios.body) as List).length
                : 0,
          };
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Painel da Direção'),
            Text(
              'Olá, $_nomeUsuario',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        actions: [_logoutButton(context)],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarDados,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_resumo != null) ...[
                    Row(
                      children: [
                        _kpiCard(
                          'Alunos',
                          '${_resumo!['totalAlunos']}',
                          Icons.person,
                          Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _kpiCard(
                          'Turmas',
                          '${_resumo!['totalTurmas']}',
                          Icons.groups,
                          Colors.teal,
                        ),
                        const SizedBox(width: 12),
                        _kpiCard(
                          'Funcionários',
                          '${_resumo!['totalFuncionarios']}',
                          Icons.badge,
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Text(
                    'Gestão escolar',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _menuItem(
                    context,
                    'Alunos',
                    'Visualizar todos os alunos',
                    Icons.person_outline,
                    Colors.blue,
                    ListaAlunoScreen(),
                  ),
                  _menuItem(
                    context,
                    'Turmas',
                    'Acompanhar turmas e séries',
                    Icons.groups_outlined,
                    Colors.teal,
                    ListaTurmaScreen(),
                  ),
                  _menuItem(
                    context,
                    'Escolas',
                    'Dados da unidade escolar',
                    Icons.school_outlined,
                    Colors.green,
                    ListaEscolaScreen(),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Comunicação',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _menuItem(
                    context,
                    'Mensagens',
                    'Caixa de entrada do setor',
                    Icons.chat_bubble_outline,
                    Colors.purple,
                    const ListaConversasScreen(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _kpiCard(String label, String valor, IconData icon, Color cor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: cor, size: 24),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    String titulo,
    String subtitulo,
    IconData icon,
    Color cor,
    Widget destino,
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
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => destino)),
      ),
    );
  }

  IconButton _logoutButton(BuildContext ctx) => IconButton(
    icon: const Icon(Icons.exit_to_app),
    onPressed: () async {
      await AuthService().logout();
      if (ctx.mounted) {
        Navigator.pushAndRemoveUntil(
          ctx,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (_) => false,
        );
      }
    },
  );
}
