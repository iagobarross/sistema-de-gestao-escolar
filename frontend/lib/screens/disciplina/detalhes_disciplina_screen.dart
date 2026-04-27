import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/disciplina.dart';
import 'package:gestao_escolar_app/screens/disciplina/form_disciplina_screen.dart';
import 'package:gestao_escolar_app/services/disciplina_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class DetalhesDisciplinaScreen extends StatefulWidget {
  final int disciplinaId;
  const DetalhesDisciplinaScreen({super.key, required this.disciplinaId});

  @override
  State<DetalhesDisciplinaScreen> createState() =>
      _DetalhesDisciplinaScreenState();
}

class _DetalhesDisciplinaScreenState extends State<DetalhesDisciplinaScreen> {
  Disciplina? _disciplina;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _carregando = true;
      DisciplinaService()
          .getDisciplinaById(widget.disciplinaId)
          .then((d) {
            if (mounted)
              setState(() {
                _disciplina = d;
                _carregando = false;
              });
          })
          .catchError((_) {
            if (mounted) setState(() => _carregando = false);
          });
    });
  }

  Future<void> _deletar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir disciplina'),
        content: const Text(
          'Atenção: só é possível excluir disciplinas que não estejam vinculadas a nenhuma turma.',
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
      await DisciplinaService().deleteDisciplina(widget.disciplinaId);
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
          : _disciplina == null
          ? const Center(child: Text('Disciplina não encontrada.'))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 140,
                  pinned: true,
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final ok = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FormDisciplinaScreen(
                              disciplinaParaEditar: _disciplina,
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
                          colors: [Color(0xFF4527A0), Color(0xFF7B1FA2)],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    _disciplina!.codigo.length > 3
                                        ? _disciplina!.codigo.substring(0, 3)
                                        : _disciplina!.codigo,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _disciplina!.nome,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Código: ${_disciplina!.codigo}',
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

                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Descrição
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DESCRIÇÃO',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Divider(height: 16),
                              Text(
                                _disciplina!.descricao,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Parâmetros acadêmicos
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      color: Colors.deepPurple,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _disciplina!.notaMinima.toStringAsFixed(
                                        1,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const Text(
                                      'Nota mínima',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.access_time_outlined,
                                      color: Colors.teal,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_disciplina!.cargaHoraria}h',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const Text(
                                      'Carga horária',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}
