import 'package:flutter/material.dart';
import '../../models/aluno.dart';
import '../../services/aluno_service.dart';

class FormAlunoScreen extends StatefulWidget {
  final Aluno? alunoParaEditar;

  FormAlunoScreen({this.alunoParaEditar});

  @override
  _FormAlunoScreenState createState() => _FormAlunoScreenState();
}

class _FormAlunoScreenState extends State<FormAlunoScreen> {
  final _formKey = GlobalKey<FormState>();
  final AlunoService _service = AlunoService();

  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;
  late TextEditingController _matriculaController;
  late TextEditingController _dataNascimentoController;
  late TextEditingController _escolaIdController;
  late TextEditingController _responsavelIdController;

  bool _isEditando = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.alunoParaEditar != null;

    _nomeController = TextEditingController(
      text: _isEditando ? widget.alunoParaEditar!.nome : '',
    );
    _emailController = TextEditingController(
      text: _isEditando ? widget.alunoParaEditar!.email : '',
    );
    _senhaController = TextEditingController();
    _matriculaController = TextEditingController(
      text: _isEditando ? widget.alunoParaEditar!.matricula : '',
    );
    _dataNascimentoController = TextEditingController(
      text: _isEditando
          ? widget.alunoParaEditar!.dataNascimento.toString()
          : '',
    );
    _escolaIdController = TextEditingController(
      text: _isEditando ? widget.alunoParaEditar!.escolaId.toString() : '',
    );
    _responsavelIdController = TextEditingController(
      text: _isEditando ? widget.alunoParaEditar!.responsavelId.toString() : '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _matriculaController.dispose();
    _dataNascimentoController.dispose();
    _escolaIdController.dispose();
    _responsavelIdController.dispose();
    super.dispose();
  }

  Future<void> _salvarAluno() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      String? errorMessage;

      try {
        // Validação e conversão de IDs
        final int? escolaId = int.tryParse(_escolaIdController.text);
        final int? responsavelId = int.tryParse(_responsavelIdController.text);

        if (escolaId == null || responsavelId == null) {
          throw Exception(
            "IDs de Escola e Responsável devem ser números válidos.",
          );
        }

        // (Adicionar validador de data YYYY-MM-DD se necessário)

        AlunoRequestDTO dto = AlunoRequestDTO(
          nome: _nomeController.text,
          email: _emailController.text,
          senha: _senhaController.text, // (Vazio na edição se não for alterado)
          escolaId: escolaId,
          matricula: _matriculaController.text,
          dataNascimento: _dataNascimentoController.text, // "YYYY-MM-DD"
          responsavelId: responsavelId,
        );

        if (_isEditando) {
          // No update, se a senha estiver vazia, o service NÃO deve atualizá-la
          // (Nosso AlunoServiceImpl já trata isso)
          await _service.updateAluno(widget.alunoParaEditar!.id, dto);
        } else {
          if (dto.senha.isEmpty) {
            // Senha obrigatória na criação
            throw Exception("Senha é obrigatória para criar um novo aluno.");
          }
          await _service.createAluno(dto);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Aluno salvo com sucesso!')));
        Navigator.of(context).pop(true);
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
      appBar: AppBar(title: Text(_isEditando ? 'Editar Aluno' : 'Novo Aluno')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // Usar ListView para evitar overflow
            children: <Widget>[
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty || !v.contains('@'))
                    ? 'Email inválido'
                    : null,
              ),
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: _isEditando ? 'Deixe em branco para manter' : '',
                ),
                obscureText: true,
                validator: (v) => (!_isEditando && (v == null || v.isEmpty))
                    ? 'Campo obrigatório'
                    : null,
              ),
              TextFormField(
                controller: _matriculaController,
                decoration: InputDecoration(labelText: 'Matrícula (RA)'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _dataNascimentoController,
                decoration: InputDecoration(
                  labelText: 'Data Nascimento',
                  hintText: 'AAAA-MM-DD',
                ),
                keyboardType: TextInputType.datetime,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _escolaIdController,
                decoration: InputDecoration(labelText: 'ID da Escola'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _responsavelIdController,
                decoration: InputDecoration(labelText: 'ID do Responsável'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarAluno,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
