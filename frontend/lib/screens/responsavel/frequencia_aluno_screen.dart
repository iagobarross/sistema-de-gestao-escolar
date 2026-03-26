import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:http/http.dart' as http;

class FrequenciaAlunoScreen extends StatefulWidget {
  final int? alunoId;
  final String? nomeAluno;

  const FrequenciaAlunoScreen({this.alunoId, this.nomeAluno, super.key});

  @override
  State<FrequenciaAlunoScreen> createState() => _FrequenciaAlunoScreenState();
}

class _FrequenciaAlunoScreenState extends State<FrequenciaAlunoScreen> {
  final int _anoAtual = DateTime.now().year;
  late Future<_DadosFrequencia> _futureFrequencia;

  @override
  void initState() {
    super.initState();
    _futureFrequencia = _carregarFrequencia();
  }

  Future<_DadosFrequencia> _carregarFrequencia() async {
    int alunoId;
    String nomeAluno;

    if (widget.alunoId != null) {
      alunoId = widget.alunoId!;
      nomeAluno = widget.nomeAluno ?? 'Aluno';
    } else {
      final payload = await AuthService().getPayload();
      final role = payload?['role'] as String?;
      final meuId = payload?['id'] as int?;

      if (meuId == null) throw Exception('Usuário não identificado.');

      if (role == 'ALUNO') {
        alunoId = meuId;
        nomeAluno = payload?['nome'] ?? 'Minha frequência';
      } else if (role == 'RESPONSAVEL') {
        final resAlunos = await http.get(
          Uri.parse(
            '${ApiClient.baseDomain}/aluno?responsavelId=$meuId&size=1',
          ),
          headers: await ApiClient.getHeaders(),
        );
        if (resAlunos.statusCode != 200) {
          throw Exception('Erro ao buscar aluno.');
        }
        final pagina = jsonDecode(utf8.decode(resAlunos.bodyBytes));
        final conteudo = pagina['content'] as List?;
        if (conteudo == null || conteudo.isEmpty) {
          throw Exception('Nenhum aluno vinculado.');
        }
        alunoId = conteudo.first['id'];
        nomeAluno = conteudo.first['nome'];
      } else {
        throw Exception('Role não autorizada.');
      }
    }

    // Busca o boletim — ele já traz frequência por disciplina
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/nota/boletim/$alunoId?ano=$_anoAtual'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar frequência: ${res.statusCode}');
    }

    final List lista = jsonDecode(utf8.decode(res.bodyBytes));
    return _DadosFrequencia(
      nomeAluno: nomeAluno,
      disciplinas: List<Map<String, dynamic>>.from(lista),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequência'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<_DadosFrequencia>(
        future: _futureFrequencia,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${snap.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          final dados = snap.data!;
          final disciplinas = dados.disciplinas;

          // Calcula totais globais
          final totalAulas = disciplinas.fold<int>(
            0,
            (s, d) => s + ((d['totalAulas'] as int?) ?? 0),
          );
          final totalFaltas = disciplinas.fold<int>(
            0,
            (s, d) => s + ((d['faltas'] as int?) ?? 0),
          );
          final totalPresencas = totalAulas - totalFaltas;
          final pctGeral = totalAulas > 0
              ? (totalPresencas / totalAulas * 100)
              : 0.0;

          return Column(
            children: [
              // Cabeçalho com resumo geral
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dados.nomeAluno,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Ano letivo $_anoAtual',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _resumoBadge(
                          '$totalAulas',
                          'total de aulas',
                          Colors.blue,
                        ),
                        const SizedBox(width: 10),
                        _resumoBadge(
                          '$totalPresencas',
                          'presenças',
                          Colors.green,
                        ),
                        const SizedBox(width: 10),
                        _resumoBadge('$totalFaltas', 'faltas', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Barra de progresso geral
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pctGeral / 100,
                        backgroundColor: Colors.red.shade100,
                        color: pctGeral >= 75
                            ? Colors.green.shade500
                            : Colors.red.shade500,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${pctGeral.toStringAsFixed(1)}% de presença geral',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Mínimo: 75%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              if (disciplinas.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Nenhum dado de frequência disponível.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: disciplinas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _cartaoFrequencia(disciplinas[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _resumoBadge(String valor, String label, Color cor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoFrequencia(Map<String, dynamic> d) {
    final totalAulas = (d['totalAulas'] as int?) ?? 0;
    final faltas = (d['faltas'] as int?) ?? 0;
    final presencas = totalAulas - faltas;
    final pct = (d['percentualPresenca'] as num?)?.toDouble();
    final percentual =
        pct ?? (totalAulas > 0 ? presencas / totalAulas * 100 : 0.0);
    final aprovada = percentual >= 75;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: aprovada ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['nomeDisciplina'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Prof. ${d['nomeProfessor'] ?? ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: aprovada ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${percentual.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: aprovada
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentual / 100,
                backgroundColor: Colors.grey.shade200,
                color: aprovada ? Colors.green.shade400 : Colors.red.shade400,
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 6),

            // Contagens
            Row(
              children: [
                _contagem('$presencas', 'presenças', Colors.green),
                const SizedBox(width: 12),
                _contagem('$faltas', 'faltas', Colors.red),
                const SizedBox(width: 12),
                _contagem('$totalAulas', 'total', Colors.grey),
              ],
            ),

            if (!aprovada) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Frequência abaixo de 75% — risco de reprovação',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _contagem(String valor, String label, Color cor) {
    return Row(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _DadosFrequencia {
  final String nomeAluno;
  final List<Map<String, dynamic>> disciplinas;
  _DadosFrequencia({required this.nomeAluno, required this.disciplinas});
}
