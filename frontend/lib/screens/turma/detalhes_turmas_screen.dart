import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/turma/gerenciar_alunos_turma_screen.dart';
import '../../models/aluno.dart';
import '../../models/turma.dart';
import '../../services/turma_service.dart';
import 'form_turmas_screen.dart';

class DetalhesTurmasScreen extends StatefulWidget {
  final int turmaId;
  DetalhesTurmasScreen({required this.turmaId});

  @override
  _DetalhesTurmaScreenState createState() => _DetalhesTurmaScreenState();
}

class _DetalhesTurmaScreenState extends State<DetalhesTurmasScreen> {
  final TurmaService _service = TurmaService();
  late Future<Turma> _futureTurma;
  late Future<List<Aluno>> _futureAlunos;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    setState(() {
      _futureTurma = _service.getTurmaById(widget.turmaId);
      _futureAlunos = _service.getAlunosByTurma(widget.turmaId);
    });
  }

  Future<void> _navegarParaFormulario(Turma turma) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormTurmaScreen(turmaParaEditar: turma),
      ),
    );
    if (resultado == true) {
      _carregarDados();
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _navegarParaGerenciarAlunos(int turmaId) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        // Chama a nova tela
        builder: (context) => GerenciarAlunosTurmaScreen(turmaId: turmaId),
      ),
    );

    if (resultado == true) {
      _carregarDados();
    }
  }

  Future<void> _deletarTurma(int id) async {
    bool confirmou =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmar Exclusão'),
              content: Text('Deseja realmente excluir esta turma?'),
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
        await _service.deleteTurma(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Turma excluída com sucesso!')));
        Navigator.of(context).pop(true);
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
        title: Text("Detalhes da Turma"),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => _deletarTurma(widget.turmaId),
          ),
        ],
      ),
      body: FutureBuilder<Turma>(
        future: _futureTurma,
        builder: (context, snapshotTurma) {
          if (snapshotTurma.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshotTurma.hasError) {
            return Center(child: Text("Erro: ${snapshotTurma.error}"));
          } else if (snapshotTurma.hasData) {
            final turma = snapshotTurma.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(turma.serie),
                        subtitle: Text("Série"),
                      ),
                      ListTile(
                        title: Text(turma.ano.toString()),
                        subtitle: Text("Ano"),
                      ),
                      ListTile(
                        title: Text(turma.turno),
                        subtitle: Text("Turno"),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Text(
                  "Alunos na Turma",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Expanded(
                  child: FutureBuilder<List<Aluno>>(
                    future: _futureAlunos,
                    builder: (context, snapshotAlunos) {
                      if (snapshotAlunos.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshotAlunos.hasError) {
                        return Center(
                          child: Text(
                            "Erro ao buscar alunos: ${snapshotAlunos.error}",
                          ),
                        );
                      } else if (snapshotAlunos.hasData) {
                        final alunos = snapshotAlunos.data!;
                        if (alunos.isEmpty) {
                          return Center(
                            child: Text("Nenhum aluno nesta turma."),
                          );
                        }
                        return ListView.builder(
                          itemCount: alunos.length,
                          itemBuilder: (context, index) {
                            final aluno = alunos[index];
                            return ListTile(
                              title: Text(aluno.nome),
                              subtitle: Text("RA: ${aluno.matricula}"),
                            );
                          },
                        );
                      } else {
                        return Center(child: Text("Nenhum aluno encontrado."));
                      }
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text("Turma não encontrada."));
          }
        },
      ),
      floatingActionButton: FutureBuilder<Turma>(
        future: _futureTurma,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () => _navegarParaFormulario(snapshot.data!),
                  child: Icon(Icons.edit),
                  tooltip: 'Editar Turma',
                  heroTag: 'editarTurma',
                ),
                SizedBox(height: 16),

                FloatingActionButton(
                  onPressed: () {
                    _navegarParaGerenciarAlunos(snapshot.data!.id);
                  },
                  child: Icon(Icons.person_add),
                  tooltip: 'Gerenciar Alunos',
                  heroTag: 'adicionarAluno',
                  backgroundColor: Colors.blue,
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
