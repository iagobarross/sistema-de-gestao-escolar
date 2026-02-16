import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/responsavel/detalhes_responsavel_screen.dart';
import '../../models/responsavel.dart';
import '../../services/responsavel_service.dart';
import 'form_responsavel_screen.dart';

class ListaResponsavelScreen extends StatefulWidget {
  @override
  _ListaResponsavelScreenState createState() => _ListaResponsavelScreenState();
}

class _ListaResponsavelScreenState extends State<ListaResponsavelScreen> {
  final ResponsavelService _responsavelService = ResponsavelService();
  late Future<List<Responsavel>> _futureResponsaveis;

  @override
  void initState() {
    super.initState();
    _carregarResponsaveis();
  }

  void _carregarResponsaveis() {
    setState(() {
      _futureResponsaveis = _responsavelService.getResponsaveis();
    });
  }

  Future<void> _navegarParaDetalhes(int responsavelId) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetalhesResponsavelScreen(responsavelId: responsavelId),
      ),
    );
    if (resultado == true) {
      _carregarResponsaveis();
    }
  }

  Future<void> _navegarParaFormulario({Responsavel? responsavel}) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FormResponsavelScreen(responsavelParaEditar: responsavel),
      ),
    );
    if (resultado == true) {
      _carregarResponsaveis();
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
      if (!mounted) return; // Checagem de segurança
      try {
        await _responsavelService.deleteResponsavel(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Responsável excluído com sucesso!')),
        );
        _carregarResponsaveis();
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
        title: Text("Responsáveis"),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _carregarResponsaveis,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000),
          child: FutureBuilder<List<Responsavel>>(
            future: _futureResponsaveis,
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
                final responsaveis = snapshot.data!;
                if (responsaveis.isEmpty) {
                  return Center(child: Text("Nenhum responsável cadastrado."));
                }
                return ListView.builder(
                  itemCount: responsaveis.length,
                  itemBuilder: (context, index) {
                    final responsavel = responsaveis[index];
                    return ListTile(
                      title: Text(responsavel.nome),
                      subtitle: Text(
                        "CPF: ${responsavel.cpf} | Telefone: ${responsavel.telefone}",
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deletarResponsavel(responsavel.id),
                      ),
                      onTap: () => _navegarParaDetalhes(responsavel.id),
                    );
                  },
                );
              } else {
                return Center(child: Text("Nenhum responsável encontrado."));
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaFormulario(),
        child: Icon(Icons.add),
        tooltip: 'Novo Responsável',
      ),
    );
  }
}
