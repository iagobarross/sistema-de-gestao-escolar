import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/escola.dart';
import 'package:gestao_escolar_app/screens/escola/escola_hub_screen.dart';
import 'package:gestao_escolar_app/services/escola_service.dart';

/// Mantido por compatibilidade. Navega para o EscolaHubScreen assim que
/// o dado da escola estiver disponível.
class DetalhesEscolaScreen extends StatefulWidget {
  final int escolaId;
  const DetalhesEscolaScreen({super.key, required this.escolaId});

  @override
  State<DetalhesEscolaScreen> createState() => _DetalhesEscolaScreenState();
}

class _DetalhesEscolaScreenState extends State<DetalhesEscolaScreen> {
  @override
  void initState() {
    super.initState();
    _redirecionar();
  }

  Future<void> _redirecionar() async {
    try {
      final Escola escola = await EscolaService().getEscolaById(
        widget.escolaId,
      );
      if (!mounted) return;
      // Substitui esta tela pelo hub, para que o botão voltar funcione
      // corretamente sem duplicar entradas na pilha de navegação.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => EscolaHubScreen(escola: escola)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar escola: $e')));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Exibe loading enquanto redireciona
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
