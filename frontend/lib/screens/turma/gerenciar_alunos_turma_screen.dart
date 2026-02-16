// frontend/lib/screens/turma/gerenciar_alunos_turma_screen.dart
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aluno.dart';
import 'package:gestao_escolar_app/services/aluno_service.dart';
import 'package:gestao_escolar_app/services/turma_service.dart';

class GerenciarAlunosTurmaScreen extends StatefulWidget {
  final int turmaId;
  GerenciarAlunosTurmaScreen({required this.turmaId});

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
        _turmaService.getAlunosByTurma(widget.turmaId),
        _alunoService.getAlunos(),
      ]);

      final List<Aluno> alunosNaTurma = results[0];
      final List<Aluno> todosAlunos = results[1];

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
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _adicionarAluno(int alunoId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _turmaService.adicionarAlunoNaTurma(widget.turmaId, alunoId);
      setState(() {
        _hasChanges = true;
      });
      await _carregarDados();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aluno adicionado!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _removerAluno(int alunoId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _turmaService.removerAlunoDaTurma(widget.turmaId, alunoId);
      setState(() {
        _hasChanges = true;
      });
      await _carregarDados();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aluno removido!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text("Erro: $_errorMessage"));
    }

    return Column(
      children: [
        _buildSectionTitle(
          context,
          "Alunos na Turma (${_alunosNaTurma.length})",
        ),
        Expanded(
          child: _alunosNaTurma.isEmpty
              ? Center(child: Text("Nenhum aluno nesta turma."))
              : ListView.builder(
                  itemCount: _alunosNaTurma.length,
                  itemBuilder: (context, index) {
                    final aluno = _alunosNaTurma[index];
                    return ListTile(
                      title: Text(aluno.nome),
                      subtitle: Text("RA: ${aluno.matricula}"),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removerAluno(aluno.id),
                      ),
                    );
                  },
                ),
        ),
        _buildSectionTitle(
          context,
          "Alunos Disponíveis (${_alunosDisponiveis.length})",
        ),
        Expanded(
          child: _alunosDisponiveis.isEmpty
              ? Center(child: Text("Nenhum aluno disponível para adicionar."))
              : ListView.builder(
                  itemCount: _alunosDisponiveis.length,
                  itemBuilder: (context, index) {
                    final aluno = _alunosDisponiveis[index];
                    return ListTile(
                      title: Text(aluno.nome),
                      subtitle: Text("RA: ${aluno.matricula}"),
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () => _adicionarAluno(aluno.id),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Padding _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
          title: Text("Gerenciar Alunos"),
          backgroundColor: Colors.red.shade900,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(_hasChanges);
            },
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }
}
