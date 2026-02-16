import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/turma/detalhes_turmas_screen.dart';
import '../../models/turma.dart';
import '../../services/turma_service.dart';
import 'form_turmas_screen.dart';

class ListaTurmaScreen extends StatefulWidget {
  @override
  _ListaTurmaScreenState createState() => _ListaTurmaScreenState();
}

class _ListaTurmaScreenState extends State<ListaTurmaScreen> {
  final TurmaService _turmaService = TurmaService();
  late Future<List<Turma>> _futureTurmas;

  @override
  void initState() {
    super.initState();
    _carregarTurmas();
  }

  void _carregarTurmas() {
    setState(() {
      _futureTurmas = _turmaService.getTurmas();
    });
  }

  Future<void> _navegarParaDetalhes(int turmaId) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesTurmasScreen(turmaId: turmaId),
      ),
    );
    if (resultado == true) {
      _carregarTurmas();
    }
  }

  Future<void> _navegarParaFormulario({Turma? turma}) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormTurmaScreen(turmaParaEditar: turma),
      ),
    );
    if (resultado == true) {
      _carregarTurmas();
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
        await _turmaService.deleteTurma(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Turma excluída com sucesso!')));
        _carregarTurmas();
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
        title: Text("Turmas"),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _carregarTurmas),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000),
          child: FutureBuilder<List<Turma>>(
            future: _futureTurmas,
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
                final turmas = snapshot.data!;
                if (turmas.isEmpty) {
                  return Center(child: Text("Nenhuma turma cadastrada."));
                }
                return ListView.builder(
                  itemCount: turmas.length,
                  itemBuilder: (context, index) {
                    final turma = turmas[index];
                    return ListTile(
                      title: Text("Série: ${turma.serie}"),
                      subtitle: Text(
                        "Ano: ${turma.ano} | Turno: ${turma.turno}",
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deletarTurma(turma.id),
                      ),
                      onTap: () => _navegarParaDetalhes(turma.id),
                      // TODO: Adicionar um botão/gesto para navegar para a tela de "Gerenciar Alunos da Turma"
                    );
                  },
                );
              } else {
                return Center(child: Text("Nenhuma turma encontrada."));
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaFormulario(),
        child: Icon(Icons.add),
        tooltip: 'Nova Turma',
      ),
    );
  }
}
