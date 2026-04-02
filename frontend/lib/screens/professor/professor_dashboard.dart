import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/professor/chamada_hoje_screen.dart';
import 'package:gestao_escolar_app/screens/professor/minhas_turmas_screen.dart';
import 'package:gestao_escolar_app/screens/chat/lista_conversas_screen.dart';
import 'package:gestao_escolar_app/widgets/main_shell.dart';

class ProfessorDashboard extends StatelessWidget {
  const ProfessorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShell(
      titulo: 'Portal do Professor',
      role: 'PROFESSOR',
      items: [
        NavItem(
          label: 'Chamada de Hoje',
          icon: Icons.checklist_outlined,
          page: ChamadaHojeScreen(),
        ),
        NavItem(
          label: 'Minhas Turmas',
          icon: Icons.groups_outlined,
          page: MinhasTurmasScreen(),
        ),
        NavItem(
          label: 'Mensagens',
          icon: Icons.chat_bubble_outline,
          page: ListaConversasScreen(),
        ),
      ],
    );
  }

  /*
  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
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
            const Text('Painel do Professor'),
            Text(
              'Olá, $_nomeUsuario',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [_logoutButton(context)],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        children: [
          _card(
            context,
            'Chamada de hoje',
            Icons.checklist,
            Colors.teal,
            ChamadaHojeScreen(),
          ),
          _card(
            context,
            'Minhas turmas',
            Icons.groups,
            Colors.blue,
            MinhasTurmasScreen(),
          ),
          _card(
            context,
            'Mensagens',
            Icons.chat_bubble_outline,
            Colors.purple,
            ListaConversasScreen(),
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            Navigator.push(ctx, MaterialPageRoute(builder: (_) => destino)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: cor),
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
  );*/
}
