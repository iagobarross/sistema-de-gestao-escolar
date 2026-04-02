import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/escola.dart';
import 'package:gestao_escolar_app/services/escola_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class FormEscolaScreen extends StatefulWidget {
  final Escola? escolaParaEditar;
  const FormEscolaScreen({super.key, this.escolaParaEditar});

  @override
  State<FormEscolaScreen> createState() => _FormEscolaScreenState();
}

class _FormEscolaScreenState extends State<FormEscolaScreen> {
  final _formKey = GlobalKey<FormState>();
  final EscolaService _service = EscolaService();

  late final TextEditingController _codigoCtrl;
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _cnpjCtrl;
  late final TextEditingController _enderecoCtrl;
  late final TextEditingController _diretorNomeCtrl;
  late final TextEditingController _diretorEmailCtrl;
  late final TextEditingController _diretorSenhaCtrl;

  bool _isEditando = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.escolaParaEditar != null;
    final e = widget.escolaParaEditar;
    _codigoCtrl = TextEditingController(text: e?.codigo ?? '');
    _nomeCtrl = TextEditingController(text: e?.nome ?? '');
    _cnpjCtrl = TextEditingController(text: e?.cnpj ?? '');
    _enderecoCtrl = TextEditingController(text: e?.endereco ?? '');
    _diretorNomeCtrl = TextEditingController();
    _diretorEmailCtrl = TextEditingController();
    _diretorSenhaCtrl = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [
      _codigoCtrl,
      _nomeCtrl,
      _cnpjCtrl,
      _enderecoCtrl,
      _diretorNomeCtrl,
      _diretorEmailCtrl,
      _diretorSenhaCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      if (_isEditando) {
        await _service.updateEscola(
          widget.escolaParaEditar!.id,
          _codigoCtrl.text.trim(),
          _nomeCtrl.text.trim(),
          _cnpjCtrl.text.trim(),
          _enderecoCtrl.text.trim(),
        );
      } else {
        await _service.createEscola(
          _codigoCtrl.text.trim(),
          _nomeCtrl.text.trim(),
          _cnpjCtrl.text.trim(),
          _enderecoCtrl.text.trim(),
          _diretorNomeCtrl.text.trim(),
          _diretorEmailCtrl.text.trim(),
          _diretorSenhaCtrl.text,
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
        title: Text(_isEditando ? 'Editar escola' : 'Nova escola'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _secao('Dados da escola'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome da escola *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _codigoCtrl,
                    decoration: const InputDecoration(labelText: 'Código *'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _cnpjCtrl,
                    decoration: const InputDecoration(
                      labelText: 'CNPJ *',
                      hintText: '00.000.000/0001-00',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Obrigatório';
                      final digits = v.replaceAll(RegExp(r'\D'), '');
                      if (digits.length != 14)
                        return 'CNPJ deve ter 14 dígitos';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _enderecoCtrl,
              decoration: const InputDecoration(
                labelText: 'Endereço *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
            ),

            if (!_isEditando) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              _secao('Dados do Diretor'),
              const SizedBox(height: 4),
              Text(
                'O diretor receberá acesso ao sistema com estas credenciais.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diretorNomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome completo *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Campo obrigatório'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diretorEmailCtrl,
                decoration: const InputDecoration(
                  labelText: 'E-mail de acesso *',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                  if (!v.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diretorSenhaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Senha inicial *',
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
            ],

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
                          : 'Criar escola e diretor',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secao(String titulo) => Text(
    titulo,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppTheme.primary,
    ),
  );
}
