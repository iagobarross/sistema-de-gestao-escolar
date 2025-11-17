import 'package:flutter/material.dart';
import '../../models/escola.dart';
import '../../services/escola_service.dart';
import 'form_escola_screen.dart';

class DetalhesEscolaScreen extends StatefulWidget {
  final int escolaId;

  const DetalhesEscolaScreen({Key? key, required this.escolaId})
    : super(key: key);

  @override
  _DetalhesEscolaScreenState createState() => _DetalhesEscolaScreenState();
}

class _DetalhesEscolaScreenState extends State<DetalhesEscolaScreen> {
  late Future<Escola> _futureEscola;
  final EscolaService _escolaService = EscolaService();
  bool _dadosAlterados = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosEscola();
  }

  void _carregarDadosEscola() {
    setState(() {
      _futureEscola = _escolaService.getEscolaById(widget.escolaId);
    });
  }

  Future<void> _navegarParaEdicao(Escola escola) async {
    final bool? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormEscolaScreen(escolaParaEditar: escola),
      ),
    );

    if (resultado == true) {
      setState(() {
        _dadosAlterados = true;
        _carregarDadosEscola();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dadosAlterados);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Detalhes da Escola"),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _dadosAlterados);
            },
          ),
        ),
        body: FutureBuilder<Escola>(
          future: _futureEscola,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Erro ao carregar detalhes: ${snapshot.error}"),
              );
            }

            if (snapshot.hasData) {
              final escola = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: <Widget>[
                    _buildDetailRow(context, "Nome", escola.nome),
                    _buildDetailRow(context, "Código", escola.codigo),
                    _buildDetailRow(context, "Endereço", escola.endereco),
                    _buildDetailRow(context, "CNPJ", escola.cnpj),
                  ],
                ),
              );
            }

            return Center(child: Text("Escola não encontrada."));
          },
        ),

        floatingActionButton: FutureBuilder<Escola>(
          future: _futureEscola,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FloatingActionButton(
                onPressed: () {
                  _navegarParaEdicao(snapshot.data!);
                },
                child: Icon(Icons.edit),
                tooltip: 'Editar Escola',
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
