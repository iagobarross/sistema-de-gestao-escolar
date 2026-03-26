import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/aluno/lista_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/aluno/form_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/responsavel/lista_responsavel_screen.dart';
import 'package:gestao_escolar_app/screens/turma/lista_turmas_screen.dart';
import 'package:gestao_escolar_app/screens/chat/lista_conversas_screen.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/screens/login_screen.dart';

class SecretariaDashboard extends StatefulWidget {
  const SecretariaDashboard({super.key});

  @override
  State<SecretariaDashboard> createState() => _SecretariaDashboardState();
}

class _SecretariaDashboardState extends State<SecretariaDashboard> {
  String _nomeUsuario = '';

  @override
  void initState() {
    super.initState();
    AuthService().getNome().then((n) {
      if (mounted) setState(() => _nomeUsuario = n ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Secretaria Escolar'),
            Text(
              'Olá, $_nomeUsuario',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.cyan.shade800,
        foregroundColor: Colors.white,
        actions: [_logoutButton(context)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ação rápida: novo aluno
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.person_add),
              label: const Text(
                'Cadastrar novo aluno',
                style: TextStyle(fontSize: 15),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormAlunoScreen()),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Cadastros',
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
            'Pesquisar, editar e matricular',
            Icons.person_outline,
            Colors.blue,
            ListaAlunoScreen(),
          ),
          _menuItem(
            context,
            'Responsáveis',
            'Dados dos responsáveis',
            Icons.family_restroom_outlined,
            Colors.green,
            ListaResponsavelScreen(),
          ),
          _menuItem(
            context,
            'Turmas',
            'Consultar e gerenciar turmas',
            Icons.groups_outlined,
            Colors.teal,
            ListaTurmaScreen(),
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
            'Atendimento a responsáveis',
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
