import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/escola.dart';
import 'package:gestao_escolar_app/services/aluno_service.dart';
import 'package:gestao_escolar_app/services/escola_service.dart';
import 'package:gestao_escolar_app/screens/aluno/form_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/aluno/detalhes_alunos_screen.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class ListaAlunoScreen extends StatefulWidget {
  final int? escolaIdFiltro;

  final bool podeCadastrar;

  const ListaAlunoScreen({
    this.escolaIdFiltro,
    this.podeCadastrar = true,
    super.key,
  });

  @override
  State<ListaAlunoScreen> createState() => _ListaAlunoScreenState();
}

class _ListaAlunoScreenState extends State<ListaAlunoScreen> {
  final AlunoService _alunoService = AlunoService();
  final EscolaService _escolaService = EscolaService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();

  Future<Map<String, dynamic>>? _futureAlunos;
  List<Escola> _listaEscolas = [];
  Escola? _escolaFiltro;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.escolaIdFiltro == null) {
      _escolaService.getEscolas().then((e) {
        if (mounted)
          setState(() {
            _listaEscolas = e;
          });
      });
    }
    _carregar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  void _carregar({int page = 0}) {
    setState(() {
      _currentPage = page;
      _futureAlunos = _alunoService.getAlunos(
        page: page,
        size: 15,
        nome: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        matricula: _matriculaController.text.trim().isEmpty
            ? null
            : _matriculaController.text.trim(),
        escolaId: widget.escolaIdFiltro ?? _escolaFiltro?.id,
      );
    });
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _matriculaController,
              decoration: const InputDecoration(
                labelText: 'Matrícula (RA)',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            if (widget.escolaIdFiltro == null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<Escola>(
                value: _escolaFiltro,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Escola',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                hint: const Text('Todas as escolas'),
                items: _listaEscolas
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.nome, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _escolaFiltro = v),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _matriculaController.clear();
                      setState(() => _escolaFiltro = null);
                      Navigator.pop(context);
                      _carregar();
                    },
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _carregar();
                    },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletar(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir aluno'),
        content: const Text(
          'Esta ação não pode ser desfeita. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _alunoService.deleteAluno(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno excluído'),
            backgroundColor: Colors.green,
          ),
        );
        _carregar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final temFiltroAtivo =
        _matriculaController.text.isNotEmpty || _escolaFiltro != null;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _carregar();
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _carregar(),
                    onChanged: (v) {
                      if (v.isEmpty) _carregar();
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: temFiltroAtivo,
                  child: IconButton.outlined(
                    icon: const Icon(Icons.tune),
                    tooltip: 'Filtros',
                    onPressed: _abrirFiltros,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _futureAlunos,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return _erro('${snap.error}');
                }
                if (!snap.hasData) return const SizedBox();

                final content = snap.data!['content'] as List<dynamic>;
                final totalPages = snap.data!['totalPages'] as int;
                final isFirst = snap.data!['first'] as bool;
                final isLast = snap.data!['last'] as bool;
                final totalElements = snap.data!['totalElements'] as int;

                if (content.isEmpty) {
                  return _vazio('Nenhum aluno encontrado');
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Text(
                            '$totalElements resultado${totalElements != 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => _carregar(page: _currentPage),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: content.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 4),
                          itemBuilder: (_, i) {
                            final a = content[i] as Map<String, dynamic>;
                            final turmas =
                                (a['turmas'] as List<dynamic>?) ?? [];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primary.withOpacity(
                                    0.12,
                                  ),
                                  child: Text(
                                    (a['nome'] as String)[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  a['nome'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('RA: ${a['matricula']}'),
                                    if (turmas.isNotEmpty)
                                      Text(
                                        turmas.join(' · '),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (v) async {
                                    if (v == 'ver') {
                                      final ok = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetalhesAlunoScreen(
                                            alunoId: a['id'],
                                          ),
                                        ),
                                      );
                                      if (ok == true) _carregar();
                                    } else if (v == 'del') {
                                      _deletar(a['id']);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'ver',
                                      child: Text('Ver detalhes'),
                                    ),
                                    if (widget.podeCadastrar)
                                      const PopupMenuItem(
                                        value: 'del',
                                        child: Text(
                                          'Excluir',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () async {
                                  final ok = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetalhesAlunoScreen(alunoId: a['id']),
                                    ),
                                  );
                                  if (ok == true) _carregar();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (totalPages > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppTheme.divider),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: isFirst
                                  ? null
                                  : () => _carregar(page: _currentPage - 1),
                            ),
                            Text(
                              '${_currentPage + 1} / $totalPages',
                              style: const TextStyle(fontSize: 13),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: isLast
                                  ? null
                                  : () => _carregar(page: _currentPage + 1),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.podeCadastrar
          ? FloatingActionButton.extended(
              onPressed: () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FormAlunoScreen(
                      escolaIdPreSelecionada: widget.escolaIdFiltro,
                    ),
                  ),
                );
                if (ok == true) _carregar();
              },
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Novo aluno'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _erro(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );

  Widget _vazio(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.person_off_outlined,
          size: 56,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(height: 12),
        Text(msg, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    ),
  );
}
