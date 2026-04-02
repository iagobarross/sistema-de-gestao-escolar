import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/escola.dart';
import 'package:gestao_escolar_app/screens/escola/escola_hub_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/profile_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:gestao_escolar_app/widgets/charts.dart';
import 'package:http/http.dart' as http;

/// Tela de início do Diretor.
///
/// Exibe KPIs e gráficos da escola. Ao clicar em "Gerenciar escola"
/// navega para o EscolaHubScreen com as abas completas.
class ResumoEscolaScreen extends StatefulWidget {
  const ResumoEscolaScreen({super.key});

  @override
  State<ResumoEscolaScreen> createState() => _ResumoEscolaScreenState();
}

class _ResumoEscolaScreenState extends State<ResumoEscolaScreen> {
  bool _carregando = true;
  Escola? _escola;
  int _totalAlunos = 0;
  int _totalTurmas = 0;
  int _totalFuncionarios = 0;
  List<ChartData> _distribuicaoTurno = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final escolaId = await ProfileService.instance.getEscolaId();
      if (escolaId == null) {
        if (mounted) setState(() => _carregando = false);
        return;
      }

      final results = await Future.wait([
        http.get(
          Uri.parse('${ApiClient.baseDomain}/escola/$escolaId'),
          headers: await ApiClient.getHeaders(),
        ),
        http.get(
          Uri.parse('${ApiClient.baseDomain}/aluno?size=1&escolaId=$escolaId'),
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

      Escola? escola;
      if (results[0].statusCode == 200) {
        escola = Escola.fromJson(jsonDecode(results[0].body));
      }

      final totalAlunos = results[1].statusCode == 200
          ? jsonDecode(results[1].body)['totalElements'] ?? 0
          : 0;

      List<Map<String, dynamic>> turmas = [];
      if (results[2].statusCode == 200) {
        turmas = List<Map<String, dynamic>>.from(
          jsonDecode(utf8.decode(results[2].bodyBytes)),
        );
      }

      int totalFuncionarios = 0;
      if (results[3].statusCode == 200) {
        final funcs = List<Map<String, dynamic>>.from(
          jsonDecode(utf8.decode(results[3].bodyBytes)),
        );
        totalFuncionarios = funcs
            .where((f) => f['escolaId'] == escolaId)
            .length;
      }

      // Agrupamos turmas por turno para compor o gráfico de donut
      final Map<String, int> porTurno = {};
      for (final t in turmas) {
        final turno = t['turno'] as String? ?? 'Outro';
        porTurno[turno] = (porTurno[turno] ?? 0) + 1;
      }

      final cores = [Colors.orange, Colors.blue, Colors.indigo, Colors.teal];
      final chartData = porTurno.entries.toList().asMap().entries.map((e) {
        return ChartData(
          label: e.value.key,
          value: e.value.value.toDouble(),
          color: cores[e.key % cores.length],
        );
      }).toList();

      setState(() {
        _escola = escola;
        _totalAlunos = totalAlunos;
        _totalTurmas = turmas.length;
        _totalFuncionarios = totalFuncionarios;
        _distribuicaoTurno = chartData;
        _carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Cabeçalho clicável da escola ────────────────────────────────
          if (_escola != null)
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EscolaHubScreen(escola: _escola!, podeGerenciar: false),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school_outlined,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _escola!.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _escola!.endereco,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // ── KPIs ────────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  valor: '$_totalAlunos',
                  label: 'Alunos matriculados',
                  icon: Icons.person_outlined,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KpiCard(
                  valor: '$_totalTurmas',
                  label: 'Turmas ativas',
                  icon: Icons.groups_outlined,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          KpiCard(
            valor: '$_totalFuncionarios',
            label: 'Funcionários nesta unidade',
            icon: Icons.badge_outlined,
            color: Colors.orange,
          ),

          const SizedBox(height: 20),

          // ── Gráfico: distribuição por turno ─────────────────────────────
          if (_distribuicaoTurno.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Distribuição de turmas por turno',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DonutChart(
                      data: _distribuicaoTurno,
                      centerLabel: 'turmas\nno total',
                      centerValue: '$_totalTurmas',
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // ── Gráfico: barras horizontais por turno ───────────────────────
          if (_distribuicaoTurno.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: HorizontalBarChart(
                  titulo: 'Turmas por turno (quantidade)',
                  data: _distribuicaoTurno,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
