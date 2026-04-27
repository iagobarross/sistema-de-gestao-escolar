import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/turma.dart';
import 'package:gestao_escolar_app/services/turma_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class FormTurmaScreen extends StatefulWidget {
  final Turma? turmaParaEditar;
  const FormTurmaScreen({super.key, this.turmaParaEditar});

  @override
  State<FormTurmaScreen> createState() => _FormTurmaScreenState();
}

class _FormTurmaScreenState extends State<FormTurmaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TurmaService _service = TurmaService();

  late final TextEditingController _anoCtrl;
  late final TextEditingController _serieCtrl;
  String _turnoSelecionado = 'Manhã';
  bool _salvando = false;
  bool _isEditando = false;

  static const _turnos = ['Manhã', 'Tarde', 'Noite', 'Integral'];

  @override
  void initState() {
    super.initState();
    _isEditando = widget.turmaParaEditar != null;
    final t = widget.turmaParaEditar;
    _anoCtrl = TextEditingController(
      text: t?.ano.toString() ?? DateTime.now().year.toString(),
    );
    _serieCtrl = TextEditingController(text: t?.serie ?? '');
    if (t != null && _turnos.contains(t.turno)) {
      _turnoSelecionado = t.turno;
    }
  }

  @override
  void dispose() {
    _anoCtrl.dispose();
    _serieCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    final ano = int.tryParse(_anoCtrl.text.trim());
    if (ano == null) {
      setState(() => _salvando = false);
      return;
    }
    try {
      if (_isEditando) {
        await _service.updateTurma(
          widget.turmaParaEditar!.id,
          ano,
          _serieCtrl.text.trim(),
          _turnoSelecionado,
        );
      } else {
        await _service.createTurma(
          ano,
          _serieCtrl.text.trim(),
          _turnoSelecionado,
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
        title: Text(_isEditando ? 'Editar turma' : 'Nova turma'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _anoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Ano letivo *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obrigatório';
                      final n = int.tryParse(v);
                      if (n == null || n < 2000) return 'Ano inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _turnoSelecionado,
                    decoration: const InputDecoration(labelText: 'Turno *'),
                    items: _turnos
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _turnoSelecionado = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _serieCtrl,
              decoration: const InputDecoration(
                labelText: 'Série *',
                hintText: 'Ex: 6º Ano',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
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
                  : Text(_isEditando ? 'Salvar alterações' : 'Criar turma'),
            ),
          ],
        ),
      ),
    );
  }
}
