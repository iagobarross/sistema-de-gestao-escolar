import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/escola.dart';
import '../../models/aluno.dart';
import '../../services/aluno_service.dart';
import '../../services/escola_service.dart';
import 'form_alunos_screen.dart';
import 'detalhes_alunos_screen.dart';

class ListaAlunoScreen extends StatefulWidget {
  @override
  _ListaAlunoScreenState createState() => _ListaAlunoScreenState();
}

class _ListaAlunoScreenState extends State<ListaAlunoScreen> {
  final AlunoService _alunoService = AlunoService();
  final EscolaService _escolaService = EscolaService();

  Future<Map<String, dynamic>>? _futureAlunos;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();

  List<Escola> _listaEscolas = [];
  Escola? _escola;
  bool _isLoadingEscolas = false;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _carregarEscolas();
    _carregarAlunos();
  }

  Future<void> _carregarEscolas() async {
    setState(() => _isLoadingEscolas = true);
    try {
      final escolas = await _escolaService.getEscolas();
      setState(() {
        _listaEscolas = escolas;
        _isLoadingEscolas = false;
      });
    } catch (e) {
      print("Erro o carregar escolas: $e");
      setState(() => _isLoadingEscolas = false);
    }
  }

  void _carregarAlunos({int page = 0}) {
    setState(() {
      _currentPage = page;
      _futureAlunos = _alunoService.getAlunos(
        page: page,
        size: 10,
        nome: _searchController.text,
        matricula: _matriculaController.text,
        escolaId: _escola?.id,
      );
    });
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filtrar Resultados",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _matriculaController,
                decoration: InputDecoration(
                  labelText: 'Matricula(RA)',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<Escola>(
                value: _escola,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Escola',
                  prefixIcon: Icon(Icons.school_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _listaEscolas.map((escola) {
                  return DropdownMenuItem(
                    value: escola,
                    child: Text(escola.nome, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _escola = val);
                },
                hint: _isLoadingEscolas
                    ? Text("Carregando escolas...")
                    : Text("Selecione uma escola"),
              ),
              SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _matriculaController.clear();
                      setState(() => _escola = null);
                      Navigator.pop(context);
                      _carregarAlunos(page: 0);
                    },
                    child: Text("Limpar Filtros"),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: Icon(Icons.check),
                    label: Text("Aplicar"),
                    onPressed: () {
                      Navigator.pop(context);
                      _carregarAlunos(page: 0);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navegarParaDetalhes(int alunoId) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesAlunoScreen(alunoId: alunoId),
      ),
    );

    if (resultado == true) {
      _carregarAlunos();
    }
  }

  Future<void> _navegarParaFormulario({Aluno? aluno}) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormAlunoScreen(alunoParaEditar: aluno),
      ),
    );
    if (resultado == true) {
      _carregarAlunos();
    }
  }

  Future<void> _deletarAluno(int id) async {
    bool confirmou =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmar Exclusão'),
              content: Text('Deseja realmente excluir este aluno?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Excluir'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmou) {
      if (!mounted) return;
      try {
        await _alunoService.deleteAluno(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Aluno excluído com sucesso!')));
        _carregarAlunos();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alunos"),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          // Mantive seu botão de refresh
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _carregarAlunos(page: 0),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // --- 1. BARRA DE PESQUISA E FILTROS (NOVO) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Pesquisar por nome...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _carregarAlunos(page: 0);
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (_) => _carregarAlunos(page: 0),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: Icon(Icons.filter_list),
                      // Muda a cor se tiver filtro ativo
                      style:
                          (_matriculaController.text.isNotEmpty ||
                              _escola != null)
                          ? IconButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                            )
                          : null,
                      onPressed: _abrirFiltros,
                    ),
                  ],
                ),
              ),

              // --- 2. LISTA DE ALUNOS (ADAPTADO) ---
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  // Mudou para Map
                  future: _futureAlunos,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("Erro: ${snapshot.error}"),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      // Extrai a lista de dentro do objeto de paginação
                      final List<dynamic> alunos = snapshot.data!['content'];
                      final int totalPages = snapshot.data!['totalPages'];
                      final bool isFirst = snapshot.data!['first'];
                      final bool isLast = snapshot.data!['last'];

                      if (alunos.isEmpty) {
                        return Center(child: Text("Nenhum aluno encontrado."));
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: alunos.length,
                              itemBuilder: (context, index) {
                                final aluno =
                                    alunos[index]; // aluno agora é um Map

                                // Tratamento para lista de turmas no JSON
                                String turmasTexto = "Sem turmas";
                                if (aluno['turmas'] != null &&
                                    (aluno['turmas'] as List).isNotEmpty) {
                                  turmasTexto = (aluno['turmas'] as List).join(
                                    ', ',
                                  );
                                }

                                return ListTile(
                                  title: Text(
                                    aluno['nome'],
                                  ), // Acesso via chave ['nome']
                                  subtitle: Text(
                                    "RA: ${aluno['matricula']} | Turmas: $turmasTexto\nEscola: ${aluno['nomeEscola'] ?? 'Não informada'}",
                                  ),
                                  isThreeLine: true,
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deletarAluno(aluno['id']),
                                  ),
                                  onTap: () =>
                                      _navegarParaDetalhes(aluno['id']),
                                );
                              },
                            ),
                          ),

                          // --- 3. CONTROLES DE PAGINAÇÃO (NOVO) ---
                          if (totalPages > 1)
                            Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.grey[50],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.chevron_left),
                                    onPressed: isFirst
                                        ? null
                                        : () => _carregarAlunos(
                                            page: _currentPage - 1,
                                          ),
                                  ),
                                  Text(
                                    "Página ${_currentPage + 1} de $totalPages",
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.chevron_right),
                                    onPressed: isLast
                                        ? null
                                        : () => _carregarAlunos(
                                            page: _currentPage + 1,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    } else {
                      return Center(child: Text("Nenhum aluno encontrado."));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaFormulario(),
        child: Icon(Icons.add),
        tooltip: 'Novo Aluno',
        backgroundColor:
            Colors.red.shade900, // Ajuste para combinar com o AppBar
        foregroundColor: Colors.white,
      ),
    );
  }
}
