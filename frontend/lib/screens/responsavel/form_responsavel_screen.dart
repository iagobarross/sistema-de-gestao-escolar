import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/responsavel.dart';
import 'package:gestao_escolar_app/services/responsavel_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class FormResponsavelScreen extends StatefulWidget {
  final Responsavel? responsavelParaEditar;
  const FormResponsavelScreen({super.key, this.responsavelParaEditar});

  @override
  State<FormResponsavelScreen> createState() => _FormResponsavelScreenState();
}

class _FormResponsavelScreenState extends State<FormResponsavelScreen> {
  final _formKey = GlobalKey<FormState>();
  final ResponsavelService _service = ResponsavelService();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _senhaCtrl;
  late final TextEditingController _cpfCtrl;
  late final TextEditingController _telefoneCtrl;

  bool _isEditando = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.responsavelParaEditar != null;
    final r = widget.responsavelParaEditar;
    _nomeCtrl = TextEditingController(text: r?.nome ?? '');
    _emailCtrl = TextEditingController(text: r?.email ?? '');
    _senhaCtrl = TextEditingController();
    _cpfCtrl = TextEditingController(text: r?.cpf ?? '');
    _telefoneCtrl = TextEditingController(text: r?.telefone ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _nomeCtrl,
      _emailCtrl,
      _senhaCtrl,
      _cpfCtrl,
      _telefoneCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      if (_isEditando) {
        await _service.updateResponsavel(
          widget.responsavelParaEditar!.id,
          _nomeCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _cpfCtrl.text.trim(),
          _telefoneCtrl.text.trim(),
          _senhaCtrl.text.isEmpty ? null : _senhaCtrl.text,
        );
      } else {
        await _service.createResponsavel(
          _nomeCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _senhaCtrl.text,
          _cpfCtrl.text.trim(),
          _telefoneCtrl.text.trim(),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(_isEditando ? 'Editar responsável' : 'Novo responsável'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome completo *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'E-mail *',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo obrigatório';
                if (!v.contains('@')) return 'E-mail inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _senhaCtrl,
              decoration: InputDecoration(
                labelText: _isEditando
                    ? 'Nova senha (deixe em branco para manter)'
                    : 'Senha *',
                prefixIcon: const Icon(Icons.lock_outlined),
              ),
              obscureText: true,
              validator: (v) {
                if (!_isEditando && (v == null || v.isEmpty)) {
                  return 'Campo obrigatório';
                }
                if (v != null && v.isNotEmpty && v.length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cpfCtrl,
                    decoration: const InputDecoration(labelText: 'CPF *'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obrigatório';
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 11) return '11 dígitos';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _telefoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isEditando
                          ? 'Salvar alterações'
                          : 'Cadastrar responsável',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
