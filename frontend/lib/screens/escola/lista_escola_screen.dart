import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/escola.dart';
import 'package:gestao_escolar_app/services/escola_service.dart';
import 'package:gestao_escolar_app/screens/escola/form_escola_screen.dart';
import 'package:gestao_escolar_app/screens/escola/escola_hub_screen.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class ListaEscolaScreen extends StatefulWidget {
  final int? escolaIdFiltro;

  final bool podeCadastrar;

  const ListaEscolaScreen({
    this.escolaIdFiltro,
    this.podeCadastrar = true,
    super.key,
  });

  @override
  State<ListaEscolaScreen> createState() => _ListaEscolaScreenState();
}

class _ListaEscolaScreenState extends State<ListaEscolaScreen> {
  final EscolaService _service = EscolaService();
  late Future<List<Escola>> _futureEscolas;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    // FIX: bloco {} garante que o callback retorna void, não Future.
    setState(() {
      if (widget.escolaIdFiltro != null) {
        // Diretor: busca apenas sua escola por ID e empacota em lista
        _futureEscolas = _service
            .getEscolaById(widget.escolaIdFiltro!)
            .then((e) => [e]);
      } else {
        _futureEscolas = _service.getEscolas();
      }
    });
  }

  Future<void> _deletar(int id, String nome) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir escola'),
        content: Text(
          'Deseja excluir "$nome"? Esta ação não pode ser desfeita.',
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
      await _service.deleteEscola(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escola excluída'),
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
    return Scaffold(
      body: FutureBuilder<List<Escola>>(
        future: _futureEscolas,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
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

          final escolas = snap.data ?? [];
          if (escolas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 56,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhuma escola encontrada.',
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
              itemCount: escolas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final escola = escolas[i];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.school_outlined,
                        color: AppTheme.primary,
                      ),
                    ),
                    title: Text(
                      escola.nome,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${escola.codigo}  ·  ${escola.endereco}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (v) async {
                        if (v == 'ver') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EscolaHubScreen(
                                escola: escola,
                                podeGerenciar: widget.podeCadastrar,
                              ),
                            ),
                          );
                          _carregar();
                        } else if (v == 'del') {
                          _deletar(escola.id, escola.nome);
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
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EscolaHubScreen(
                            escola: escola,
                            podeGerenciar: widget.podeCadastrar,
                          ),
                        ),
                      );
                      _carregar();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: widget.podeCadastrar
          ? FloatingActionButton.extended(
              onPressed: () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const FormEscolaScreen()),
                );
                if (ok == true) _carregar();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova escola'),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
