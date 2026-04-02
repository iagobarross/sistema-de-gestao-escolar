import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/escola.dart';
import 'package:gestao_escolar_app/screens/aluno/lista_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/turma/lista_turmas_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class EscolaHubScreen extends StatefulWidget {
  final Escola escola;
  final bool podeGerenciar;

  const EscolaHubScreen({
    required this.escola,
    this.podeGerenciar = true,
    super.key,
  });

  @override
  State<EscolaHubScreen> createState() => _EscolaHubScreenState();
}

class _EscolaHubScreenState extends State<EscolaHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _totalAlunos = 0;
  int _totalTurmas = 0;
  int _totalFuncionarios = 0;
  bool _carregandoStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarStats() async {
    try {
      final results = await Future.wait([
        http.get(
          Uri.parse(
            '${ApiClient.baseDomain}/aluno?size=1&escolaId=${widget.escola.id}',
          ),
          headers: await ApiClient.getHeaders(),
        ),
        http.get(
          Uri.parse('${ApiClient.baseDomain}/turma'),
          headers: await ApiClient.getHeaders(),
        ),
        http.get(
          Uri.parse('${ApiClient.baseDomain}/funcionario'),
          headers: await ApiClient.getHeaders(),
        ),
      ]);

      if (!mounted) return;
      setState(() {
        _totalAlunos = results[0].statusCode == 200
            ? jsonDecode(results[0].body)['totalElements'] ?? 0
            : 0;
        _totalTurmas = results[1].statusCode == 200
            ? (jsonDecode(results[1].body) as List).length
            : 0;
        _totalFuncionarios = results[2].statusCode == 200
            ? (jsonDecode(utf8.decode(results[2].bodyBytes)) as List)
                  .where((f) => f['escolaId'] == widget.escola.id)
                  .length
            : 0;
        _carregandoStats = false;
      });
    } catch (_) {
      if (mounted) setState(() => _carregandoStats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge com o código
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.escola.codigo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.escola.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white70,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.escola.endereco,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // KPIs rápidos
                        if (!_carregandoStats)
                          Row(
                            children: [
                              _statChip(
                                '$_totalAlunos',
                                'alunos',
                                Icons.person,
                              ),
                              const SizedBox(width: 8),
                              _statChip(
                                '$_totalTurmas',
                                'turmas',
                                Icons.groups,
                              ),
                              const SizedBox(width: 8),
                              _statChip(
                                '$_totalFuncionarios',
                                'funcionários',
                                Icons.badge,
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
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.person_outlined, size: 18),
                  text: 'Alunos',
                ),
                Tab(
                  icon: Icon(Icons.groups_outlined, size: 18),
                  text: 'Turmas',
                ),
                Tab(
                  icon: Icon(Icons.badge_outlined, size: 18),
                  text: 'Funcionários',
                ),
              ],
            ),
          ),
        ],

        // ── Conteúdo das abas ──────────────────────────────────────────────
        body: TabBarView(
          controller: _tabController,
          children: [
            // Aba Alunos: filtrada pela escola
            ListaAlunoScreen(
              escolaIdFiltro: widget.escola.id,
              podeCadastrar: widget.podeGerenciar,
            ),

            ListaTurmaScreen(podeCadastrar: widget.podeGerenciar),

            _FuncionariosTab(
              escolaId: widget.escola.id,
              podeGerenciar: widget.podeGerenciar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String valor, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(
            '$valor $label',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FuncionariosTab extends StatefulWidget {
  final int escolaId;
  final bool podeGerenciar;

  const _FuncionariosTab({required this.escolaId, required this.podeGerenciar});

  @override
  State<_FuncionariosTab> createState() => _FuncionariosTabState();
}

class _FuncionariosTabState extends State<_FuncionariosTab> {
  late Future<List<Map<String, dynamic>>> _futureFuncionarios;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futureFuncionarios = _buscar();
    });
  }

  Future<List<Map<String, dynamic>>> _buscar() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/funcionario'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar funcionários');
    final lista = List<Map<String, dynamic>>.from(
      jsonDecode(utf8.decode(res.bodyBytes)),
    );
    return lista.where((f) => f['escolaId'] == widget.escolaId).toList();
  }

  Color _cargoColor(String cargo) => switch (cargo) {
    'DIRETOR' => AppTheme.diretorColor,
    'COORDENADOR' => AppTheme.coordenadorColor,
    'SECRETARIA' => AppTheme.secretariaColor,
    'PROFESSOR' => AppTheme.professorColor,
    _ => AppTheme.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureFuncionarios,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }

          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum funcionário cadastrado nesta escola.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _carregar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final f = lista[i];
                final cargo = f['cargo'] as String? ?? '';
                final cor = _cargoColor(cargo);
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: cor.withOpacity(0.12),
                      child: Text(
                        (f['nome'] as String)[0].toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cor,
                        ),
                      ),
                    ),
                    title: Text(
                      f['nome'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      f['email'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: cor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cargo,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: cor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
