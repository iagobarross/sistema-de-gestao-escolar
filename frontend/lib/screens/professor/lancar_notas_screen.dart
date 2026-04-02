import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/matriz_curricular.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class LancarNotasScreen extends StatefulWidget {
  final MatrizCurricular matriz;
  const LancarNotasScreen({required this.matriz, super.key});

  @override
  State<LancarNotasScreen> createState() => _LancarNotasScreenState();
}

class _LancarNotasScreenState extends State<LancarNotasScreen> {
  List<Map<String, dynamic>> _avaliacoes = [];
  Map<String, dynamic>? _avaliacaoSelecionada;
  List<Map<String, dynamic>> _alunos = [];
  final Map<int, TextEditingController> _controllers = {};
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    // FIX: não chamamos setState com Future — usamos bool de loading.
    setState(() => _carregando = true);
    try {
      await Future.wait([_buscarAvaliacoes(), _buscarAlunos()]);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _buscarAvaliacoes() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/avaliacao/matriz/${widget.matriz.id}'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200 && mounted) {
      // Não chamamos setState aqui; o await acima é dentro de _carregarDados
      // que já controla o estado via _carregando.
      _avaliacoes = List<Map<String, dynamic>>.from(
        jsonDecode(utf8.decode(res.bodyBytes)),
      );
    }
  }

  Future<void> _buscarAlunos() async {
    final res = await http.get(
      Uri.parse(
        '${ApiClient.baseDomain}/turma/${widget.matriz.turmaId}/alunos',
      ),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200 && mounted) {
      final lista = List<Map<String, dynamic>>.from(
        jsonDecode(utf8.decode(res.bodyBytes)),
      );
      _alunos = lista;
      for (final a in lista) {
        final id = a['id'] as int;
        _controllers[id] ??= TextEditingController();
      }
    }
  }

  Future<void> _carregarNotasExistentes(int avaliacaoId) async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/nota/avaliacao/$avaliacaoId'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      final notas = List<Map<String, dynamic>>.from(
        jsonDecode(utf8.decode(res.bodyBytes)),
      );
      for (final nota in notas) {
        final alunoId = nota['alunoId'] as int;
        _controllers[alunoId]?.text = (nota['valor'] as num).toStringAsFixed(1);
      }
    }
  }

  Future<void> _salvarNotas() async {
    if (_avaliacaoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma avaliação primeiro.')),
      );
      return;
    }

    final notaMax = (_avaliacaoSelecionada!['notaMaxima'] as num).toDouble();
    final erros = <String>[];

    for (final aluno in _alunos) {
      final id = aluno['id'] as int;
      final texto = _controllers[id]?.text.trim() ?? '';
      if (texto.isEmpty) continue;
      final valor = double.tryParse(texto.replaceAll(',', '.'));
      if (valor == null) {
        erros.add('Nota inválida para ${aluno['nome']}');
      } else if (valor < 0 || valor > notaMax) {
        erros.add('${aluno['nome']}: nota deve estar entre 0 e $notaMax');
      }
    }

    if (erros.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erros.join('\n')), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      final itens = <Map<String, dynamic>>[];
      for (final aluno in _alunos) {
        final id = aluno['id'] as int;
        final texto = _controllers[id]?.text.trim().replaceAll(',', '.') ?? '';
        if (texto.isEmpty) continue;
        itens.add({'alunoId': id, 'valor': double.parse(texto)});
      }

      if (itens.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhuma nota foi preenchida.')),
        );
        return;
      }

      final body = {
        'avaliacaoId': _avaliacaoSelecionada!['id'],
        'notas': itens,
      };

      final res = await http.post(
        Uri.parse('${ApiClient.baseDomain}/nota/lancar'),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(body),
      );

      if (res.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notas salvas com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception(jsonDecode(res.body)['erro'] ?? 'Erro ao salvar notas');
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

  void _abrirCriarAvaliacao() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FormNovaAvaliacao(
        matrizId: widget.matriz.id,
        onSalvo: () {
          Navigator.pop(context);
          _carregarDados();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lançar notas'),
            Text(
              widget.matriz.nomeDisciplina,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          if (_avaliacaoSelecionada != null)
            TextButton(
              onPressed: _salvando ? null : _salvarNotas,
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
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Seletor de avaliação ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Map<String, dynamic>>(
                          value: _avaliacaoSelecionada,
                          hint: const Text('Selecione uma avaliação'),
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          items: _avaliacoes.map((av) {
                            return DropdownMenuItem(
                              value: av,
                              child: Text(
                                '${av['titulo']} · ${av['bimestre']}º bim',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (av) async {
                            for (final c in _controllers.values) {
                              c.clear();
                            }
                            setState(() => _avaliacaoSelecionada = av);
                            if (av != null) {
                              await _carregarNotasExistentes(av['id']);
                              if (mounted) setState(() {});
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        onPressed: _abrirCriarAvaliacao,
                        icon: const Icon(Icons.add),
                        tooltip: 'Nova avaliação',
                      ),
                    ],
                  ),
                ),

                if (_avaliacaoSelecionada != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          'Nota máxima: ${_avaliacaoSelecionada!['notaMaxima']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Peso: ${_avaliacaoSelecionada!['peso']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 1),

                // ── Lista de alunos / campo de nota ────────────────────
                _avaliacaoSelecionada == null
                    ? Expanded(
                        child: Center(
                          child: Text(
                            'Selecione uma avaliação acima\npara lançar as notas.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _alunos.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final aluno = _alunos[i];
                            final id = aluno['id'] as int;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.orange.withOpacity(
                                      0.1,
                                    ),
                                    child: Text(
                                      (aluno['nome'] as String)[0],
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          aluno['nome'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'RA: ${aluno['matricula']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 76,
                                    child: TextFormField(
                                      controller: _controllers[id],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        hintText: '—',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 10,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet para criar nova avaliação
// ─────────────────────────────────────────────────────────────────────────────

class _FormNovaAvaliacao extends StatefulWidget {
  final int matrizId;
  final VoidCallback onSalvo;
  const _FormNovaAvaliacao({required this.matrizId, required this.onSalvo});

  @override
  State<_FormNovaAvaliacao> createState() => _FormNovaAvaliacaoState();
}

class _FormNovaAvaliacaoState extends State<_FormNovaAvaliacao> {
  final _tituloCtrl = TextEditingController();
  String _tipo = 'PROVA';
  int _bimestre = 1;
  DateTime _data = DateTime.now().add(const Duration(days: 1));
  bool _salvando = false;

  static const _tipos = [
    'PROVA',
    'TRABALHO',
    'PARTICIPACAO',
    'RECUPERACAO',
    'SIMULADO',
  ];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty) return;
    setState(() => _salvando = true);
    try {
      final body = {
        'matrizCurricularId': widget.matrizId,
        'titulo': _tituloCtrl.text.trim(),
        'tipo': _tipo,
        'dataAplicacao': _data.toIso8601String().substring(0, 10),
        'notaMaxima': 10.0,
        'bimestre': _bimestre,
        'peso': 1.0,
      };
      final res = await http.post(
        Uri.parse('${ApiClient.baseDomain}/avaliacao'),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(body),
      );
      if (res.statusCode == 201) widget.onSalvo();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nova avaliação',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
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
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _tipos
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _tipo = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _bimestre,
                  decoration: InputDecoration(
                    labelText: 'Bimestre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: [1, 2, 3, 4]
                      .map(
                        (b) => DropdownMenuItem(
                          value: b,
                          child: Text('$b º bimestre'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _bimestre = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
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
                  : const Text('Criar avaliação'),
            ),
          ),
        ],
      ),
    );
  }
}
