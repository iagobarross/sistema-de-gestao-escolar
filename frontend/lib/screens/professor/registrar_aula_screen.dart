import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/matriz_curricular.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:http/http.dart' as http;

class RegistrarAulaScreen extends StatefulWidget {
  final MatrizCurricular matriz;
  const RegistrarAulaScreen({required this.matriz, super.key});

  @override
  State<RegistrarAulaScreen> createState() => _RegistrarAulaScreenState();
}

class _RegistrarAulaScreenState extends State<RegistrarAulaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conteudoController = TextEditingController();
  DateTime _dataSelecionada = DateTime.now();
  bool _salvando = false;

  @override
  void dispose() {
    _conteudoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(DateTime.now().year, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dataSelecionada = picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    try {
      final body = {
        'matrizCurricularId': widget.matriz.id,
        'data': _dataSelecionada.toIso8601String().substring(0, 10),
        'conteudo': _conteudoController.text.trim(),
      };

      final res = await http.post(
        Uri.parse('${ApiClient.baseDomain}/aula'),
        headers: await ApiClient.getHeaders(),
        body: jsonEncode(body),
      );

      if (res.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aula registrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(
          jsonDecode(res.body)['erro'] ?? 'Erro ao registrar aula',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
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
        title: const Text('Registrar aula'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info da matriz
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.matriz.nomeDisciplina,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.matriz.nomeTurma,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data
            const Text(
              'Data da aula',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _selecionarData,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(_formatarData(_dataSelecionada)),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Conteúdo
            const Text(
              'Conteúdo ministrado',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _conteudoController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Descreva o conteúdo abordado nessa aula...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe o conteúdo da aula'
                  : null,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Registrar aula',
                        style: TextStyle(fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}
