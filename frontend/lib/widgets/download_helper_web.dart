import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadFile({
  required List<int> bytes,
  required String nome,
  required String tipo,
  required void Function(String mensagem) onSucesso,
  required void Function(String erro) onErro,
}) async {
  try {
    final base64Str = base64Encode(bytes);
    final dataUrl = 'data:$tipo;base64,$base64Str';

    html.AnchorElement(href: dataUrl)
      ..setAttribute('download', nome)
      ..click();

    onSucesso('Download iniciado.');
  } catch (e) {
    onErro('Erro ao salvar na web: $e');
  }
}
