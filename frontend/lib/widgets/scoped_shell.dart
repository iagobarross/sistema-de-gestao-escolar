import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/profile_service.dart';
import 'package:gestao_escolar_app/widgets/main_shell.dart';

class ScopedShell extends StatefulWidget {
  final String titulo;
  final String role;
  final List<NavItem> Function(int? escolaId) itemsBuilder;

  const ScopedShell({
    required this.titulo,
    required this.role,
    required this.itemsBuilder,
    super.key,
  });

  @override
  State<ScopedShell> createState() => _ScopedShellState();
}

class _ScopedShellState extends State<ScopedShell> {
  int? _escolaId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final escolaId = await ProfileService.instance.getEscolaId();
    if (mounted) {
      setState(() {
        _escolaId = escolaId;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Mostra um scaffold mínimo enquanto o perfil carrega,
      // evitando flash de tela em branco.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainShell(
      titulo: widget.titulo,
      role: widget.role,
      items: widget.itemsBuilder(_escolaId),
    );
  }
}
