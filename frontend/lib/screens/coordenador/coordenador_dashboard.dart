import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/aluno/lista_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/chat/lista_conversas_screen.dart';
import 'package:gestao_escolar_app/screens/turma/lista_turmas_screen.dart';
import 'package:gestao_escolar_app/screens/disciplina/lista_disciplina_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/screens/login_screen.dart';
import 'package:http/http.dart' as http;

class CoordenadorDashboard extends StatefulWidget {
  const CoordenadorDashboard({super.key});

  @override
  State<CoordenadorDashboard> createState() => _CoordenadorDashboardState();
}

class _CoordenadorDashboardState extends State<CoordenadorDashboard> {
  String _nomeUsuario = '';

  @override
  void initState() {
    super.initState();
    _carregarNome();
  }

  Future<void> _carregarNome() async {
    final nome = await AuthService().getNome();
    if (mounted) setState(() => _nomeUsuario = nome ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Coordenação Pedagógica'),
            Text(
              'Olá, $_nomeUsuario',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        actions: [_logoutButton(context)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bloco de alertas — placeholder para a Fase 4 (IA)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Análise de desempenho por IA disponível na Fase 4.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Acompanhamento acadêmico',
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
            'Buscar e visualizar alunos',
            Icons.person_outline,
            Colors.blue,
            ListaAlunoScreen(),
          ),
          _menuItem(
            context,
            'Turmas',
            'Grade de turmas e séries',
            Icons.groups_outlined,
            Colors.teal,
            ListaTurmaScreen(),
          ),
          _menuItem(
            context,
            'Disciplinas',
            'Gerenciar disciplinas',
            Icons.book_outlined,
            Colors.orange,
            ListaDisciplinaScreen(),
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
            'Conversas com responsáveis',
            Icons.chat_bubble_outline,
            Colors.purple,
            const ListaConversasScreen(),
          ),
        ],
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
