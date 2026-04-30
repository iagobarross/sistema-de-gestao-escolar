import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class ListaFuncionariosScreen extends StatefulWidget {
  final int? escolaIdFiltro;
  const ListaFuncionariosScreen({this.escolaIdFiltro, super.key});

  @override
  State<ListaFuncionariosScreen> createState() =>
      _ListaFuncionariosScreenState();
}

class _ListaFuncionariosScreenState extends State<ListaFuncionariosScreen> {
  late Future<List<Map<String, dynamic>>> _futureFuncionarios;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _todos = [];
  List<Map<String, dynamic>> _filtrados = [];
  String? _cargoFiltro;

  static const _cargos = [
    'TODOS',
    'DIRETOR',
    'COORDENADOR',
    'SECRETARIA',
    'PROFESSOR',
  ];

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
    final future = _buscar();
    future.then((lista) {
      if (mounted) {
        setState(() {
          _todos = lista;
          _filtrar(_searchController.text);
        });
      }
    });
    setState(() {
      _futureFuncionarios = future;
    });
  }

  Future<List<Map<String, dynamic>>> _buscar() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/funcionario'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar funcionários: ${res.statusCode}');
    }
    final lista = List<Map<String, dynamic>>.from(
      jsonDecode(utf8.decode(res.bodyBytes)),
    );
    if (widget.escolaIdFiltro != null) {
      return lista
          .where((f) => f['escolaId'] == widget.escolaIdFiltro)
          .toList();
    }
    return lista;
  }

  void _filtrar(String termo) {
    setState(() {
      _filtrados = _todos.where((f) {
        final nomeOk =
            termo.isEmpty ||
            (f['nome'] as String).toLowerCase().contains(termo.toLowerCase()) ||
            (f['email'] as String).toLowerCase().contains(termo.toLowerCase());
        final cargoOk =
            _cargoFiltro == null ||
            _cargoFiltro == 'TODOS' ||
            f['cargo'] == _cargoFiltro;
        return nomeOk && cargoOk;
      }).toList();
    });
  }

  Color _cargoColor(String cargo) => switch (cargo) {
    'DIRETOR' => AppTheme.primary,
    'COORDENADOR' => AppTheme.primaryLight,
    'SECRETARIA' => AppTheme.accent,
    'PROFESSOR' => AppTheme.primaryDark,
    _ => AppTheme.primary,
  };

  String _cargoLabel(String cargo) => switch (cargo) {
    'DIRETOR' => 'Diretor',
    'COORDENADOR' => 'Coordenador',
    'SECRETARIA' => 'Secretaria',
    'PROFESSOR' => 'Professor',
    'ADMIN' => 'Admin',
    _ => cargo,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Barra de busca ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou e-mail...',
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

          // ── Filtro por cargo ────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _cargos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final cargo = _cargos[i];
                final selected =
                    _cargoFiltro == cargo ||
                    (cargo == 'TODOS' && _cargoFiltro == null);
                return FilterChip(
                  label: Text(
                    cargo == 'TODOS' ? 'Todos' : _cargoLabel(cargo),
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  selected: selected,
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: selected ? AppTheme.primary : AppTheme.divider,
                  ),
                  onSelected: (_) {
                    setState(
                      () => _cargoFiltro = cargo == 'TODOS' ? null : cargo,
                    );
                    _filtrar(_searchController.text);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          // ── Lista ───────────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureFuncionarios,
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
                if (_filtrados.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum funcionário encontrado.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }

                // Contagem por cargo para o resumo
                final Map<String, int> contagem = {};
                for (final f in _filtrados) {
                  final c = f['cargo'] as String? ?? '';
                  contagem[c] = (contagem[c] ?? 0) + 1;
                }

                return RefreshIndicator(
                  onRefresh: () async => _carregar(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _filtrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final f = _filtrados[i];
                      final cargo = f['cargo'] as String? ?? '';
                      final cor = _cargoColor(cargo);
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: cor.withOpacity(0.12),
                            child: Text(
                              (f['nome'] as String)[0].toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cor,
                              ),
                            ),
                          ),
                          title: Text(
                            f['nome'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            f['email'] ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _cargoLabel(cargo),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: cor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
