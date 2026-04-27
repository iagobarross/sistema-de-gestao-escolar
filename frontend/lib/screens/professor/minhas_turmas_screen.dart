import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/matriz_curricular.dart';
import 'package:gestao_escolar_app/screens/professor/diario_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class MinhasTurmasScreen extends StatefulWidget {
  const MinhasTurmasScreen({super.key});

  @override
  State<MinhasTurmasScreen> createState() => _MinhasTurmasScreenState();
}

class _MinhasTurmasScreenState extends State<MinhasTurmasScreen> {
  late Future<List<MatrizCurricular>> _futureMatrizes;
  final int _anoAtual = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    // FIX: bloco {} garante que o callback retorna void, não Future.
    setState(() {
      _futureMatrizes = _buscarMatrizes();
    });
  }

  Future<List<MatrizCurricular>> _buscarMatrizes() async {
    final id = await AuthService().getId();
    if (id == null) throw Exception('Usuário não autenticado');

    final res = await http.get(
      Uri.parse(
        '${ApiClient.baseDomain}/matriz-curricular/professor/$id?ano=$_anoAtual',
      ),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      final List lista = jsonDecode(utf8.decode(res.bodyBytes));
      return lista.map((j) => MatrizCurricular.fromJson(j)).toList();
    }
    throw Exception('Erro ao carregar turmas: ${res.statusCode}');
  }

  // Agrupa as matrizes por nome de turma para exibição organizada
  Map<String, List<MatrizCurricular>> _agruparPorTurma(
    List<MatrizCurricular> lista,
  ) {
    final Map<String, List<MatrizCurricular>> mapa = {};
    for (final m in lista) {
      mapa.putIfAbsent(m.nomeTurma, () => []).add(m);
    }
    return mapa;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<MatrizCurricular>>(
        future: _futureMatrizes,
        builder: (ctx, snap) {
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
                  Text(
                    '${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
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

          final matrizes = snap.data ?? [];
          if (matrizes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 56,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma turma vinculada em $_anoAtual.',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }

          final grupos = _agruparPorTurma(matrizes);

          return RefreshIndicator(
            onRefresh: () async => _carregar(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: grupos.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.groups,
                            size: 15,
                            color: AppTheme.professorColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.professorColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...entry.value.map((m) => _cartaoMatriz(ctx, m)),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _cartaoMatriz(BuildContext ctx, MatrizCurricular m) {
    final pct = m.cargaHorariaTotal > 0
        ? (m.aulasRealizadas / m.cargaHorariaTotal).clamp(0.0, 1.0)
        : 0.0;
    final ativa = m.status == 'ATIVA';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => DiarioScreen(matriz: m)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      m.nomeDisciplina,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!ativa)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ENCERRADA',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Barra de progresso das aulas
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: AppTheme.professorColor.withOpacity(0.12),
                  color: AppTheme.professorColor,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${m.aulasRealizadas} de ${m.cargaHorariaTotal} aulas',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(pct * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.professorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
