import 'package:flutter/material.dart';
import '../../models/aluno.dart';
import '../../services/aluno_service.dart';
import 'form_alunos_screen.dart';
import 'detalhes_alunos_screen.dart';

class ListaAlunoScreen extends StatefulWidget {
  @override
  _ListaAlunoScreenState createState() => _ListaAlunoScreenState();
}

class _ListaAlunoScreenState extends State<ListaAlunoScreen> {
  final AlunoService _alunoService = AlunoService();
  late Future<List<Aluno>> _futureAlunos;

  @override
  void initState() {
    super.initState();
    _carregarAlunos();
  }

  void _carregarAlunos() {
    setState(() {
      _futureAlunos = _alunoService.getAlunos();
    });
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
          IconButton(icon: Icon(Icons.refresh), onPressed: _carregarAlunos),
        ],
      ),
      body: FutureBuilder<List<Aluno>>(
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
            final alunos = snapshot.data!;
            if (alunos.isEmpty) {
              return Center(child: Text("Nenhum aluno cadastrado."));
            }
            return ListView.builder(
              itemCount: alunos.length,
              itemBuilder: (context, index) {
                final aluno = alunos[index];
                return ListTile(
                  title: Text(aluno.nome),
                  subtitle: Text(
                    "RA: ${aluno.matricula} | Turmas: ${aluno.turmas.join(', ')}\nEscola: ${aluno.nomeEscola}",
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deletarAluno(aluno.id),
                  ),
                  onTap: () => _navegarParaDetalhes(aluno.id),
                );
              },
            );
          } else {
            return Center(child: Text("Nenhum aluno encontrado."));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaFormulario(),
        child: Icon(Icons.add),
        tooltip: 'Novo Aluno',
      ),
    );
  }
}
