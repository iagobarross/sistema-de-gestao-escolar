import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/disciplina.dart';
import 'package:gestao_escolar_app/services/disciplina_service.dart';
import 'package:gestao_escolar_app/screens/disciplina/form_disciplina_screen.dart';
import 'package:gestao_escolar_app/screens/disciplina/detalhes_disciplina_screen.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class ListaDisciplinaScreen extends StatefulWidget {
  /// Quando false, oculta o FAB de criação. Coordenador e Diretor só leem.
  final bool podeCadastrar;

  const ListaDisciplinaScreen({this.podeCadastrar = true, super.key});

  @override
  State<ListaDisciplinaScreen> createState() => _ListaDisciplinaScreenState();
}

class _ListaDisciplinaScreenState extends State<ListaDisciplinaScreen> {
  final DisciplinaService _service = DisciplinaService();
  late Future<List<Disciplina>> _futureDisciplinas;
  final _searchController = TextEditingController();
  List<Disciplina> _todas = [];
  List<Disciplina> _filtradas = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _carregar() {
    // FIX: separamos a atribuição da Future do setState para evitar
    // que o callback retorne Future — causa do warning original.
    final future = _service.getDisciplinas();
    future.then((lista) {
      if (mounted) {
        setState(() {
          _todas = lista;
          _filtrar(_searchController.text);
        });
      }
    });
    // Este setState apenas registra a Future para o FutureBuilder;
    // o callback retorna void porque a expressão é uma atribuição simples
    // a uma variável do tipo Future (não await, não async).
    setState(() {
      _futureDisciplinas = future;
    });
  }

  void _filtrar(String termo) {
    setState(() {
      _filtradas = termo.isEmpty
          ? List.from(_todas)
          : _todas
                .where(
                  (d) =>
                      d.nome.toLowerCase().contains(termo.toLowerCase()) ||
                      d.codigo.toLowerCase().contains(termo.toLowerCase()),
                )
                .toList();
    });
  }

  Future<void> _deletar(int id, String nome) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir disciplina'),
        content: Text('Deseja excluir "$nome"?'),
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
      await _service.deleteDisciplina(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Disciplina excluída')));
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
    return Scaffold(
      body: FutureBuilder<List<Disciplina>>(
        future: _futureDisciplinas,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              _todas.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && _todas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text('${snap.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _carregar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou código...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _filtrar('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: _filtrar,
                ),
              ),
              Expanded(
                child: _filtradas.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhuma disciplina encontrada.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _carregar(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filtradas.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, i) {
                            final d = _filtradas[i];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      d.codigo.length > 3
                                          ? d.codigo.substring(0, 3)
                                          : d.codigo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  d.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      'Nota mín.: ${d.notaMinima.toStringAsFixed(1)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${d.cargaHoraria}h',
                                      style: const TextStyle(
                                        fontSize: 12,
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
                                          builder: (_) =>
                                              DetalhesDisciplinaScreen(
                                                disciplinaId: d.id,
                                              ),
                                        ),
                                      );
                                      if (ok == true) _carregar();
                                    } else if (v == 'del') {
                                      _deletar(d.id, d.nome);
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
                                      builder: (_) => DetalhesDisciplinaScreen(
                                        disciplinaId: d.id,
                                      ),
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
            ],
          );
        },
      ),
      floatingActionButton: widget.podeCadastrar
          ? FloatingActionButton.extended(
              onPressed: () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FormDisciplinaScreen(),
                  ),
                );
                if (ok == true) _carregar();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova disciplina'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
