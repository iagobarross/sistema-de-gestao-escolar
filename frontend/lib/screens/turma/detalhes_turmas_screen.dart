import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aluno.dart';
import 'package:gestao_escolar_app/models/turma.dart';
import 'package:gestao_escolar_app/screens/aluno/detalhes_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/turma/form_turmas_screen.dart';
import 'package:gestao_escolar_app/screens/turma/gerenciar_alunos_turma_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/turma_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:gestao_escolar_app/widgets/charts.dart';
import 'package:http/http.dart' as http;

class DetalhesTurmasScreen extends StatefulWidget {
  final int turmaId;
  const DetalhesTurmasScreen({super.key, required this.turmaId});

  @override
  State<DetalhesTurmasScreen> createState() => _DetalhesTurmasScreenState();
}

class _DetalhesTurmasScreenState extends State<DetalhesTurmasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Turma? _turma;
  List<Aluno> _alunos = [];
  List<Map<String, dynamic>> _matrizes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final ano = DateTime.now().year;
      final results = await Future.wait([
        TurmaService().getTurmaById(widget.turmaId),
        TurmaService().getAlunosByTurma(widget.turmaId),
        http.get(
          Uri.parse(
            '${ApiClient.baseDomain}/matriz-curricular?turmaId=${widget.turmaId}&ano=$ano',
          ),
          headers: await ApiClient.getHeaders(),
        ),
      ]);

      final turma = results[0] as Turma;
      final alunos = results[1] as List<Aluno>;
      final resMatrizes = results[2] as http.Response;

      List<Map<String, dynamic>> matrizes = [];
      if (resMatrizes.statusCode == 200) {
        matrizes = List<Map<String, dynamic>>.from(
          jsonDecode(utf8.decode(resMatrizes.bodyBytes)),
        );
      }

      if (mounted) {
        setState(() {
          _turma = turma;
          _alunos = alunos;
          _matrizes = matrizes;
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _deletar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir turma'),
        content: const Text('Deseja remover esta turma permanentemente?'),
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
      await TurmaService().deleteTurma(widget.turmaId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _turnoColor(String turno) {
    final t = turno.toLowerCase();
    if (t.contains('manhã') || t.contains('manha')) return Colors.orange;
    if (t.contains('tarde')) return Colors.blue;
    if (t.contains('noit')) return Colors.indigo;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_turma == null) {
      return const Scaffold(body: Center(child: Text('Turma não encontrada.')));
    }

    final cor = _turnoColor(_turma!.turno);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: cor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final ok = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FormTurmaScreen(turmaParaEditar: _turma),
                    ),
                  );
                  if (ok == true) _carregar();
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_add_outlined),
                tooltip: 'Gerenciar alunos',
                onPressed: () async {
                  final ok = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GerenciarAlunosTurmaScreen(turmaId: widget.turmaId),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cor.withOpacity(0.9), cor]),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_turma!.serie}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _chip(Icons.wb_sunny_outlined, _turma!.turno),
                            const SizedBox(width: 8),
                            _chip(
                              Icons.calendar_today_outlined,
                              '${_turma!.ano}',
                            ),
                            const SizedBox(width: 8),
                            _chip(
                              Icons.people_outlined,
                              '${_alunos.length} alunos',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(
                  icon: const Icon(Icons.person_outlined, size: 18),
                  text: 'Alunos (${_alunos.length})',
                ),
                Tab(
                  icon: const Icon(Icons.book_outlined, size: 18),
                  text: 'Disciplinas (${_matrizes.length})',
                ),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // Aba Alunos
            _alunos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum aluno matriculado.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _alunos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final a = _alunos[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            child: Text(
                              a.nome[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            a.nome,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'RA: ${a.matricula}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right, size: 18),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetalhesAlunoScreen(alunoId: a.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

            // Aba Disciplinas
            _matrizes.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma disciplina na matriz curricular.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      // Gráfico de carga horária por disciplina
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: HorizontalBarChart(
                            titulo: 'Aulas realizadas / Carga horária',
                            data: _matrizes
                                .map(
                                  (m) => ChartData(
                                    label: m['nomeDisciplina'] as String,
                                    value: (m['aulasRealizadas'] as num)
                                        .toDouble(),
                                    color: m['status'] == 'ATIVA'
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._matrizes.map((m) {
                        final ativo = m['status'] == 'ATIVA';
                        final realizadas = (m['aulasRealizadas'] as num)
                            .toInt();
                        final total = (m['cargaHorariaTotal'] as num).toInt();
                        final pct = total > 0
                            ? (realizadas / total).clamp(0.0, 1.0)
                            : 0.0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        m['nomeDisciplina'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ativo
                                            ? Colors.green.withOpacity(0.12)
                                            : Colors.grey.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        m['status'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: ativo
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Prof. ${m['nomeProfessor']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 6,
                                    backgroundColor: Colors.green.withOpacity(
                                      0.12,
                                    ),
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$realizadas de $total aulas (${(pct * 100).toInt()}%)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String texto) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 12),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    ),
  );
}
