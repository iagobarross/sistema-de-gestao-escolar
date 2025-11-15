import 'package:flutter/material.dart';
import '../../services/disciplina_service.dart';
import '../../models/disciplina.dart';

class FormDisciplinaScreen extends StatefulWidget {
  final Disciplina? disciplinaParaEditar;

  FormDisciplinaScreen({this.disciplinaParaEditar});

  @override
  _FormDisciplinaScreenState createState() => _FormDisciplinaScreenState();
}

class _FormDisciplinaScreenState extends State<FormDisciplinaScreen> {
  final _formKey = GlobalKey<FormState>();
  final DisciplinaService _disciplinaService = DisciplinaService();

  late TextEditingController _nomeController;
  late TextEditingController _codigoController;
  late TextEditingController _descricaoController;
  late TextEditingController _notaMinimaController;
  late TextEditingController _cargaHorariaController;

  bool _isEditando = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.disciplinaParaEditar != null;

    _nomeController = TextEditingController(
      text: _isEditando ? widget.disciplinaParaEditar!.nome : '',
    );
    _codigoController = TextEditingController(
      text: _isEditando ? widget.disciplinaParaEditar!.codigo : '',
    );
    _descricaoController = TextEditingController(
      text: _isEditando ? widget.disciplinaParaEditar!.descricao : '',
    );
    _notaMinimaController = TextEditingController(
      text: _isEditando
          ? widget.disciplinaParaEditar!.notaMinima.toString()
          : '',
    );
    _cargaHorariaController = TextEditingController(
      text: _isEditando
          ? widget.disciplinaParaEditar!.cargaHoraria.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _descricaoController.dispose();
    _notaMinimaController.dispose();
    _cargaHorariaController.dispose();
    super.dispose();
  }

  Future<void> _salvarDisciplina() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      String? errorMessage;

      try {
        final double? notaMinima = double.tryParse(_notaMinimaController.text);
        final int? cargaHoraria = int.tryParse(_cargaHorariaController.text);
        if (notaMinima == null) {
          throw Exception(
            "Valor inválido. Use ponto (.) como separador decimal.",
          );
        }
        if (cargaHoraria == null) {
          throw Exception("Valor inválido.");
        }

        if (_isEditando) {
          await _disciplinaService.updateDisciplina(
            widget.disciplinaParaEditar!.id,
            _codigoController.text,
            _descricaoController.text,
            _nomeController.text,
            notaMinima,
            cargaHoraria,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Disciplina atualizada com sucesso!')),
            );
            Navigator.of(context).pop(true);
          }
        } else {
          await _disciplinaService.createDisciplina(
            _descricaoController.text,
            _codigoController.text,
            _nomeController.text,
            notaMinima,
            cargaHoraria,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Disciplina criada com sucesso')),
            );
            Navigator.of(context).pop(true);
          }
        }
      } catch (e) {
        errorMessage = e.toString();
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          if (errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao salvar disciplina: $errorMessage'),
              ),
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
        title: Text(_isEditando ? 'Editar Disciplina' : 'Nova Disciplina'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _codigoController,
                decoration: InputDecoration(labelText: 'Código'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o código';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _notaMinimaController,
                decoration: InputDecoration(labelText: 'Nota Mínima'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a nota mínima';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: _cargaHorariaController,
                decoration: InputDecoration(labelText: 'Carga Horária'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a carga horária';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarDisciplina,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(_isEditando ? 'Atualizar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
