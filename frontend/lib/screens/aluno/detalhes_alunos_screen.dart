import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aluno.dart';
import 'package:gestao_escolar_app/services/aluno_service.dart';
import 'form_alunos_screen.dart';

class DetalhesAlunoScreen extends StatefulWidget {
  final int alunoId;
  DetalhesAlunoScreen({required this.alunoId});

  @override
  _DetalhesAlunoScreenState createState() => _DetalhesAlunoScreenState();
}

class _DetalhesAlunoScreenState extends State<DetalhesAlunoScreen> {
  final AlunoService _service = AlunoService();
  late Future<Aluno> _futureAluno;

  @override
  void initState() {
    super.initState();
    _carregarAluno();
  }

  void _carregarAluno() {
    setState(() {
      _futureAluno = _service.getAlunoById(widget.alunoId);
    });
  }

  Future<void> _navegarParaFormulario(Aluno aluno) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormAlunoScreen(alunoParaEditar: aluno),
      ),
    );
    if (resultado == true) {
      _carregarAluno();
      Navigator.of(context).pop(true);
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
        await _service.deleteAluno(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Aluno excluído com sucesso!')));
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
        title: Text("Detalhes do Aluno"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => _deletarAluno(widget.alunoId),
          ),
        ],
      ),
      body: FutureBuilder<Aluno>(
        future: _futureAluno,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final aluno = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ListTile(title: Text(aluno.nome), subtitle: Text("Nome")),
                  ListTile(title: Text(aluno.email), subtitle: Text("Email")),
                  ListTile(
                    title: Text(aluno.matricula),
                    subtitle: Text("Matrícula (RA)"),
                  ),
                  ListTile(
                    title: Text(
                      aluno.dataNascimento.toIso8601String().split('T')[0],
                    ),
                    subtitle: Text("Data de Nascimento"),
                  ),
                  ListTile(
                    title: Text(aluno.nomeEscola),
                    subtitle: Text("Escola"),
                  ),
                  ListTile(
                    title: Text(aluno.nomeResponsavel),
                    subtitle: Text("Responsável"),
                  ),
                  ListTile(
                    title: Text(aluno.turmas.toString()),
                    subtitle: Text("Nº de Turmas"),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text("Aluno não encontrado."));
          }
        },
      ),
      floatingActionButton: FutureBuilder<Aluno>(
        future: _futureAluno,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton(
              onPressed: () => _navegarParaFormulario(snapshot.data!),
              child: Icon(Icons.edit),
              tooltip: 'Editar Aluno',
            );
          }
          return Container();
        },
      ),
    );
  }
}
