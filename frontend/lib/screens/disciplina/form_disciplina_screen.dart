import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/disciplina.dart';
import 'package:gestao_escolar_app/services/disciplina_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class FormDisciplinaScreen extends StatefulWidget {
  final Disciplina? disciplinaParaEditar;
  const FormDisciplinaScreen({super.key, this.disciplinaParaEditar});

  @override
  State<FormDisciplinaScreen> createState() => _FormDisciplinaScreenState();
}

class _FormDisciplinaScreenState extends State<FormDisciplinaScreen> {
  final _formKey = GlobalKey<FormState>();
  final DisciplinaService _service = DisciplinaService();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _codigoCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _notaMinimaCtrl;
  late final TextEditingController _cargaHorariaCtrl;

  bool _isEditando = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.disciplinaParaEditar != null;
    final d = widget.disciplinaParaEditar;
    _nomeCtrl = TextEditingController(text: d?.nome ?? '');
    _codigoCtrl = TextEditingController(text: d?.codigo ?? '');
    _descricaoCtrl = TextEditingController(text: d?.descricao ?? '');
    _notaMinimaCtrl = TextEditingController(
      text: d != null ? d.notaMinima.toStringAsFixed(1) : '5.0',
    );
    _cargaHorariaCtrl = TextEditingController(
      text: d?.cargaHoraria.toString() ?? '',
    );
  }

  @override
  void dispose() {
    for (final c in [
      _nomeCtrl,
      _codigoCtrl,
      _descricaoCtrl,
      _notaMinimaCtrl,
      _cargaHorariaCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final notaMinima = double.parse(
        _notaMinimaCtrl.text.trim().replaceAll(',', '.'),
      );
      final cargaHoraria = int.parse(_cargaHorariaCtrl.text.trim());

      if (_isEditando) {
        await _service.updateDisciplina(
          widget.disciplinaParaEditar!.id,
          _nomeCtrl.text.trim(),
          _codigoCtrl.text.trim(),
          _descricaoCtrl.text.trim(),
          notaMinima,
          cargaHoraria,
        );
      } else {
        await _service.createDisciplina(
          _nomeCtrl.text.trim(),
          _codigoCtrl.text.trim(),
          _descricaoCtrl.text.trim(),
          notaMinima,
          cargaHoraria,
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
        title: Text(_isEditando ? 'Editar disciplina' : 'Nova disciplina'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome da disciplina *',
              ),
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
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _notaMinimaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nota mínima *',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obrigatório';
                      final n = double.tryParse(v.replaceAll(',', '.'));
                      if (n == null || n < 0 || n > 10) {
                        return 'Entre 0 e 10';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cargaHorariaCtrl,
                    decoration: const InputDecoration(labelText: 'Carga (h) *'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Obrigatório';
                      if (int.tryParse(v) == null) return 'Inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricaoCtrl,
              decoration: const InputDecoration(labelText: 'Descrição *'),
              maxLines: 3,
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
                  : Text(
                      _isEditando ? 'Salvar alterações' : 'Criar disciplina',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
