import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aula.dart';
import 'package:gestao_escolar_app/screens/chamada/chamada_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class ChamadaHojeScreen extends StatefulWidget {
  const ChamadaHojeScreen({super.key});

  @override
  State<ChamadaHojeScreen> createState() => _ChamadaHojeScreenState();
}

class _ChamadaHojeScreenState extends State<ChamadaHojeScreen> {
  late Future<List<Aula>> _futureAulas;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futureAulas = _buscarAulasHoje();
    });
  }

  Future<List<Aula>> _buscarAulasHoje() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/aula/hoje'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      final List lista = jsonDecode(utf8.decode(res.bodyBytes));
      return lista.map((j) => Aula.fromJson(j)).toList();
    }
    if (res.statusCode == 204) return [];
    throw Exception('Erro ao carregar aulas: ${res.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Aula>>(
        future: _futureAulas,
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

          final aulas = snap.data ?? [];

          if (aulas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma aula registrada para hoje.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Registre uma aula no Diário\npara ela aparecer aqui.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _carregar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: aulas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _cartaoAula(ctx, aulas[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _cartaoAula(BuildContext ctx, Aula aula) {
    final chamadaLancada = aula.chamadaLancada;
    final corStatus = chamadaLancada ? Colors.green : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: corStatus,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aula.nomeDisciplina,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    aula.nomeTurma,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        chamadaLancada
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                        size: 13,
                        color: corStatus,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        chamadaLancada ? 'Chamada lançada' : 'Chamada pendente',
                        style: TextStyle(
                          fontSize: 12,
                          color: corStatus,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botão de ação
            if (!chamadaLancada)
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.professorColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  minimumSize: Size.zero,
                  textStyle: const TextStyle(fontSize: 13),
                ),
                onPressed: () async {
                  final ok = await Navigator.push<bool>(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => ChamadaScreen(aula: aula),
                    ),
                  );
                  if (ok == true) _carregar();
                },
                child: const Text('Lançar'),
              )
            else
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  minimumSize: Size.zero,
                ),
                onPressed: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (_) => ChamadaScreen(aula: aula)),
                ),
                child: const Text('Ver'),
              ),
          ],
        ),
      ),
    );
  }
}
