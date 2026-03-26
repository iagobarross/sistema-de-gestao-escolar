import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/matriz_curricular.dart';
import 'package:gestao_escolar_app/screens/professor/diario_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
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
    setState(() => _futureMatrizes = _buscarMatrizes());
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
      appBar: AppBar(
        title: Text('Minhas turmas — $_anoAtual'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: FutureBuilder<List<MatrizCurricular>>(
        future: _futureMatrizes,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }

          final matrizes = snap.data ?? [];
          if (matrizes.isEmpty) {
            return const Center(
              child: Text('Nenhuma turma vinculada para este ano.'),
            );
          }

          final grupos = _agruparPorTurma(matrizes);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grupos.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do grupo (nome da turma)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.groups,
                          size: 16,
                          color: Colors.teal.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cards de cada disciplina nessa turma
                  ...entry.value.map((m) => _cartaoMatriz(ctx, m)),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _cartaoMatriz(BuildContext ctx, MatrizCurricular m) {
    final pct = m.cargaHorariaTotal > 0
        ? (m.aulasRealizadas / m.cargaHorariaTotal).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => DiarioScreen(matriz: m)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),

              // Barra de progresso das aulas
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.teal.shade400,
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${m.aulasRealizadas} de ${m.cargaHorariaTotal} aulas',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
