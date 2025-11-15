import 'package:flutter/material.dart';
import '../../models/turma.dart';
import '../../services/turma_service.dart';

class FormTurmaScreen extends StatefulWidget {
  final Turma? turmaParaEditar;

  FormTurmaScreen({this.turmaParaEditar});

  @override
  _FormTurmaScreenState createState() => _FormTurmaScreenState();
}

class _FormTurmaScreenState extends State<FormTurmaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TurmaService _service = TurmaService();

  late TextEditingController _anoController;
  late TextEditingController _serieController;
  late TextEditingController _turnoController;

  bool _isEditando = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.turmaParaEditar != null;

    _anoController = TextEditingController(text: _isEditando ? widget.turmaParaEditar!.ano.toString() : '');
    _serieController = TextEditingController(text: _isEditando ? widget.turmaParaEditar!.serie : '');
    _turnoController = TextEditingController(text: _isEditando ? widget.turmaParaEditar!.turno : '');
  }

  @override
  void dispose() {
    _anoController.dispose();
    _serieController.dispose();
    _turnoController.dispose();
    super.dispose();
  }

  Future<void> _salvarTurma() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() { _isLoading = true; });
      String? errorMessage;
      
      try {
        final int? ano = int.tryParse(_anoController.text);
        if (ano == null) {
          throw Exception("Ano deve ser um número válido.");
        }

        if (_isEditando) {
          await _service.updateTurma(
            widget.turmaParaEditar!.id,
            ano,
            _serieController.text,
            _turnoController.text,
          );
        } else {
          await _service.createTurma(
            ano,
            _serieController.text,
            _turnoController.text,
          );
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Turma salva com sucesso!')));
        Navigator.of(context).pop(true);

      } catch (e) {
        errorMessage = e.toString();
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
          if (errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditando ? 'Editar Turma' : 'Nova Turma'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _anoController,
                decoration: InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _serieController,
                decoration: InputDecoration(labelText: 'Série (ex: 6º Ano)'),
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _turnoController,
                decoration: InputDecoration(labelText: 'Turno (ex: Manhã)'),
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarTurma,
                child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}