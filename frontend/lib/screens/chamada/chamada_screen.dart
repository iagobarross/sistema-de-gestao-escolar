import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aula.dart';
import 'package:gestao_escolar_app/models/aluno.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/aluno_service.dart';
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

  @override
  void initState() {
    super.initState();
    _futureAlunos = _carregarAlunos();
  }

  Future<List<Aluno>> _carregarAlunos() async {
    final turmaId = await _getTurmaId();
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/turma/$turmaId/alunos'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      final List list = jsonDecode(utf8.decode(res.bodyBytes));
      final alunos = list.map((j) => Aluno.fromJson(j)).toList();
      for (var a in alunos) {
        _presencas[a.id] = true;
      }
      return alunos;
    }
    throw Exception('Erro ao carregar alunos');
  }

  Future<int> _getTurmaId() async {
    final res = await http.get(
      Uri.parse(
        '${ApiClient.baseDomain}/matriz-curricular/${widget.aula.matrizCurricularId}',
      ),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['turmaId'];
    }
    throw Exception('Erro ao buscar turma');
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
        throw Exception(res.body);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chamada'),
            Text(
              '${widget.aula.nomeDisciplina} · ${widget.aula.nomeTurma}',
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
          FutureBuilder<List<Aluno>>(
            future: _futureAlunos,
            builder: (_, snap) {
              if (!snap.hasData) return const SizedBox();
              return TextButton(
                onPressed: _salvando ? null : () => _salvarChamada(snap.data!),
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
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
                    _chip('$presentes presentes', Colors.green),
                    const SizedBox(width: 8),
                    _chip('$ausentes ausentes', Colors.red),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() {
                        for (var a in alunos) _presencas[a.id] = true;
                      }),
                      child: const Text('Marcar todos'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
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
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Text(
                          aluno.nome[0],
                          style: TextStyle(
                            color: presente
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      title: Text(aluno.nome),
                      subtitle: Text('RA: ${aluno.matricula}'),
                      trailing: Switch.adaptive(
                        value: presente,
                        activeColor: Colors.green,
                        onChanged: (v) =>
                            setState(() => _presencas[aluno.id] = v),
                      ),
                      tileColor: presente ? null : Colors.red.shade50,
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

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
