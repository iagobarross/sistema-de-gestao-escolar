import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/disciplina/detalhes_disciplina_screen.dart';
import '../../models/disciplina.dart';
import '../../services/disciplina_service.dart';

import 'form_disciplina_screen.dart';

class ListaDisciplinaScreen extends StatefulWidget {
  @override
  _ListaDisciplinasScreenState createState() => _ListaDisciplinasScreenState();
}

class _ListaDisciplinasScreenState extends State<ListaDisciplinaScreen> {
  final DisciplinaService _disciplinaService = DisciplinaService();
  late Future<List<Disciplina>> _futureDisciplinas;

  @override
  void initState() {
    super.initState();
    _carregarDisciplinas();
  }

  void _carregarDisciplinas() {
    setState(() {
      _futureDisciplinas = _disciplinaService.getDisciplinas();
    });
  }

  Future<void> _navegarParaDetalhes(int disciplinaId) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetalhesDisciplinaScreen(disciplinaId: disciplinaId),
      ),
    );
    if (resultado == true) {
      _carregarDisciplinas();
    }
  }

  Future<void> _navegarParaFormulario({Disciplina? disciplina}) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FormDisciplinaScreen(disciplinaParaEditar: disciplina),
      ),
    );
    if (resultado == true) {
      _carregarDisciplinas();
    }
  }

  Future<void> _deletarDisciplina(int id) async {
    bool confirmou =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confimar Exclusão'),
              content: Text('Deseja realmente excluir esta disciplina?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Excluir'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmou) {
      try {
        await _disciplinaService.deleteDisciplina(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disciplina excluída com sucesso!')),
        );
        _carregarDisciplinas();
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
        title: Text("Disciplinas"),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _carregarDisciplinas,
          ),
        ],
      ),
      body: FutureBuilder<List<Disciplina>>(
        future: _futureDisciplinas,
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
            final disciplinas = snapshot.data!;
            if (disciplinas.isEmpty) {
              return Center(child: Text("Nenhuma disciplina cadastrada."));
            }
            return ListView.builder(
              itemCount: disciplinas.length,
              itemBuilder: (context, index) {
                final disciplina = disciplinas[index];
                return ListTile(
                  title: Text(disciplina.nome),
                  subtitle: Text("${disciplina.descricao}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deletarDisciplina(disciplina.id),
                  ),
                  onTap: () => _navegarParaDetalhes(disciplina.id),
                );
              },
            );
          } else {
            return Center(child: Text("Nenhuma disciplina encontrada."));
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaFormulario(),
        child: Icon(Icons.add),
        tooltip: 'Nova disciplina',
      ),
    );
  }
}
