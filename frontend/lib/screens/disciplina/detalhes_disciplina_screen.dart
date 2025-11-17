import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/disciplina.dart';
import 'package:gestao_escolar_app/services/disciplina_service.dart';
import 'form_disciplina_screen.dart';

class DetalhesDisciplinaScreen extends StatefulWidget {
  final int disciplinaId;
  DetalhesDisciplinaScreen({required this.disciplinaId});

  @override
  _DetalhesDisciplinaScreenState createState() =>
      _DetalhesDisciplinaScreenState();
}

class _DetalhesDisciplinaScreenState extends State<DetalhesDisciplinaScreen> {
  final DisciplinaService _service = DisciplinaService();
  late Future<Disciplina> _futureDisciplina;

  @override
  void initState() {
    super.initState();
    _carregarDisciplina();
  }

  void _carregarDisciplina() {
    setState(() {
      _futureDisciplina = _service.getDisciplinaById(widget.disciplinaId);
    });
  }

  Future<void> _navegarParaFormulario(Disciplina disciplina) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FormDisciplinaScreen(disciplinaParaEditar: disciplina),
      ),
    );
    if (resultado == true) {
      _carregarDisciplina();
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deletarDisciplina(int id) async {
    bool confirmou =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmar Exclusão'),
              content: Text('Deseja realmente excluir esta disciplina?'),
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
        await _service.deleteDisciplina(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disciplina excluída com sucesso!')),
        );
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
        title: Text("Detalhes da Disciplina"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => _deletarDisciplina(widget.disciplinaId),
          ),
        ],
      ),
      body: FutureBuilder<Disciplina>(
        future: _futureDisciplina,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final disciplina = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ListTile(
                    title: Text(disciplina.nome),
                    subtitle: Text("Nome"),
                  ),
                  ListTile(
                    title: Text(disciplina.codigo),
                    subtitle: Text("Código"),
                  ),
                  ListTile(
                    title: Text(disciplina.descricao),
                    subtitle: Text("Descrição"),
                  ),
                  ListTile(
                    title: Text(disciplina.notaMinima.toString()),
                    subtitle: Text("Nota Mínima"),
                  ),
                  ListTile(
                    title: Text(disciplina.cargaHoraria.toString()),
                    subtitle: Text("Carga Horária (h)"),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text("Disciplina não encontrada."));
          }
        },
      ),
      floatingActionButton: FutureBuilder<Disciplina>(
        future: _futureDisciplina,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton(
              onPressed: () => _navegarParaFormulario(snapshot.data!),
              child: Icon(Icons.edit),
              tooltip: 'Editar Disciplina',
            );
          }
          return Container();
        },
      ),
    );
  }
}
