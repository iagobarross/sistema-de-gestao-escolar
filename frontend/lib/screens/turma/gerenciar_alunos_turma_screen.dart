import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aluno.dart';
import 'package:gestao_escolar_app/services/aluno_service.dart';
import 'package:gestao_escolar_app/services/turma_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class GerenciarAlunosTurmaScreen extends StatefulWidget {
  final int turmaId;
  const GerenciarAlunosTurmaScreen({super.key, required this.turmaId});

  @override
  State<GerenciarAlunosTurmaScreen> createState() =>
      _GerenciarAlunosTurmaScreenState();
}

class _GerenciarAlunosTurmaScreenState
    extends State<GerenciarAlunosTurmaScreen> {
  final TurmaService _turmaService = TurmaService();
  final AlunoService _alunoService = AlunoService();

  bool _carregando = true;
  String? _erro;
  List<Aluno> _alunosNaTurma = [];
  List<Aluno> _alunosDisponiveis = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    // FIX: setState apenas com bool, nunca com Future.
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final alunosNaTurma = await _turmaService.getAlunosByTurma(
        widget.turmaId,
      );

      final alunosMap = await _alunoService.getAlunos(page: 0, size: 200);
      final listaJson = (alunosMap['content'] as List<dynamic>);
      final todosAlunos = listaJson
          .map((json) => Aluno.fromJson(json as Map<String, dynamic>))
          .toList();

      final idsNaTurma = alunosNaTurma.map((a) => a.id).toSet();
      final disponiveis = todosAlunos
          .where((a) => !idsNaTurma.contains(a.id))
          .toList();

      setState(() {
        _alunosNaTurma = alunosNaTurma;
        _alunosDisponiveis = disponiveis;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _carregando = false;
        _erro = e.toString();
      });
    }
  }

  Future<void> _adicionar(int alunoId) async {
    try {
      await _turmaService.adicionarAlunoNaTurma(widget.turmaId, alunoId);
      setState(() => _hasChanges = true);
      await _carregarDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _remover(int alunoId) async {
    try {
      await _turmaService.removerAlunoDaTurma(widget.turmaId, alunoId);
      setState(() => _hasChanges = true);
      await _carregarDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aluno removido da turma.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Navigator.of(context).pop(_hasChanges);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          title: const Text('Gerenciar alunos'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_hasChanges),
          ),
        ),
        body: _carregando
            ? const Center(child: CircularProgressIndicator())
            : _erro != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _erro!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _carregarDados,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // ── Matriculados ─────────────────────────────────
                  _cabecalhoSecao(
                    'Matriculados (${_alunosNaTurma.length})',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                  Expanded(
                    flex: 1,
                    child: _alunosNaTurma.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum aluno nesta turma.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _alunosNaTurma.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final a = _alunosNaTurma[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  child: Text(
                                    a.nome[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(a.nome),
                                subtitle: Text(
                                  'RA: ${a.matricula}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Remover da turma',
                                  onPressed: () => _remover(a.id),
                                ),
                              );
                            },
                          ),
                  ),

                  const Divider(height: 1, thickness: 2),

                  // ── Disponíveis ──────────────────────────────────
                  _cabecalhoSecao(
                    'Disponíveis (${_alunosDisponiveis.length})',
                    Icons.person_add_alt,
                    AppTheme.primary,
                  ),
                  Expanded(
                    flex: 1,
                    child: _alunosDisponiveis.isEmpty
                        ? const Center(
                            child: Text(
                              'Todos os alunos já estão nesta turma.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _alunosDisponiveis.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final a = _alunosDisponiveis[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  child: Text(
                                    a.nome[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(a.nome),
                                subtitle: Text(
                                  'RA: ${a.matricula}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppTheme.primary,
                                  ),
                                  tooltip: 'Adicionar à turma',
                                  onPressed: () => _adicionar(a.id),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _cabecalhoSecao(String titulo, IconData icon, Color cor) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cor),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
