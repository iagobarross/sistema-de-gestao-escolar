import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/atividade.dart';
import 'package:gestao_escolar_app/models/matriz_curricular.dart';
import 'package:gestao_escolar_app/services/atividade_service.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class AtividadesProfessorScreen extends StatefulWidget {
  const AtividadesProfessorScreen({super.key});

  @override
  State<AtividadesProfessorScreen> createState() =>
      _AtividadesProfessorScreenState();
}

class _AtividadesProfessorScreenState extends State<AtividadesProfessorScreen> {
  final _service = AtividadeService();
  late Future<List<Atividade>> _futureAtividades;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futureAtividades = _service.minhasAtividades();
    });
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _criarAtividade() async {
    // Busca matrizes do professor
    final id = await AuthService().getId();
    final ano = DateTime.now().year;
    final res = await http.get(
      Uri.parse(
        '${ApiClient.baseDomain}/matriz-curricular/professor/$id?ano=$ano',
      ),
      headers: await ApiClient.getHeaders(),
    );
    if (!mounted) return;

    List<MatrizCurricular> matrizes = [];
    if (res.statusCode == 200) {
      matrizes = (jsonDecode(utf8.decode(res.bodyBytes)) as List)
          .map((j) => MatrizCurricular.fromJson(j))
          .toList();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FormNovaAtividade(
        matrizes: matrizes,
        onSalvo: () {
          Navigator.pop(context);
          _carregar();
        },
      ),
    );
  }

  Future<void> _verEntregas(Atividade a) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _EntregasAtividadeScreen(atividade: a)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Atividade>>(
        future: _futureAtividades,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
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
                    'Nenhuma atividade criada.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _carregar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final a = lista[i];
                final atrasada = a.atrasada;
                return Card(
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: atrasada
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                atrasada ? 'Encerrada' : 'Aberta',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: atrasada ? Colors.red : Colors.green,
                                ),
                              ),
                            ),
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Entrega: ${_formatarData(a.dataEntrega)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: atrasada
                                    ? Colors.red.shade700
                                    : AppTheme.textSecondary,
                                fontWeight: atrasada
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _verEntregas(a),
                              icon: const Icon(Icons.people_outline, size: 16),
                              label: const Text(
                                'Ver entregas',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () async {
                                await _service.deletar(a.id);
                                _carregar();
                              },
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
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criarAtividade,
        icon: const Icon(Icons.add),
        label: const Text('Nova atividade'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ── Form Nova Atividade ──────────────────────────────────────────────────────

class _FormNovaAtividade extends StatefulWidget {
  final List<MatrizCurricular> matrizes;
  final VoidCallback onSalvo;
  const _FormNovaAtividade({required this.matrizes, required this.onSalvo});

  @override
  State<_FormNovaAtividade> createState() => _FormNovaAtividadeState();
}

class _FormNovaAtividadeState extends State<_FormNovaAtividade> {
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  MatrizCurricular? _matrizSelecionada;
  DateTime _dataEntrega = DateTime.now().add(const Duration(days: 7));
  bool _salvando = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty || _matrizSelecionada == null) return;
    setState(() => _salvando = true);
    try {
      await AtividadeService().criar({
        'matrizCurricularId': _matrizSelecionada!.id,
        'titulo': _tituloCtrl.text.trim(),
        'descricao': _descricaoCtrl.text.trim(),
        'dataEntrega': _dataEntrega.toIso8601String().substring(0, 10),
      });
      widget.onSalvo();
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Nova atividade',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MatrizCurricular>(
            value: _matrizSelecionada,
            isExpanded: true,
            hint: const Text('Turma / Disciplina *'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: widget.matrizes
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(
                      '${m.nomeTurma} · ${m.nomeDisciplina}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _matrizSelecionada = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tituloCtrl,
            decoration: InputDecoration(
              labelText: 'Título *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descricaoCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descrição / Enunciado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _dataEntrega,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => _dataEntrega = d);
            },
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              'Entrega: ${_dataEntrega.day.toString().padLeft(2, '0')}/${_dataEntrega.month.toString().padLeft(2, '0')}/${_dataEntrega.year}',
            ),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Criar atividade'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tela de entregas da atividade ────────────────────────────────────────────

class _EntregasAtividadeScreen extends StatefulWidget {
  final Atividade atividade;
  const _EntregasAtividadeScreen({required this.atividade});

  @override
  State<_EntregasAtividadeScreen> createState() =>
      _EntregasAtividadeScreenState();
}

class _EntregasAtividadeScreenState extends State<_EntregasAtividadeScreen> {
  late Future<List<AtividadeEntrega>> _futureEntregas;

  @override
  void initState() {
    super.initState();
    _futureEntregas = AtividadeService().entregasDaAtividade(
      widget.atividade.id,
    );
  }

  Color _statusColor(StatusEntrega s) => switch (s) {
    StatusEntrega.ENTREGUE => Colors.green,
    StatusEntrega.ATRASADA => Colors.orange,
    StatusEntrega.PENDENTE => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.atividade.titulo),
            Text(
              widget.atividade.nomeTurma,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<AtividadeEntrega>>(
        future: _futureEntregas,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lista = snap.data ?? [];
          final entregues = lista
              .where((e) => e.status != StatusEntrega.PENDENTE)
              .length;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppTheme.primary.withOpacity(0.06),
                child: Row(
                  children: [
                    _badge('$entregues entregues', Colors.green),
                    const SizedBox(width: 8),
                    _badge(
                      '${widget.atividade.totalAlunos - entregues} pendentes',
                      Colors.grey,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: lista.isEmpty
                    ? const Center(child: Text('Nenhuma entrega ainda.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: lista.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (_, i) {
                          final e = lista[i];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _statusColor(
                                  e.status,
                                ).withOpacity(0.12),
                                child: Text(
                                  e.nomeAluno[0].toUpperCase(),
                                  style: TextStyle(
                                    color: _statusColor(e.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(e.nomeAluno),
                              subtitle: Text(
                                e.conteudo ?? '(sem texto)',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    e.status,
                                  ).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  e.status.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor(e.status),
                                  ),
                                ),
                              ),
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
