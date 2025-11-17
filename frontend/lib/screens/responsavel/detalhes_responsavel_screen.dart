import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/responsavel.dart';
import 'package:gestao_escolar_app/services/responsavel_service.dart';
import 'form_responsavel_screen.dart';

class DetalhesResponsavelScreen extends StatefulWidget {
  final int responsavelId;
  DetalhesResponsavelScreen({required this.responsavelId});

  @override
  _DetalhesResponsavelScreenState createState() =>
      _DetalhesResponsavelScreenState();
}

class _DetalhesResponsavelScreenState extends State<DetalhesResponsavelScreen> {
  final ResponsavelService _service = ResponsavelService();
  late Future<Responsavel> _futureResponsavel;

  @override
  void initState() {
    super.initState();
    _carregarResponsavel();
  }

  void _carregarResponsavel() {
    setState(() {
      _futureResponsavel = _service.getResponsavelById(widget.responsavelId);
    });
  }

  Future<void> _navegarParaFormulario(Responsavel responsavel) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FormResponsavelScreen(responsavelParaEditar: responsavel),
      ),
    );
    if (resultado == true) {
      _carregarResponsavel();
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deletarResponsavel(int id) async {
    bool confirmou =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmar Exclusão'),
              content: Text('Deseja realmente excluir este responsável?'),
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
        await _service.deleteResponsavel(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Responsável excluído com sucesso!')),
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
        title: Text("Detalhes do Responsável"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () => _deletarResponsavel(widget.responsavelId),
          ),
        ],
      ),
      body: FutureBuilder<Responsavel>(
        future: _futureResponsavel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final responsavel = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ListTile(
                    title: Text(responsavel.nome),
                    subtitle: Text("Nome"),
                  ),
                  ListTile(
                    title: Text(responsavel.email),
                    subtitle: Text("Email"),
                  ),
                  ListTile(title: Text(responsavel.cpf), subtitle: Text("CPF")),
                  ListTile(
                    title: Text(responsavel.telefone),
                    subtitle: Text("Telefone"),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text("Responsável não encontrado."));
          }
        },
      ),
      floatingActionButton: FutureBuilder<Responsavel>(
        future: _futureResponsavel,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton(
              onPressed: () => _navegarParaFormulario(snapshot.data!),
              child: Icon(Icons.edit),
              tooltip: 'Editar Responsável',
            );
          }
          return Container();
        },
      ),
    );
  }
}
