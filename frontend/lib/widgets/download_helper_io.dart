import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<void> downloadFile({
  required List<int> bytes,
  required String nome,
  required String tipo,
  required void Function(String mensagem) onSucesso,
  required void Function(String erro) onErro,
}) async {
  try {
    final caminho = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar arquivo',
      fileName: nome,
    );

    if (caminho != null) {
      await File(caminho).writeAsBytes(bytes);
      onSucesso('Arquivo salvo em: $caminho');
    }
  } catch (e) {
    onErro('Erro ao salvar: $e');
  }
}
