import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/responsavel.dart';
import 'package:gestao_escolar_app/services/responsavel_service.dart';
import 'package:gestao_escolar_app/screens/responsavel/form_responsavel_screen.dart';
import 'package:gestao_escolar_app/screens/responsavel/detalhes_responsavel_screen.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class ListaResponsavelScreen extends StatefulWidget {
  final bool podeCadastrar;
  const ListaResponsavelScreen({this.podeCadastrar = true, super.key});

  @override
  State<ListaResponsavelScreen> createState() => _ListaResponsavelScreenState();
}

class _ListaResponsavelScreenState extends State<ListaResponsavelScreen> {
  final ResponsavelService _service = ResponsavelService();
  late Future<List<Responsavel>> _futureResponsaveis;
  final _searchController = TextEditingController();
  List<Responsavel> _todos = [];
  List<Responsavel> _filtrados = [];

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
    // FIX: separamos a criação da Future do setState para evitar que o
    // callback retorne Future — padrão idêntico ao da ListaDisciplinaScreen.
    final future = _service.getResponsaveis();
    future.then((lista) {
      if (mounted) {
        setState(() {
          _todos = lista;
          _filtrar(_searchController.text);
        });
      }
    });
    setState(() {
      _futureResponsaveis = future;
    });
  }

  void _filtrar(String termo) {
    setState(() {
      _filtrados = termo.isEmpty
          ? List.from(_todos)
          : _todos
                .where(
                  (r) =>
                      r.nome.toLowerCase().contains(termo.toLowerCase()) ||
                      r.cpf.contains(termo),
                )
                .toList();
    });
  }

  Future<void> _deletar(int id, String nome) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir responsável'),
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
      await _service.deleteResponsavel(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Responsável excluído')));
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
      body: FutureBuilder<List<Responsavel>>(
        future: _futureResponsaveis,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              _todos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError && _todos.isEmpty) {
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
                    hintText: 'Buscar por nome ou CPF...',
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
                child: _filtrados.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum responsável encontrado.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _carregar(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filtrados.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, i) {
                            final r = _filtrados[i];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.withOpacity(0.1),
                                  child: Text(
                                    r.nome[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  r.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  'CPF: ${r.cpf}  ·  ${r.telefone}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (v) async {
                                    if (v == 'ver') {
                                      final ok = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetalhesResponsavelScreen(
                                                responsavelId: r.id,
                                              ),
                                        ),
                                      );
                                      if (ok == true) _carregar();
                                    } else if (v == 'del') {
                                      _deletar(r.id, r.nome);
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
                                      builder: (_) => DetalhesResponsavelScreen(
                                        responsavelId: r.id,
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
                    builder: (_) => const FormResponsavelScreen(),
                  ),
                );
                if (ok == true) _carregar();
              },
              icon: const Icon(Icons.add),
              label: const Text('Novo responsável'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
