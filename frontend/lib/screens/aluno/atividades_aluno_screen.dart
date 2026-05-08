import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/atividade.dart';
import 'package:gestao_escolar_app/services/atividade_service.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class AtividadesAlunoScreen extends StatefulWidget {
  const AtividadesAlunoScreen({super.key});

  @override
  State<AtividadesAlunoScreen> createState() => _AtividadesAlunoScreenState();
}

class _AtividadesAlunoScreenState extends State<AtividadesAlunoScreen> {
  final _service = AtividadeService();
  List<Atividade> _atividades = [];
  Map<int, AtividadeEntrega> _entregasMap = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
    });
    try {
      final payload = await AuthService().getPayload();
      final meuId = payload?['id'] as int?;
      if (meuId == null) return;

      // Busca turmas do aluno para encontrar atividades
      final resAluno = await http.get(
        Uri.parse('${ApiClient.baseDomain}/aluno/$meuId'),
        headers: await ApiClient.getHeaders(),
      );

      List<Atividade> todasAtividades = [];
      if (resAluno.statusCode == 200) {
        final aluno = jsonDecode(utf8.decode(resAluno.bodyBytes));
        final turmas = (aluno['turmas'] as List?) ?? [];
        // Busca turma IDs pelo boletim para pegar as atividades
        final resTurmas = await http.get(
          Uri.parse('${ApiClient.baseDomain}/turma'),
          headers: await ApiClient.getHeaders(),
        );
        if (resTurmas.statusCode == 200) {
          final listaTurmas =
              jsonDecode(utf8.decode(resTurmas.bodyBytes)) as List;
          for (final t in listaTurmas) {
            final tAtiv = await _service.porTurma(t['id']);
            todasAtividades.addAll(tAtiv);
          }
        }
      }

      final entregas = await _service.minhasEntregas();
      final map = {for (final e in entregas) e.atividadeId: e};

      if (mounted) {
        setState(() {
          _atividades = todasAtividades;
          _entregasMap = map;
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _entregar(Atividade a) async {
    final ctrl = TextEditingController(
      text: _entregasMap[a.id]?.conteudo ?? '',
    );
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              a.titulo,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              a.descricao,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Sua resposta / entrega',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _service.entregar(a.id, ctrl.text.trim());
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  _entregasMap.containsKey(a.id)
                      ? 'Atualizar entrega'
                      : 'Entregar atividade',
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok == true) _carregar();
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator());

    if (_atividades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nenhuma atividade disponível.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _atividades.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final a = _atividades[i];
          final entrega = _entregasMap[a.id];
          final entregue = entrega != null;
          final atrasada = a.atrasada && !entregue;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: atrasada
                    ? Colors.red.shade200
                    : entregue
                    ? Colors.green.shade200
                    : AppTheme.divider,
                width: atrasada || entregue ? 1.5 : 1,
              ),
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
                          a.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _statusChip(entregue, atrasada, entrega?.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${a.nomeDisciplina} · ${a.nomeTurma}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (a.descricao.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      a.descricao,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: atrasada ? Colors.red : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Entrega: ${_formatarData(a.dataEntrega)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: atrasada ? Colors.red : AppTheme.textSecondary,
                          fontWeight: atrasada
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (!a.atrasada || entregue)
                        TextButton(
                          onPressed: () => _entregar(a),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            entregue ? 'Ver / Editar' : 'Entregar',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(bool entregue, bool atrasada, StatusEntrega? status) {
    String label;
    Color cor;
    if (entregue) {
      label = status == StatusEntrega.ATRASADA ? 'Atrasada' : 'Entregue';
      cor = status == StatusEntrega.ATRASADA ? Colors.orange : Colors.green;
    } else if (atrasada) {
      label = 'Prazo encerrado';
      cor = Colors.red;
    } else {
      label = 'Pendente';
      cor = AppTheme.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cor),
      ),
    );
  }
}
