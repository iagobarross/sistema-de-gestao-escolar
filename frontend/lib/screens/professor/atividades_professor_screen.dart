import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/atividade.dart';
import 'package:gestao_escolar_app/models/matriz_curricular.dart';
import 'package:gestao_escolar_app/services/atividade_service.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:gestao_escolar_app/widgets/file_upload_helper.dart';
import 'package:gestao_escolar_app/widgets/arquivo_chip.dart';
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
                            _badge(
                              a.atrasada ? 'Encerrada' : 'Aberta',
                              a.atrasada ? Colors.red : Colors.green,
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
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      _EntregasAtividadeScreen(atividade: a),
                                ),
                              ),
                              icon: const Icon(Icons.people_outline, size: 16),
                              label: const Text(
                                'Ver alunos',
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
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Excluir atividade'),
                                    content: const Text(
                                      'Todas as entregas serão removidas. Confirma?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await _service.deletar(a.id);
                                  _carregar();
                                }
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

  Widget _badge(String label, Color cor) {
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

// ── Formulário: nova atividade ────────────────────────────────────────────────

class _FormNovaAtividade extends StatefulWidget {
  final List<MatrizCurricular> matrizes;
  final VoidCallback onSalvo;

  const _FormNovaAtividade({required this.matrizes, required this.onSalvo});

  @override
  State<_FormNovaAtividade> createState() => _FormNovaAtividadeState();
}

class _FormNovaAtividadeState extends State<_FormNovaAtividade> {
  final _service = AtividadeService();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  MatrizCurricular? _matrizSelecionada;
  DateTime? _dataEntrega;
  bool _salvando = false;

  Future<void> _salvar() async {
    if (_matrizSelecionada == null ||
        _tituloCtrl.text.trim().isEmpty ||
        _dataEntrega == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      await _service.criar({
        'matrizCurricularId': _matrizSelecionada!.id,
        'titulo': _tituloCtrl.text.trim(),
        'descricao': _descricaoCtrl.text.trim(),
        'dataEntrega':
            '${_dataEntrega!.year}-${_dataEntrega!.month.toString().padLeft(2, '0')}-${_dataEntrega!.day.toString().padLeft(2, '0')}',
      });
      widget.onSalvo();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
        setState(() => _salvando = false);
      }
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
            'Nova Atividade',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Disciplina / turma
          DropdownButtonFormField<MatrizCurricular>(
            value: _matrizSelecionada,
            decoration: InputDecoration(
              labelText: 'Disciplina / Turma *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: widget.matrizes
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(
                      '${m.nomeDisciplina} · ${m.nomeTurma}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _matrizSelecionada = v),
          ),
          const SizedBox(height: 12),

          // Título
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

          // Descrição
          TextField(
            controller: _descricaoCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descrição (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Data de entrega
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _dataEntrega = picked);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              _dataEntrega == null
                  ? 'Selecionar data de entrega *'
                  : 'Entrega: ${_dataEntrega!.day.toString().padLeft(2, '0')}/${_dataEntrega!.month.toString().padLeft(2, '0')}/${_dataEntrega!.year}',
            ),
          ),
          const SizedBox(height: 20),

          // Botão salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
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

// ── Tela: entregas / status de alunos (Bug 3 corrigido) ──────────────────────

class _EntregasAtividadeScreen extends StatefulWidget {
  final Atividade atividade;

  const _EntregasAtividadeScreen({required this.atividade});

  @override
  State<_EntregasAtividadeScreen> createState() =>
      _EntregasAtividadeScreenState();
}

class _EntregasAtividadeScreenState extends State<_EntregasAtividadeScreen> {
  final _service = AtividadeService();
  List<AtividadeAlunoStatus> _status = [];
  bool _carregando = true;
  String _filtro = 'TODOS'; // TODOS | ENTREGUE | PENDENTE | ATRASADA

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      // Bug 3 corrigido: usa /status-alunos que retorna TODOS os alunos,
      // inclusive os que ainda não entregaram.
      final lista = await _service.statusAlunos(widget.atividade.id);
      if (mounted) setState(() => _status = lista);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<AtividadeAlunoStatus> get _filtrado {
    if (_filtro == 'TODOS') return _status;
    if (_filtro == 'ENTREGUE') {
      return _status
          .where((s) => s.status == 'ENTREGUE' || s.status == 'ATRASADA')
          .toList();
    }

    return _status.where((s) => s.status == _filtro).toList();
  }

  int get _totalEntregaram => _status.where((s) => s.entregou).length;

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.atividade.titulo,
          style: const TextStyle(fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _carregando
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$_totalEntregaram / ${_status.length} entregaram',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      _FiltroChip(
                        label: 'Todos',
                        selecionado: _filtro == 'TODOS',
                        onTap: () => setState(() => _filtro = 'TODOS'),
                      ),
                      const SizedBox(width: 4),
                      _FiltroChip(
                        label: 'Entregues',
                        cor: Colors.green,
                        selecionado: _filtro == 'ENTREGUE',
                        onTap: () => setState(() => _filtro = 'ENTREGUE'),
                      ),
                      const SizedBox(width: 4),
                      _FiltroChip(
                        label: 'Pendentes',
                        cor: Colors.orange,
                        selecionado: _filtro == 'PENDENTE',
                        onTap: () => setState(() => _filtro = 'PENDENTE'),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregar,
              child: _filtrado.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum aluno encontrado.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filtrado.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final s = _filtrado[i];
                        final cor = s.status == 'ENTREGUE'
                            ? Colors.green
                            : s.status == 'ATRASADA'
                            ? Colors.orange
                            : Colors.grey;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: cor.withOpacity(0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: cor.withOpacity(0.15),
                                      child: Text(
                                        s.nomeAluno
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: cor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.nomeAluno,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            s.matriculaAluno,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        s.status == 'ENTREGUE'
                                            ? 'Entregue'
                                            : s.status == 'ATRASADA'
                                            ? 'Atrasada'
                                            : 'Pendente',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: cor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Conteúdo da entrega
                                if (s.entregou &&
                                    s.conteudo != null &&
                                    s.conteudo!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  Text(
                                    s.conteudo!,
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],

                                // Arquivo anexado — Bug 2 corrigido:
                                // usa ArquivoChip compartilhado com entregaId
                                if (s.entregou &&
                                    (s.temArquivo ||
                                        s.arquivoNome != null)) ...[
                                  const SizedBox(height: 8),
                                  ArquivoChip(
                                    nome: s.arquivoNome ?? 'Arquivo',
                                    tipo: s.arquivoTipo,
                                    // entregaId habilita o download sob demanda
                                    entregaId: s.entregaId,
                                  ),
                                ],

                                // Data de entrega
                                if (s.entregueEm != null) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_outlined,
                                        size: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Enviado em: ${_formatarData(s.entregueEm!)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

// ── Chip de filtro ────────────────────────────────────────────────────────────

class _FiltroChip extends StatelessWidget {
  final String label;
  final Color cor;
  final bool selecionado;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    this.cor = AppTheme.primary,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selecionado ? cor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selecionado ? cor : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selecionado ? FontWeight.bold : FontWeight.normal,
            color: selecionado ? cor : Colors.white,
          ),
        ),
      ),
    );
  }
}
