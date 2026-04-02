import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aula.dart';
import 'package:gestao_escolar_app/models/aluno.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class ChamadaScreen extends StatefulWidget {
  final Aula aula;
  const ChamadaScreen({required this.aula, super.key});

  @override
  State<ChamadaScreen> createState() => _ChamadaScreenState();
}

class _ChamadaScreenState extends State<ChamadaScreen> {
  late Future<List<Aluno>> _futureAlunos;
  final Map<int, bool> _presencas = {};
  bool _salvando = false;
  bool _chamadaJaLancada = false;

  @override
  void initState() {
    super.initState();
    // FIX: bloco {} garante retorno void no setState.
    setState(() {
      _futureAlunos = _carregarAlunos();
    });
  }

  Future<List<Aluno>> _carregarAlunos() async {
    // Se a chamada já foi lançada, carrega as presenças existentes
    if (widget.aula.chamadaLancada) {
      setState(() => _chamadaJaLancada = true);
      final res = await http.get(
        Uri.parse('${ApiClient.baseDomain}/frequencia/aula/${widget.aula.id}'),
        headers: await ApiClient.getHeaders(),
      );
      if (res.statusCode == 200) {
        final lista = List<Map<String, dynamic>>.from(
          jsonDecode(utf8.decode(res.bodyBytes)),
        );
        // Monta _presencas a partir dos registros existentes
        for (final f in lista) {
          _presencas[f['alunoId'] as int] = f['presente'] as bool;
        }
        // Busca os alunos da turma para montar a lista
        return _buscarAlunosDaTurma();
      }
    }
    return _buscarAlunosDaTurma();
  }

  Future<List<Aluno>> _buscarAlunosDaTurma() async {
    // Busca turmaId pela matrizCurricular
    final resMC = await http.get(
      Uri.parse(
        '${ApiClient.baseDomain}/matriz-curricular/${widget.aula.matrizCurricularId}',
      ),
      headers: await ApiClient.getHeaders(),
    );

    int turmaId;
    if (resMC.statusCode == 200) {
      turmaId = jsonDecode(resMC.body)['turmaId'] as int;
    } else {
      throw Exception('Erro ao buscar turma da aula');
    }

    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/turma/$turmaId/alunos'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      final List lista = jsonDecode(utf8.decode(res.bodyBytes));
      final alunos = lista.map((j) => Aluno.fromJson(j)).toList();
      // Inicializa todos como presentes se ainda não há registros
      for (final a in alunos) {
        _presencas.putIfAbsent(a.id, () => true);
      }
      return alunos;
    }
    throw Exception('Erro ao carregar alunos');
  }

  Future<void> _salvarChamada(List<Aluno> alunos) async {
    setState(() => _salvando = true);
    try {
      final presencas = alunos
          .map((a) => {'alunoId': a.id, 'presente': _presencas[a.id] ?? true})
          .toList();

      final body = {'aulaId': widget.aula.id, 'presencas': presencas};

      final res = await http.post(
        Uri.parse('${ApiClient.baseDomain}/frequencia/chamada'),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(body),
      );

      if (res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chamada salva com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(
          jsonDecode(res.body)['erro'] ?? 'Erro ao salvar chamada',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.professorColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_chamadaJaLancada ? 'Chamada (lançada)' : 'Chamada'),
            Text(
              '${widget.aula.nomeDisciplina} · ${widget.aula.nomeTurma}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          FutureBuilder<List<Aluno>>(
            future: _futureAlunos,
            builder: (_, snap) {
              if (!snap.hasData || _chamadaJaLancada) {
                return const SizedBox();
              }
              return TextButton(
                onPressed: _salvando ? null : () => _salvarChamada(snap.data!),
                child: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'SALVAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Aluno>>(
        future: _futureAlunos,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }

          final alunos = snap.data!;
          final presentes = _presencas.values.where((p) => p).length;
          final ausentes = alunos.length - presentes;

          return Column(
            children: [
              // Resumo
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    _badge('$presentes presentes', Colors.green),
                    const SizedBox(width: 8),
                    _badge('$ausentes ausentes', Colors.red),
                    const Spacer(),
                    if (!_chamadaJaLancada)
                      TextButton(
                        onPressed: () => setState(() {
                          for (final a in alunos) _presencas[a.id] = true;
                        }),
                        child: const Text('Marcar todos'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),

              if (_chamadaJaLancada)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.green.shade50,
                  child: const Text(
                    'Chamada já lançada — modo somente leitura.',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),

              Expanded(
                child: ListView.separated(
                  itemCount: alunos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final aluno = alunos[i];
                    final presente = _presencas[aluno.id] ?? true;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: presente
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        child: Text(
                          aluno.nome[0],
                          style: TextStyle(
                            color: presente
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      title: Text(aluno.nome),
                      subtitle: Text('RA: ${aluno.matricula}'),
                      tileColor: presente ? null : Colors.red.shade50,
                      trailing: _chamadaJaLancada
                          ? Icon(
                              presente ? Icons.check_circle : Icons.cancel,
                              color: presente ? Colors.green : Colors.red,
                            )
                          : Switch.adaptive(
                              value: presente,
                              activeColor: Colors.green,
                              onChanged: (v) =>
                                  setState(() => _presencas[aluno.id] = v),
                            ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
    ),
  );
}
