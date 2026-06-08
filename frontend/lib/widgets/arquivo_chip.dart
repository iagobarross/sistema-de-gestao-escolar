import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/atividade_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:gestao_escolar_app/widgets/download_helper.dart';
import 'package:gestao_escolar_app/widgets/file_upload_helper.dart';

class ArquivoChip extends StatefulWidget {
  final String nome;
  final String? tipo;
  final String? tamanho;
  final int? entregaId;
  final VoidCallback? onRemover;

  const ArquivoChip({
    required this.nome,
    this.tipo,
    this.tamanho,
    this.entregaId,
    this.onRemover,
    super.key,
  });

  @override
  State<ArquivoChip> createState() => _ArquivoChipState();
}

class _ArquivoChipState extends State<ArquivoChip> {
  bool _baixando = false;

  Future<void> _baixar() async {
    if (widget.entregaId == null) return;
    setState(() => _baixando = true);
    try {
      final data = await AtividadeService().baixarArquivo(widget.entregaId!);
      if (data == null || !mounted) return;

      final bytes = base64Decode(data['arquivoBase64']!);
      await downloadFile(
        bytes: bytes,
        nome: data['arquivoNome'] ?? widget.nome,
        tipo: data['arquivoTipo'] ?? 'application/octet-stream',
        onSucesso: (String mensagem) {},
        onErro: (String erro) {},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download iniciado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _baixando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = FileUploadHelper.corParaTipo(widget.tipo);
    final icone = FileUploadHelper.iconeParaTipo(widget.tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: cor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nome,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.tamanho != null)
                  Text(
                    widget.tamanho!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          // Botão download
          if (widget.entregaId != null)
            _baixando
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cor,
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.download_outlined, color: cor, size: 18),
                    tooltip: 'Baixar arquivo',
                    onPressed: _baixar,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
          // Botão remover (apenas ao selecionar novo arquivo)
          if (widget.onRemover != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.red),
              onPressed: widget.onRemover,
              padding: const EdgeInsets.only(left: 4),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
