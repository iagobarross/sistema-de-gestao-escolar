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

  Future<void> _selecionarAvaliacao(Map<String, dynamic> av) async {
    // Limpa campos antes de carregar novas
    for (final c in _controllers.values) c.clear();
    setState(() => _avaliacaoSelecionada = av);
    await _carregarNotasExistentes(av['id'] as int);
    if (mounted) setState(() {});
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
    if (_avaliacaoSelecionada == null) return;

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

  // ── Helpers de apresentação ──────────────────────────────────────────────

  Color _corTipo(String tipo) => switch (tipo) {
    'PROVA' => Colors.blue,
    'TRABALHO' => Colors.green,
    'PARTICIPACAO' => Colors.teal,
    'RECUPERACAO' => Colors.orange,
    'SIMULADO' => Colors.purple,
    _ => Colors.grey,
  };

  String _labelTipo(String tipo) => switch (tipo) {
    'PROVA' => 'Prova',
    'TRABALHO' => 'Trabalho',
    'PARTICIPACAO' => 'Participação',
    'RECUPERACAO' => 'Recuperação',
    'SIMULADO' => 'Simulado',
    _ => tipo,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lançar notas'),
            Text(
              '${widget.matriz.nomeDisciplina} · ${widget.matriz.nomeTurma}',
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
                // ── Seção: lista de avaliações ─────────────────────────
                Container(
                  color: Colors.grey.shade50,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Avaliações',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: _abrirCriarAvaliacao,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text(
                              'Nova',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_avaliacoes.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Nenhuma avaliação cadastrada. Crie a primeira.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        )
                      else
                        // Rolagem horizontal de cartões de avaliação
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _avaliacoes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final av = _avaliacoes[i];
                              final isSelected =
                                  _avaliacaoSelecionada?['id'] == av['id'];
                              final cor = _corTipo(av['tipo'] as String? ?? '');

                              return GestureDetector(
                                onTap: () => _selecionarAvaliacao(av),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 160,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.primary
                                                  .withOpacity(0.25),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white.withOpacity(
                                                      0.2,
                                                    )
                                                  : cor.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _labelTipo(
                                                av['tipo'] as String? ?? '',
                                              ),
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : cor,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${av['bimestre']}º bim',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: isSelected
                                                  ? Colors.white70
                                                  : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        av['titulo'] as String? ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : AppTheme.textPrimary,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Máx: ${av['notaMaxima']}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isSelected
                                                  ? Colors.white70
                                                  : AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Peso: ${av['peso']}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isSelected
                                                  ? Colors.white70
                                                  : AppTheme.textSecondary,
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
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // ── Seção: lista de alunos com campo de nota ───────────
                _avaliacaoSelecionada == null
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Selecione uma avaliação acima\npara lançar as notas.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          children: [
                            // Info da avaliação selecionada
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              color: AppTheme.primary.withOpacity(0.05),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.quiz_outlined,
                                    size: 16,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _avaliacaoSelecionada!['titulo'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Nota máx: ${_avaliacaoSelecionada!['notaMaxima']}  ·  Peso: ${_avaliacaoSelecionada!['peso']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: _alunos.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final aluno = _alunos[i];
                                  final id = aluno['id'] as int;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: AppTheme.primary
                                              .withOpacity(0.1),
                                          child: Text(
                                            (aluno['nome'] as String)[0],
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontWeight: FontWeight.w600,
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
                      ),
              ],
            ),
    );
  }
}

// ─── Bottom sheet: Criar nova avaliação ──────────────────────────────────────
// FIX #4: campos de Peso e Nota Máxima adicionados

class _FormNovaAvaliacao extends StatefulWidget {
  final int matrizId;
  final VoidCallback onSalvo;
  const _FormNovaAvaliacao({required this.matrizId, required this.onSalvo});

  @override
  State<_FormNovaAvaliacao> createState() => _FormNovaAvaliacaoState();
}

class _FormNovaAvaliacaoState extends State<_FormNovaAvaliacao> {
  final _tituloCtrl = TextEditingController();
  final _notaMaxCtrl = TextEditingController(text: '10.0');
  final _pesoCtrl = TextEditingController(text: '1.0');
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

  static const _labeisTipos = {
    'PROVA': 'Prova',
    'TRABALHO': 'Trabalho',
    'PARTICIPACAO': 'Participação',
    'RECUPERACAO': 'Recuperação',
    'SIMULADO': 'Simulado',
  };

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _notaMaxCtrl.dispose();
    _pesoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o título da avaliação.')),
      );
      return;
    }

    final notaMax = double.tryParse(
      _notaMaxCtrl.text.trim().replaceAll(',', '.'),
    );
    final peso = double.tryParse(_pesoCtrl.text.trim().replaceAll(',', '.'));

    if (notaMax == null || notaMax <= 0 || notaMax > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota máxima deve ser entre 0.1 e 10.')),
      );
      return;
    }
    if (peso == null || peso <= 0 || peso > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peso deve ser entre 0.1 e 5.')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      final body = {
        'matrizCurricularId': widget.matrizId,
        'titulo': _tituloCtrl.text.trim(),
        'tipo': _tipo,
        'dataAplicacao': _data.toIso8601String().substring(0, 10),
        'notaMaxima': notaMax,
        'bimestre': _bimestre,
        'peso': peso,
      };
      final res = await http.post(
        Uri.parse('${ApiClient.baseDomain}/avaliacao'),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(body),
      );
      if (res.statusCode == 201) {
        widget.onSalvo();
      } else {
        final erro = jsonDecode(res.body)['erro'] ?? 'Erro ao criar avaliação';
        throw Exception(erro);
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

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _data = picked);
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Nova avaliação',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Título
            TextField(
              controller: _tituloCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex: Prova Bimestral 1',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tipo e Bimestre
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
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(_labeisTipos[t] ?? t),
                          ),
                        )
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
                            child: Text('$bº bimestre'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _bimestre = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nota Máxima e Peso  ← FIX #4
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _notaMaxCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nota máxima *',
                      hintText: '0.1 – 10.0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _pesoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Peso *',
                      hintText: '0.1 – 5.0',
                      helperText: 'Usado na média ponderada',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Data de aplicação
            OutlinedButton.icon(
              onPressed: _selecionarData,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                'Data de aplicação: '
                '${_data.day.toString().padLeft(2, '0')}/'
                '${_data.month.toString().padLeft(2, '0')}/'
                '${_data.year}',
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
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
      ),
    );
  }
}
