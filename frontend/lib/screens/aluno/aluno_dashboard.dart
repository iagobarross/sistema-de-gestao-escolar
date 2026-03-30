import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/responsavel/boletim_screen.dart';
import 'package:gestao_escolar_app/screens/responsavel/boletim_screen.dart';
import 'package:gestao_escolar_app/screens/chat/lista_conversas_screen.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/screens/login_screen.dart';
import '../chat/lista_conversas_screen.dart';

class AlunoDashboard extends StatefulWidget {
  const AlunoDashboard({super.key});

  @override
  State<AlunoDashboard> createState() => _AlunoDashboardState();
}

class _AlunoDashboardState extends State<AlunoDashboard> {
  String _nomeUsuario = '';
  int? _meuId;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final nome = await AuthService().getNome();
    final id = await AuthService().getId();
    if (mounted) {
      setState(() {
        _nomeUsuario = nome ?? '';
        _meuId = id;
      });
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
            const Text('Minha Escola'),
            Text(
              _nomeUsuario,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade800,
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
            'Meu boletim',
            Icons.assignment_outlined,
            Colors.blue,
            _meuId != null
                ? BoletimScreen(alunoId: _meuId!, nomeAluno: _nomeUsuario)
                : const SizedBox(),
          ),
          _card(
            context,
            'Mensagens',
            Icons.chat_bubble_outline,
            Colors.purple,
            const ListaConversasScreen(),
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
  );
}
