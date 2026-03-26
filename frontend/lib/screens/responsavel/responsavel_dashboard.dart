import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/chat/lista_conversas_screen.dart';
import 'package:gestao_escolar_app/screens/responsavel/boletim_screen.dart';
import 'package:gestao_escolar_app/screens/responsavel/comunicados_screen.dart';
import 'package:gestao_escolar_app/screens/responsavel/frequencia_aluno_screen.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/screens/login_screen.dart';

class ResponsavelDashboard extends StatelessWidget {
  const ResponsavelDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhamento Escolar'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [_logoutButton(context)],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _card(
            context,
            'Boletim',
            Icons.assignment,
            Colors.blue,
            const BoletimScreen(),
          ),
          _card(
            context,
            'Frequência',
            Icons.calendar_today,
            Colors.green,
            const FrequenciaAlunoScreen(),
          ),
          _card(
            context,
            'Mensagens',
            Icons.chat_bubble_outline,
            Colors.purple,
            const ListaConversasScreen(),
          ),
          _card(
            context,
            'Comunicados',
            Icons.notifications,
            Colors.orange,
            const ComunicadosScreen(),
          ),
        ],
      ),
    );
  }

  Widget _card(
    BuildContext ctx,
    String titulo,
    IconData icon,
    Color cor,
    Widget destino,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => destino)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: cor),
            const SizedBox(height: 10),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
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
