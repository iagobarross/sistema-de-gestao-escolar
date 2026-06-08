import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/atividade.dart';
import 'package:gestao_escolar_app/services/atividade_service.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:gestao_escolar_app/widgets/arquivo_chip.dart';
import 'package:gestao_escolar_app/widgets/file_upload_helper.dart';
import 'package:http/http.dart' as http;

class AtividadesAlunoScreen extends StatefulWidget {
  const AtividadesAlunoScreen({super.key});

  @override
  State<AtividadesAlunoScreen> createState() => _AtividadesAlunoScreenState();
}

class _AtividadesAlunoScreenState extends State<AtividadesAlunoScreen> {
  final _service = AtividadeService();
  List<Atividade> _atividades = [];
  Map<int, AtividadeEntrega> _entregasMap = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final payload = await AuthService().getPayload();
      final meuId = payload?['id'] as int?;
      if (meuId == null) return;

      final resTurmas = await http.get(
        Uri.parse('${ApiClient.baseDomain}/turma'),
        headers: await ApiClient.getHeaders(),
      );

      List<Atividade> todasAtividades = [];
      if (resTurmas.statusCode == 200) {
        final listaTurmas =
            jsonDecode(utf8.decode(resTurmas.bodyBytes)) as List;
        for (final t in listaTurmas) {
          final tAtiv = await _service.porTurma(t['id']);
          todasAtividades.addAll(tAtiv);
        }
      }

      final entregas = await _service.minhasEntregas();
      final map = {for (final e in entregas) e.atividadeId: e};

      if (mounted) {
        setState(() {
          _atividades = todasAtividades;
          _entregasMap = map;
          _carregando = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirModalEntrega(Atividade a) async {
    final entregaExistente = _entregasMap[a.id];
    final conteudoCtrl = TextEditingController(
      text: entregaExistente?.conteudo ?? '',
    );
    ArquivoSelecionado? arquivoNovo;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                a.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (a.descricao.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  a.descricao,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Campo de texto
              TextField(
                controller: conteudoCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Resposta / comentário (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Arquivo já enviado anteriormente ─────────────────────
              if (entregaExistente != null &&
                  (entregaExistente.temArquivo ||
                      entregaExistente.arquivoNome != null)) ...[
                const Text(
                  'Arquivo enviado anteriormente:',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                ArquivoChip(
                  nome: entregaExistente.arquivoNome ?? 'Arquivo',
                  tipo: entregaExistente.arquivoTipo,
                  // Passa entregaId para habilitar download
                  entregaId: entregaExistente.id,
                ),
                const SizedBox(height: 4),
              ],

              // ── Novo arquivo selecionado ──────────────────────────────
              if (arquivoNovo != null) ...[
                const Text(
                  'Novo arquivo (substituirá o anterior):',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                ArquivoChip(
                  nome: arquivoNovo!.nome,
                  tipo: arquivoNovo!.tipo,
                  tamanho: arquivoNovo!.tamanhoFormatado,
                  onRemover: () => setModal(() => arquivoNovo = null),
                ),
                const SizedBox(height: 4),
              ],

              // Botão de selecionar arquivo
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final selecionado =
                        await FileUploadHelper.selecionarArquivo();
                    if (selecionado != null) {
                      setModal(() => arquivoNovo = selecionado);
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('$e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  arquivoNovo != null ? Icons.swap_horiz : Icons.attach_file,
                ),
                label: Text(
                  arquivoNovo != null
                      ? 'Trocar arquivo'
                      : entregaExistente?.temArquivo == true
                      ? 'Substituir arquivo'
                      : 'Anexar arquivo',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PDF, Word, Excel, PowerPoint, imagens, ZIP… • Máx: 10 MB',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 16),

              // Botão de enviar
              _BotaoEnviar(
                isEdicao: entregaExistente != null,
                onEnviar: () async {
                  await _service.entregar(
                    atividadeId: a.id,
                    conteudo: conteudoCtrl.text.trim(),
                    arquivoBase64: arquivoNovo?.base64,
                    arquivoNome: arquivoNovo?.nome,
                    arquivoTipo: arquivoNovo?.tipo,
                  );
                  if (ctx.mounted) Navigator.pop(ctx, true);
                },
                onErro: (msg) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(msg), backgroundColor: Colors.red),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) _carregar();
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator());

    if (_atividades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nenhuma atividade disponível.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _atividades.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final a = _atividades[i];
          final entrega = _entregasMap[a.id];
          final entregue = entrega != null;
          final atrasada = a.atrasada && !entregue;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: atrasada
                    ? Colors.red.shade200
                    : entregue
                    ? Colors.green.shade200
                    : AppTheme.divider,
                width: atrasada || entregue ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          a.titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _StatusChip(
                        entregue: entregue,
                        atrasada: atrasada,
                        status: entrega?.status,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${a.nomeDisciplina} · ${a.nomeTurma}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (a.descricao.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      a.descricao,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Arquivo anexado — visível no card da lista
                  if (entregue &&
                      (entrega.temArquivo || entrega.arquivoNome != null)) ...[
                    const SizedBox(height: 8),
                    ArquivoChip(
                      nome: entrega.arquivoNome ?? 'Arquivo',
                      tipo: entrega.arquivoTipo,
                      entregaId: entrega.id,
                    ),
                  ],

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: atrasada ? Colors.red : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Entrega: ${_formatarData(a.dataEntrega)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: atrasada ? Colors.red : AppTheme.textSecondary,
                          fontWeight: atrasada
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (!a.atrasada || entregue)
                        TextButton(
                          onPressed: () => _abrirModalEntrega(a),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            entregue ? 'Ver / Editar' : 'Entregar',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final bool entregue;
  final bool atrasada;
  final StatusEntrega? status;
  const _StatusChip({
    required this.entregue,
    required this.atrasada,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    Color cor;
    if (entregue) {
      label = status == StatusEntrega.ATRASADA ? 'Atrasada' : 'Entregue';
      cor = status == StatusEntrega.ATRASADA ? Colors.orange : Colors.green;
    } else if (atrasada) {
      label = 'Prazo encerrado';
      cor = Colors.red;
    } else {
      label = 'Pendente';
      cor = AppTheme.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cor),
      ),
    );
  }
}

class _BotaoEnviar extends StatefulWidget {
  final bool isEdicao;
  final Future<void> Function() onEnviar;
  final void Function(String) onErro;
  const _BotaoEnviar({
    required this.isEdicao,
    required this.onEnviar,
    required this.onErro,
  });

  @override
  State<_BotaoEnviar> createState() => _BotaoEnviarState();
}

class _BotaoEnviarState extends State<_BotaoEnviar> {
  bool _salvando = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _salvando
            ? null
            : () async {
                setState(() => _salvando = true);
                try {
                  await widget.onEnviar();
                } catch (e) {
                  widget.onErro('$e');
                  setState(() => _salvando = false);
                }
              },
        child: _salvando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(widget.isEdicao ? 'Atualizar entrega' : 'Enviar atividade'),
      ),
    );
  }
}
