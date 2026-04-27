import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aluno.dart';
import 'package:gestao_escolar_app/models/escola.dart';
import 'package:gestao_escolar_app/models/responsavel.dart';
import 'package:gestao_escolar_app/services/aluno_service.dart';
import 'package:gestao_escolar_app/services/escola_service.dart';
import 'package:gestao_escolar_app/services/responsavel_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class FormAlunoScreen extends StatefulWidget {
  final Aluno? alunoParaEditar;

  /// Quando fornecido (ex: pelo contexto da Secretaria), a escola já vem
  /// pré-selecionada e o dropdown de escola fica desabilitado.
  final int? escolaIdPreSelecionada;

  const FormAlunoScreen({
    super.key,
    this.alunoParaEditar,
    this.escolaIdPreSelecionada,
  });

  @override
  State<FormAlunoScreen> createState() => _FormAlunoScreenState();
}

class _FormAlunoScreenState extends State<FormAlunoScreen> {
  final _formKey = GlobalKey<FormState>();
  final AlunoService _service = AlunoService();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _senhaCtrl;
  late final TextEditingController _matriculaCtrl;

  DateTime? _dataNascimento;
  Escola? _escolaSelecionada;
  Responsavel? _responsavelSelecionado;

  List<Escola> _escolas = [];
  List<Responsavel> _responsaveis = [];
  bool _isEditando = false;
  bool _salvando = false;
  bool _carregandoDados = true;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.alunoParaEditar != null;
    final a = widget.alunoParaEditar;
    _nomeCtrl = TextEditingController(text: a?.nome ?? '');
    _emailCtrl = TextEditingController(text: a?.email ?? '');
    _senhaCtrl = TextEditingController();
    _matriculaCtrl = TextEditingController(text: a?.matricula ?? '');
    if (a != null) _dataNascimento = a.dataNascimento;
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final futures = await Future.wait([
        EscolaService().getEscolas(),
        ResponsavelService().getResponsaveis(),
      ]);
      if (!mounted) return;
      setState(() {
        _escolas = futures[0] as List<Escola>;
        _responsaveis = futures[1] as List<Responsavel>;

        if (_isEditando) {
          final a = widget.alunoParaEditar!;
          _escolaSelecionada = _escolas
              .where((e) => e.id == a.escolaId)
              .firstOrNull;
          _responsavelSelecionado = _responsaveis
              .where((r) => r.id == a.responsavelId)
              .firstOrNull;
        } else if (widget.escolaIdPreSelecionada != null) {
          // Quando a Secretaria abre o formulário a partir de um contexto
          // já filtrado pela escola, pré-selecionamos automaticamente.
          _escolaSelecionada = _escolas
              .where((e) => e.id == widget.escolaIdPreSelecionada)
              .firstOrNull;
        }
        _carregandoDados = false;
      });
    } catch (_) {
      if (mounted) setState(() => _carregandoDados = false);
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _matriculaCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(2010),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dataNascimento = picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento')),
      );
      return;
    }
    setState(() => _salvando = true);
    try {
      final dto = AlunoRequestDTO(
        nome: _nomeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        senha: _senhaCtrl.text,
        escolaId: _escolaSelecionada!.id,
        matricula: _matriculaCtrl.text.trim(),
        dataNascimento:
            '${_dataNascimento!.year}-${_dataNascimento!.month.toString().padLeft(2, '0')}-${_dataNascimento!.day.toString().padLeft(2, '0')}',
        responsavelId: _responsavelSelecionado!.id,
      );

      if (_isEditando) {
        await _service.updateAluno(widget.alunoParaEditar!.id, dto);
      } else {
        await _service.createAluno(dto);
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
        title: Text(_isEditando ? 'Editar aluno' : 'Novo aluno'),
      ),
      body: _carregandoDados
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Dados pessoais ────────────────────────────────────
                  _secao('Dados pessoais'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo *',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obrigatório'
                        : null,
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
                        child: TextFormField(
                          controller: _matriculaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Matrícula (RA) *',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Campo obrigatório'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selecionarData,
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _dataNascimento == null
                                ? 'Nascimento *'
                                : '${_dataNascimento!.day.toString().padLeft(2, '0')}/${_dataNascimento!.month.toString().padLeft(2, '0')}/${_dataNascimento!.year}',
                            style: TextStyle(
                              color: _dataNascimento == null
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Vínculos ──────────────────────────────────────────
                  const SizedBox(height: 24),
                  _secao('Vínculos'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Escola>(
                    value: _escolaSelecionada,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Escola *',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    items: _escolas
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.nome,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _escolaSelecionada = v),
                    validator: (v) => v == null ? 'Selecione uma escola' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Responsavel>(
                    value: _responsavelSelecionado,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Responsável *',
                      prefixIcon: Icon(Icons.family_restroom_outlined),
                    ),
                    items: _responsaveis
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r.nome,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _responsavelSelecionado = v),
                    validator: (v) =>
                        v == null ? 'Selecione um responsável' : null,
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
                                : 'Cadastrar aluno',
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
