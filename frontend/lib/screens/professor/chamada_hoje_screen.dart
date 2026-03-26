import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aula.dart';
import 'package:gestao_escolar_app/screens/chamada/chamada_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
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
    setState(() => _futureAulas = _buscarAulasHoje());
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
    if (res.statusCode == 204 || res.statusCode == 200) return [];
    throw Exception('Erro ao carregar aulas: ${res.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chamada de hoje'),
            Text(
              _dataHoje(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: FutureBuilder<List<Aula>>(
        future: _futureAulas,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
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
                  Text(
                    'Nenhuma aula registrada para hoje.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'As aulas aparecem aqui quando você\nregistra a aula no Diário.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: aulas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _cartaoAula(ctx, aulas[i]),
          );
        },
      ),
    );
  }

  Widget _cartaoAula(BuildContext ctx, Aula aula) {
    final chamadaLancada = aula.chamadaLancada;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: chamadaLancada
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: chamadaLancada
                    ? Colors.green.shade400
                    : Colors.orange.shade400,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    aula.nomeTurma,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        chamadaLancada
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 14,
                        color: chamadaLancada
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        chamadaLancada ? 'Chamada lançada' : 'Chamada pendente',
                        style: TextStyle(
                          fontSize: 12,
                          color: chamadaLancada
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (!chamadaLancada)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
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

  String _dataHoje() {
    final hoje = DateTime.now();
    const meses = [
      '',
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '${hoje.day} de ${meses[hoje.month]} de ${hoje.year}';
  }
}
