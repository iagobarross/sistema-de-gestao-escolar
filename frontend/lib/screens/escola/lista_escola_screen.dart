import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/escola_service.dart';

import '../../models/escola.dart';
import 'form_escola_screen.dart';

class ListaEscolaScreen extends StatefulWidget {
  @override
  _ListaEscolasScreenState createState() => _ListaEscolasScreenState();
}

class _ListaEscolasScreenState extends State<ListaEscolaScreen> {
  final EscolaService _escolaService = EscolaService();
  late Future<List<Escola>> _futureEscolas;

  @override
  void initState() {
    super.initState();
    _carregarEscolas();
  }

  void _carregarEscolas() {
    setState(() {
      _futureEscolas = _escolaService.getEscolas();
    });
  }

  Future<void> _navegarParaFormulario({Escola? escola}) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormEscolaScreen(escolaParaEditar: escola),
      ),
    );
    if (resultado == true) {
      _carregarEscolas();
    }
  }

  Future<void> _deletarEscola(int id) async {
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
        await _escolaService.deleteEscola(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Escola excluída com sucesso!')));
        _carregarEscolas();
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
        title: Text("Escolas"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _carregarEscolas),
        ],
      ),
      body: FutureBuilder<List<Escola>>(
        future: _futureEscolas,
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
            final escolas = snapshot.data!;
            if (escolas.isEmpty) {
              return Center(child: Text("Nenhuma escola cadastrada."));
            }
            return ListView.builder(
              itemCount: escolas.length,
              itemBuilder: (context, index) {
                final escola = escolas[index];
                return ListTile(
                  title: Text(escola.nome),
                  subtitle: Text(
                    "Código: ${escola.codigo} - End: ${escola.endereco}",
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deletarEscola(escola.id),
                  ),
                  onTap: () => _navegarParaFormulario(escola: escola),
                );
              },
            );
          } else {
            return Center(child: Text("Nenhuma escola encontrada."));
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaFormulario(),
        child: Icon(Icons.add),
        tooltip: 'Nova Escola',
      ),
    );
  }
}
