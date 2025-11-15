import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/escola_service.dart';
import '../../models/escola.dart';

class FormEscolaScreen extends StatefulWidget {
  final Escola? escolaParaEditar;

  FormEscolaScreen({this.escolaParaEditar});

  @override
  _FormEscolaScreenState createState() => _FormEscolaScreenState();
}

class _FormEscolaScreenState extends State<FormEscolaScreen> {
  final _formKey = GlobalKey<FormState>();
  final EscolaService _escolaService = EscolaService();

  late TextEditingController _codigoController;
  late TextEditingController _nomeController;
  late TextEditingController _cnpjController;
  late TextEditingController _enderecoController;

  bool _isEditando = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.escolaParaEditar != null;

    _codigoController = TextEditingController(
      text: _isEditando ? widget.escolaParaEditar!.codigo : '',
    );
    _nomeController = TextEditingController(
      text: _isEditando ? widget.escolaParaEditar!.nome : '',
    );
    _cnpjController = TextEditingController(
      text: _isEditando ? widget.escolaParaEditar!.cnpj : '',
    );
    _enderecoController = TextEditingController(
      text: _isEditando ? widget.escolaParaEditar!.endereco : '',
    );
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _salvarEscola() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      String? errorMessage;

      try {
        if (_isEditando) {
          await _escolaService.updateEscola(
            widget.escolaParaEditar!.id,
            _codigoController.text,
            _nomeController.text,
            _cnpjController.text,
            _enderecoController.text,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Escola atualizada com sucesso!')),
            );
            Navigator.of(context).pop(true); // Navega APÓS sucesso
          }
        } else {
          await _escolaService.createEscola(
            _codigoController.text,
            _nomeController.text,
            _cnpjController.text,
            _enderecoController.text,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Escola criada com sucesso!')),
            );
            Navigator.of(context).pop(true); // Navega APÓS sucesso
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
              SnackBar(content: Text('Erro ao salvar escola: $errorMessage')),
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
        title: Text(_isEditando ? 'Editar Escola' : 'Nova Escola'),
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
              SizedBox(height: 20),
              TextFormField(
                controller: _cnpjController,
                decoration: InputDecoration(labelText: 'CNPJ'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CNPJ';
                  }
                  if (value.length != 14) {
                    return 'CNPJ deve ter 14 dígitos';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              TextFormField(
                controller: _enderecoController,
                decoration: InputDecoration(labelText: 'Endereço'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o endereço';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarEscola,
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
