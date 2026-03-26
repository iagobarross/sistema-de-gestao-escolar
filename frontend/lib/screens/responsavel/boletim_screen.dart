import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:http/http.dart' as http;

class BoletimScreen extends StatefulWidget {
  // Opcionais: se não fornecidos, busca pelo usuário logado
  final int? alunoId;
  final String? nomeAluno;

  const BoletimScreen({this.alunoId, this.nomeAluno, super.key});

  @override
  State<BoletimScreen> createState() => _BoletimScreenState();
}

class _BoletimScreenState extends State<BoletimScreen> {
  final int _anoAtual = DateTime.now().year;
  late Future<_DadosBoletim> _futureBoletim;

  @override
  void initState() {
    super.initState();
    _futureBoletim = _carregarBoletim();
  }

  Future<_DadosBoletim> _carregarBoletim() async {
    int alunoId;
    String nomeAluno;

    if (widget.alunoId != null) {
      // Parâmetros fornecidos diretamente (ex: coordenador vendo aluno específico)
      alunoId = widget.alunoId!;
      nomeAluno = widget.nomeAluno ?? 'Aluno';
    } else {
      // Descobre pelo role do token quem é o aluno
      final payload = await AuthService().getPayload();
      final role = payload?['role'] as String?;
      final meuId = payload?['id'] as int?;

      if (meuId == null) throw Exception('Usuário não identificado.');

      if (role == 'ALUNO') {
        // O próprio aluno vê seu boletim
        alunoId = meuId;
        nomeAluno = payload?['nome'] ?? 'Meu boletim';
      } else if (role == 'RESPONSAVEL') {
        // Responsável: busca o primeiro aluno vinculado a ele
        final res = await http.get(
          Uri.parse('${ApiClient.baseDomain}/responsavel/$meuId'),
          headers: await ApiClient.getHeaders(),
        );
        if (res.statusCode != 200) {
          throw Exception('Erro ao buscar dados do responsável.');
        }
        // Busca alunos vinculados ao responsável
        final resAlunos = await http.get(
          Uri.parse(
            '${ApiClient.baseDomain}/aluno?responsavelId=$meuId&size=1',
          ),
          headers: await ApiClient.getHeaders(),
        );
        if (resAlunos.statusCode != 200) {
          throw Exception('Erro ao buscar aluno.');
        }
        final paginaAlunos = jsonDecode(utf8.decode(resAlunos.bodyBytes));
        final conteudo = paginaAlunos['content'] as List?;
        if (conteudo == null || conteudo.isEmpty) {
          throw Exception('Nenhum aluno vinculado a este responsável.');
        }
        alunoId = conteudo.first['id'];
        nomeAluno = conteudo.first['nome'];
      } else {
        throw Exception('Role não autorizada para ver o boletim.');
      }
    }

    // Busca o boletim
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/nota/boletim/$alunoId?ano=$_anoAtual'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar boletim: ${res.statusCode}');
    }

    final List lista = jsonDecode(utf8.decode(res.bodyBytes));
    return _DadosBoletim(
      nomeAluno: nomeAluno,
      disciplinas: List<Map<String, dynamic>>.from(lista),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boletim Escolar'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<_DadosBoletim>(
        future: _futureBoletim,
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

          return Column(
            children: [
              // Cabeçalho com nome do aluno
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.blue.shade50,
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
                  ],
                ),
              ),

              if (disciplinas.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Nenhuma nota lançada ainda para este ano.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: disciplinas.length,
                    itemBuilder: (_, i) => _cartaoDisciplina(disciplinas[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _cartaoDisciplina(Map<String, dynamic> d) {
    final situacao = d['situacao'] as String? ?? 'SEM_DADOS';
    final cor = _corSituacao(situacao);
    final notaMinima = (d['notaMinima'] as num?)?.toDouble() ?? 5.0;

    double? _toDouble(dynamic v) => v != null ? (v as num).toDouble() : null;

    final b1 = _toDouble(d['mediaBimestre1']);
    final b2 = _toDouble(d['mediaBimestre2']);
    final b3 = _toDouble(d['mediaBimestre3']);
    final b4 = _toDouble(d['mediaBimestre4']);
    final mf = _toDouble(d['mediaFinal']);
    final pct = _toDouble(d['percentualPresenca']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cor.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da disciplina
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['nomeDisciplina'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Prof. ${d['nomeProfessor'] ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
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
                    color: cor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _labelSituacao(situacao),
                    style: TextStyle(
                      fontSize: 11,
                      color: cor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Notas por bimestre
            Row(
              children: [
                _notaCell('1º Bim', b1, notaMinima),
                _notaCell('2º Bim', b2, notaMinima),
                _notaCell('3º Bim', b3, notaMinima),
                _notaCell('4º Bim', b4, notaMinima),
                _notaCell('Média', mf, notaMinima, destaque: true),
              ],
            ),

            const SizedBox(height: 10),

            // Frequência
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 13,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 5),
                Text(
                  '${d['faltas'] ?? 0} faltas'
                  ' · ${d['totalAulas'] ?? 0} aulas',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                if (pct != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: pct >= 75
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${pct.toStringAsFixed(0)}% presença',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: pct >= 75
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _notaCell(
    String label,
    double? nota,
    double minima, {
    bool destaque = false,
  }) {
    Color corNota = Colors.grey;
    if (nota != null) {
      corNota = nota >= minima ? Colors.green.shade700 : Colors.red.shade700;
    }
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: destaque ? Colors.blue.shade50 : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              nota != null ? nota.toStringAsFixed(1) : '—',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: destaque ? 15 : 13,
                fontWeight: destaque ? FontWeight.bold : FontWeight.w500,
                color: nota != null ? corNota : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _corSituacao(String s) => switch (s) {
    'APROVADO' => Colors.green,
    'RECUPERACAO' => Colors.orange,
    'REPROVADO' => Colors.red,
    _ => Colors.grey,
  };

  String _labelSituacao(String s) => switch (s) {
    'APROVADO' => 'Aprovado',
    'RECUPERACAO' => 'Recuperação',
    'REPROVADO' => 'Reprovado',
    _ => 'Sem dados',
  };
}

class _DadosBoletim {
  final String nomeAluno;
  final List<Map<String, dynamic>> disciplinas;
  _DadosBoletim({required this.nomeAluno, required this.disciplinas});
}
