import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aluno.dart';
import 'package:gestao_escolar_app/services/aluno_service.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/screens/aluno/form_alunos_screen.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:gestao_escolar_app/widgets/charts.dart';
import 'package:http/http.dart' as http;

class DetalhesAlunoScreen extends StatefulWidget {
  final int alunoId;
  const DetalhesAlunoScreen({super.key, required this.alunoId});

  @override
  State<DetalhesAlunoScreen> createState() => _DetalhesAlunoScreenState();
}

class _DetalhesAlunoScreenState extends State<DetalhesAlunoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Aluno> _futureAluno;
  late Future<List<dynamic>> _futureBoletim;

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

  void _carregar() {
    setState(() {
      _futureAluno = AlunoService().getAlunoById(widget.alunoId);
      _futureBoletim = _buscarBoletim();
    });
  }

  Future<List<dynamic>> _buscarBoletim() async {
    final ano = DateTime.now().year;
    final res = await http.get(
      Uri.parse(
        '${ApiClient.baseDomain}/nota/boletim/${widget.alunoId}?ano=$ano',
      ),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as List;
    }
    return [];
  }

  Future<void> _deletar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir aluno'),
        content: const Text(
          'Esta ação removerá o aluno permanentemente. Deseja continuar?',
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
      await AlunoService().deleteAluno(widget.alunoId);
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
    return FutureBuilder<Aluno>(
      future: _futureAluno,
      builder: (context, snap) {
        final aluno = snap.data;

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                actions: [
                  if (aluno != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Editar',
                      onPressed: () async {
                        final ok = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FormAlunoScreen(alunoParaEditar: aluno),
                          ),
                        );
                        if (ok == true) _carregar();
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Excluir',
                    onPressed: _deletar,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                        child: snap.hasData
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.25,
                                    ),
                                    child: Text(
                                      aluno!.nome[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          aluno.nome,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _chip('RA: ${aluno.matricula}'),
                                        const SizedBox(height: 4),
                                        _chip(aluno.nomeEscola),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  tabs: const [
                    Tab(text: 'Perfil'),
                    Tab(text: 'Boletim'),
                  ],
                ),
              ),
            ],
            body: snap.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : snap.hasError
                ? Center(child: Text('Erro: ${snap.error}'))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _PerfilTab(aluno: aluno!),
                      _BoletimTab(futureBoletim: _futureBoletim),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _chip(String texto) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      texto,
      style: const TextStyle(color: Colors.white, fontSize: 11),
    ),
  );
}

// ─── Aba Perfil ──────────────────────────────────────────────────────────────

class _PerfilTab extends StatelessWidget {
  final Aluno aluno;
  const _PerfilTab({required this.aluno});

  @override
  Widget build(BuildContext context) {
    final idade = DateTime.now().year - aluno.dataNascimento.year;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _section('Dados pessoais', [
          _row(Icons.person_outlined, 'Nome', aluno.nome),
          _row(Icons.email_outlined, 'E-mail', aluno.email),
          _row(
            Icons.cake_outlined,
            'Data de nascimento',
            '${aluno.dataNascimento.day.toString().padLeft(2, '0')}/${aluno.dataNascimento.month.toString().padLeft(2, '0')}/${aluno.dataNascimento.year}  ($idade anos)',
          ),
        ]),
        const SizedBox(height: 16),
        _section('Vínculo escolar', [
          _row(Icons.school_outlined, 'Escola', aluno.nomeEscola),
          _row(Icons.badge_outlined, 'Matrícula (RA)', aluno.matricula),
          _row(
            Icons.family_restroom_outlined,
            'Responsável',
            aluno.nomeResponsavel,
          ),
        ]),
        if (aluno.turmas.isNotEmpty) ...[
          const SizedBox(height: 16),
          _section(
            'Turmas matriculadas',
            aluno.turmas
                .map((t) => _row(Icons.groups_outlined, '', t))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _section(String titulo, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          if (label.isNotEmpty) ...[
            Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: label.isEmpty ? TextAlign.start : TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Aba Boletim ─────────────────────────────────────────────────────────────

class _BoletimTab extends StatelessWidget {
  final Future<List<dynamic>> futureBoletim;
  const _BoletimTab({required this.futureBoletim});

  Color _corSituacao(String s) => switch (s) {
    'APROVADO' => Colors.green,
    'RECUPERACAO' => Colors.orange,
    'REPROVADO' => Colors.red,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureBoletim,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final lista = snap.data ?? [];
        if (lista.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma nota lançada este ano.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }

        // Gráfico de médias por disciplina
        final chartData = lista
            .where((d) => d['mediaFinal'] != null)
            .map(
              (d) => ChartData(
                label: d['nomeDisciplina'] as String,
                value: (d['mediaFinal'] as num).toDouble(),
                color: (d['mediaFinal'] as num) >= (d['notaMinima'] as num)
                    ? Colors.green
                    : Colors.red,
              ),
            )
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (chartData.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: HorizontalBarChart(
                    titulo: 'Médias por disciplina',
                    data: chartData,
                    maxValue: 10,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ...lista.map((d) {
              final situacao = d['situacao'] as String? ?? 'SEM_DADOS';
              final cor = _corSituacao(situacao);
              final mf = d['mediaFinal'] != null
                  ? (d['mediaFinal'] as num).toStringAsFixed(1)
                  : '—';
              final pct = d['percentualPresenca'] != null
                  ? '${(d['percentualPresenca'] as num).toStringAsFixed(0)}%'
                  : '—';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              d['nomeDisciplina'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              situacao,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: cor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _nota('B1', d['mediaBimestre1']?.toString()),
                          _nota('B2', d['mediaBimestre2']?.toString()),
                          _nota('B3', d['mediaBimestre3']?.toString()),
                          _nota('B4', d['mediaBimestre4']?.toString()),
                          const Spacer(),
                          Column(
                            children: [
                              Text(
                                mf,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: cor,
                                ),
                              ),
                              const Text(
                                'Média final',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${d['faltas'] ?? 0} faltas de ${d['totalAulas'] ?? 0} aulas  ·  $pct presença',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _nota(String bim, String? valor) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Text(
            valor != null
                ? (double.tryParse(valor)?.toStringAsFixed(1) ?? valor)
                : '—',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            bim,
            style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
