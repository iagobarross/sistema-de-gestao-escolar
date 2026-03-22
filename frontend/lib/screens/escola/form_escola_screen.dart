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

  // Controladores da Escola
  late TextEditingController _codigoController;
  late TextEditingController _nomeController;
  late TextEditingController _cnpjController;
  late TextEditingController _enderecoController;

  // Controladores do Diretor (usados apenas na criação)
  late TextEditingController _diretorNomeController;
  late TextEditingController _diretorEmailController;
  late TextEditingController _diretorSenhaController;

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

    // Inicializar os controladores do diretor vazios
    _diretorNomeController = TextEditingController();
    _diretorEmailController = TextEditingController();
    _diretorSenhaController = TextEditingController();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();

    _diretorNomeController.dispose();
    _diretorEmailController.dispose();
    _diretorSenhaController.dispose();
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
          // A atualização não mexe no diretor
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
            Navigator.of(context).pop(true);
          }
        } else {
          // Criação da Escola inclui os dados do Diretor
          await _escolaService.createEscola(
            _codigoController.text,
            _nomeController.text,
            _cnpjController.text,
            _enderecoController.text,
            _diretorNomeController.text,
            _diretorEmailController.text,
            _diretorSenhaController.text,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Escola e Diretor criados com sucesso!')),
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
              SnackBar(content: Text('Erro ao salvar: $errorMessage')),
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Text(
                    'Dados da Escola',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome da Escola',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                    decoration: InputDecoration(
                      labelText: 'Código',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o código';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _cnpjController,
                    decoration: InputDecoration(
                      labelText: 'CNPJ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _enderecoController,
                    decoration: InputDecoration(
                      labelText: 'Endereço',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o endereço';
                      }
                      return null;
                    },
                  ),

                  // SEÇÃO DO DIRETOR (Aparece apenas se não estiver a editar)
                  if (!_isEditando) ...[
                    SizedBox(height: 20),
                    Divider(thickness: 2),
                    SizedBox(height: 10),
                    Text(
                      'Dados do Diretor (Acesso ao Sistema)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _diretorNomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Diretor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome do diretor';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _diretorEmailController,
                      decoration: InputDecoration(
                        labelText: 'Email do Diretor (Login)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o email';
                        }
                        if (!value.contains('@')) {
                          return 'Insira um email válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _diretorSenhaController,
                      decoration: InputDecoration(
                        labelText: 'Senha Inicial do Diretor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      obscureText: true, // Esconde a senha digitada
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                  ],

                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _salvarEscola,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      _isEditando ? 'Atualizar Escola' : 'Criar Escola e Diretor',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}