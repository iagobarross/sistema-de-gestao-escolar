import 'package:flutter/material.dart';
import '../../models/responsavel.dart';
import '../../services/responsavel_service.dart';

class FormResponsavelScreen extends StatefulWidget {
  final Responsavel? responsavelParaEditar;

  FormResponsavelScreen({this.responsavelParaEditar});

  @override
  _FormResponsavelScreenState createState() => _FormResponsavelScreenState();
}

class _FormResponsavelScreenState extends State<FormResponsavelScreen> {
  final _formKey = GlobalKey<FormState>();
  final ResponsavelService _service = ResponsavelService();

  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  late TextEditingController _cpfController;
  late TextEditingController _telefoneController;

  bool _isEditando = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.responsavelParaEditar != null;

    _nomeController = TextEditingController(
      text: _isEditando ? widget.responsavelParaEditar!.nome : '',
    );
    _senhaController =
        TextEditingController(); // Senha fica vazia por padrão na edição
    _emailController = TextEditingController(
      text: _isEditando ? widget.responsavelParaEditar!.email : '',
    );
    _cpfController = TextEditingController(
      text: _isEditando ? widget.responsavelParaEditar!.cpf : '',
    );
    _telefoneController = TextEditingController(
      text: _isEditando ? widget.responsavelParaEditar!.telefone : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvarResponsavel() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      String? errorMessage;
      try {
        if (_isEditando) {
          await _service.updateResponsavel(
            widget.responsavelParaEditar!.id,
            _nomeController.text,
            _emailController.text,
            _cpfController.text,
            _telefoneController.text,
            _senhaController
                .text, // Envia a nova senha (ou null/vazio se não digitou)
          );
        } else {
          await _service.createResponsavel(
            _nomeController.text,
            _emailController.text,
            _senhaController.text, // Senha é obrigatória na criação
            _cpfController.text,
            _telefoneController.text,
          );
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Responsável salvo com sucesso!')),
        );
        Navigator.of(
          context,
        ).pop(true); // Retorna 'true' para recarregar a lista
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
                content: Text(errorMessage),
                backgroundColor: Colors.red,
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
        title: Text(_isEditando ? 'Editar Responsável' : 'Novo Responsável'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Campo obrigatório';
                      if (!value.contains('@')) return 'Email inválido';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _senhaController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: _isEditando
                          ? 'Deixe em branco para manter a atual'
                          : '',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (!_isEditando && (value == null || value.isEmpty))
                        return 'Campo obrigatório';
                      if (value != null && value.isNotEmpty && value.length < 6)
                        return 'Senha deve ter no mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cpfController,
                    decoration: InputDecoration(
                      labelText: 'CPF',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Campo obrigatório';
                      if (value.length != 11) return 'CPF deve ter 11 dígitos';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _telefoneController,
                    decoration: InputDecoration(
                      labelText: 'Telefone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _salvarResponsavel,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Salvar'),
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
