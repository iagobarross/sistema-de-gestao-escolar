import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/turma.dart';
import 'package:gestao_escolar_app/services/turma_service.dart';
import 'package:gestao_escolar_app/screens/turma/form_turmas_screen.dart';
import 'package:gestao_escolar_app/screens/turma/detalhes_turmas_screen.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class ListaTurmaScreen extends StatefulWidget {
  /// Quando false, oculta o FAB de criação de turmas.
  final bool podeCadastrar;

  const ListaTurmaScreen({this.podeCadastrar = true, super.key});

  @override
  State<ListaTurmaScreen> createState() => _ListaTurmaScreenState();
}

class _ListaTurmaScreenState extends State<ListaTurmaScreen> {
  final TurmaService _service = TurmaService();
  late Future<List<Turma>> _futureTurmas;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    // FIX: bloco {} garante retorno void no callback do setState.
    setState(() {
      _futureTurmas = _service.getTurmas();
    });
  }

  Future<void> _deletar(int id, String nome) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir turma'),
        content: Text('Deseja excluir a turma "$nome"?'),
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
    if (ok != true) return;
    try {
      await _service.deleteTurma(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Turma excluída')));
        _carregar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Map<String, List<Turma>> _agrupar(List<Turma> turmas) {
    final Map<String, List<Turma>> mapa = {};
    for (final t in turmas) {
      mapa.putIfAbsent(t.serie, () => []).add(t);
    }
    return mapa;
  }

  Color _turnoColor(String turno) {
    final t = turno.toLowerCase();
    if (t.contains('manhã') || t.contains('manha')) return Colors.orange;
    if (t.contains('tarde')) return Colors.blue;
    if (t.contains('noit')) return Colors.indigo;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Turma>>(
        future: _futureTurmas,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text('${snap.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _carregar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final turmas = snap.data ?? [];
          if (turmas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 56,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhuma turma cadastrada.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          final grupos = _agrupar(turmas);

          return RefreshIndicator(
            onRefresh: () async => _carregar(),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: grupos.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        top: 8,
                        bottom: 6,
                      ),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    ...entry.value.map((turma) {
                      final cor = _turnoColor(turma.turno);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              turma.turno[0].toUpperCase(),
                              style: TextStyle(
                                color: cor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          title: Text(
                            '${turma.serie} — ${turma.turno}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Ano letivo: ${turma.ano}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (v) async {
                              if (v == 'ver') {
                                final ok = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DetalhesTurmasScreen(turmaId: turma.id),
                                  ),
                                );
                                if (ok == true) _carregar();
                              } else if (v == 'del') {
                                _deletar(
                                  turma.id,
                                  '${turma.serie} ${turma.turno}',
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'ver',
                                child: Text('Ver detalhes'),
                              ),
                              if (widget.podeCadastrar)
                                const PopupMenuItem(
                                  value: 'del',
                                  child: Text(
                                    'Excluir',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () async {
                            final ok = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetalhesTurmasScreen(turmaId: turma.id),
                              ),
                            );
                            if (ok == true) _carregar();
                          },
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: widget.podeCadastrar
          ? FloatingActionButton.extended(
              onPressed: () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const FormTurmaScreen()),
                );
                if (ok == true) _carregar();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova turma'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
