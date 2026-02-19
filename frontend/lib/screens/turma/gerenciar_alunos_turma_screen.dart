import 'package:flutter/material.dart';
import '../../models/aluno.dart'; // Ajuste o import conforme sua estrutura
import '../../services/aluno_service.dart';
import '../../services/turma_service.dart';

class GerenciarAlunosTurmaScreen extends StatefulWidget {
  final int turmaId;

  const GerenciarAlunosTurmaScreen({Key? key, required this.turmaId})
    : super(key: key);

  @override
  _GerenciarAlunosTurmaScreenState createState() =>
      _GerenciarAlunosTurmaScreenState();
}

class _GerenciarAlunosTurmaScreenState
    extends State<GerenciarAlunosTurmaScreen> {
  final TurmaService _turmaService = TurmaService();
  final AlunoService _alunoService = AlunoService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Aluno> _alunosNaTurma = [];
  List<Aluno> _alunosDisponiveis = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        // 0: Alunos JÁ na turma
        _turmaService.getAlunosByTurma(widget.turmaId),
        // 1: Todos os alunos (paginado) - Trazemos 100 para tentar pegar todos
        _alunoService.getAlunos(page: 0, size: 100),
      ]);

      // --- CORREÇÃO DE CASTING AQUI ---
      // O Future.wait retorna List<dynamic>, então precisamos fazer o cast seguro
      final List<Aluno> alunosNaTurma = (results[0] as List)
          .cast<Aluno>()
          .toList();

      // Tratamento da paginação do AlunoService
      final alunosMap = results[1] as Map<String, dynamic>;
      final List<dynamic> listaJson = alunosMap['content'];

      // Converte JSON para Objetos Aluno
      final List<Aluno> todosAlunos = listaJson
          .map((json) => Aluno.fromJson(json))
          .toList();

      // Lógica para filtrar: Disponíveis = Todos - (Aqueles que já estão na turma)
      final Set<int> idsNaTurma = alunosNaTurma.map((a) => a.id).toSet();

      final List<Aluno> alunosDisponiveis = todosAlunos
          .where((aluno) => !idsNaTurma.contains(aluno.id))
          .toList();

      setState(() {
        _alunosNaTurma = alunosNaTurma;
        _alunosDisponiveis = alunosDisponiveis;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar dados: $e"); // Log para debug
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _adicionarAluno(int alunoId) async {
    // Feedback visual imediato (Opcional: optimistic UI)
    setState(() => _isLoading = true);

    try {
      await _turmaService.adicionarAlunoNaTurma(widget.turmaId, alunoId);

      setState(() {
        _hasChanges =
            true; // Marca que houve alteração para atualizar a tela anterior
      });

      // Recarrega as listas para atualizar a UI
      await _carregarDados();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aluno adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removerAluno(int alunoId) async {
    setState(() => _isLoading = true);

    try {
      await _turmaService.removerAlunoDaTurma(widget.turmaId, alunoId);

      setState(() {
        _hasChanges = true;
      });

      await _carregarDados();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aluno removido da turma.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- Helpers de Construção de UI ---

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Gerenciar Alunos da Turma"),
          backgroundColor: Colors.red.shade900,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_hasChanges),
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text("Erro: $_errorMessage"))
            : Column(
                children: [
                  // --- METADE SUPERIOR: ALUNOS NA TURMA ---
                  _buildSectionTitle(
                    "Alunos Matriculados (${_alunosNaTurma.length})",
                    Icons.check_circle_outline,
                  ),
                  Expanded(
                    flex: 1, // Ocupa metade da tela
                    child: _alunosNaTurma.isEmpty
                        ? Center(
                            child: Text(
                              "Nenhum aluno nesta turma.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _alunosNaTurma.length,
                            separatorBuilder: (_, __) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final aluno = _alunosNaTurma[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade100,
                                  child: Text(
                                    aluno.nome[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                    ),
                                  ),
                                ),
                                title: Text(aluno.nome),
                                subtitle: Text("Matrícula: ${aluno.matricula}"),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Remover da turma",
                                  onPressed: () => _removerAluno(aluno.id),
                                ),
                              );
                            },
                          ),
                  ),

                  Divider(height: 2, thickness: 2),

                  // --- METADE INFERIOR: ALUNOS DISPONÍVEIS ---
                  _buildSectionTitle(
                    "Alunos Disponíveis (${_alunosDisponiveis.length})",
                    Icons.person_add_alt,
                  ),
                  Expanded(
                    flex: 1, // Ocupa a outra metade
                    child: _alunosDisponiveis.isEmpty
                        ? Center(
                            child: Text(
                              "Todos os alunos já estão nesta turma.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _alunosDisponiveis.length,
                            separatorBuilder: (_, __) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final aluno = _alunosDisponiveis[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child: Text(
                                    aluno.nome[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                                title: Text(aluno.nome),
                                subtitle: Text("Matrícula: ${aluno.matricula}"),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.green[700],
                                  ),
                                  tooltip: "Adicionar à turma",
                                  onPressed: () => _adicionarAluno(aluno.id),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
