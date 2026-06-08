import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ArquivoSelecionado {
  final String nome;
  final String tipo;
  final String base64;
  final int tamanhoBytes;

  const ArquivoSelecionado({
    required this.nome,
    required this.tipo,
    required this.base64,
    required this.tamanhoBytes,
  });

  String get tamanhoFormatado {
    if (tamanhoBytes < 1024) return '${tamanhoBytes} B';
    if (tamanhoBytes < 1024 * 1024) {
      return '${(tamanhoBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(tamanhoBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class FileUploadHelper {
  static const int maxBytes = 25 * 1024 * 1024;

  static const List<String> extensoesPermitidas = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'csv',
    'zip',
    'rar',
    'png',
    'jpg',
    'jpeg',
    'mp3',
    'mp4',
    'mov',
    'avi',
  ];

  static Future<ArquivoSelecionado?> selecionarArquivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensoesPermitidas,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final bytes = file.bytes;

    if (bytes == null) throw Exception('Não foi possível ler o arquivo.');
    if (bytes.length > maxBytes) {
      throw Exception('Arquivo muito grande. Máximo permitido: 25 MB.');
    }

    final base64Str = base64Encode(bytes);
    final tipo = _inferirTipo(file.extension ?? '');

    return ArquivoSelecionado(
      nome: file.name,
      tipo: tipo,
      base64: base64Str,
      tamanhoBytes: bytes.length,
    );
  }

  static String _inferirTipo(String extensao) {
    switch (extensao.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case 'png':
        return 'image/png';
      case 'jpg':
        return 'image/jpg';
      case 'jpeg':
        return 'image/jpeg';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }

  static IconData iconeParaTipo(String? tipo) {
    if (tipo == null) return Icons.attach_file;
    if (tipo.startsWith('image/')) return Icons.image_outlined;
    if (tipo.startsWith('video/')) return Icons.videocam_outlined;
    if (tipo == 'application/pdf') return Icons.picture_as_pdf_outlined;
    if (tipo.contains('word') || tipo.contains('msword'))
      return Icons.description_outlined;
    if (tipo.contains('excel') || tipo.contains('spreadsheet'))
      return Icons.table_chart_outlined;
    if (tipo.contains('powerpoint') || tipo.contains('presentation'))
      return Icons.slideshow_outlined;
    if (tipo.contains('zip') || tipo.contains('rar'))
      return Icons.archive_outlined;
    return Icons.insert_drive_file_outlined;
  }

  static Color corParaTipo(String? tipo) {
    if (tipo == null) return Colors.grey;
    if (tipo.startsWith('image/')) return Colors.green;
    if (tipo.startsWith('video/')) return Colors.purple;
    if (tipo == 'application/pdf') return Colors.red;
    if (tipo.contains('word') || tipo.contains('msword')) return Colors.blue;
    if (tipo.contains('excel') || tipo.contains('spreadsheet'))
      return Colors.green.shade700;
    if (tipo.contains('powerpoint') || tipo.contains('presentation'))
      return Colors.orange;
    return Colors.blueGrey;
  }
}
