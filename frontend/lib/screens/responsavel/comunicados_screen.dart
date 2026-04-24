import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ComunicadosScreen extends StatefulWidget {
  const ComunicadosScreen({super.key});

  @override
  State<ComunicadosScreen> createState() => _ComunicadosScreenState();
}

class _ComunicadosScreenState extends State<ComunicadosScreen> {
  late Future<List<Map<String, dynamic>>> _futureComunicados;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futureComunicados = _buscar();
    });
  }

  Future<List<Map<String, dynamic>>> _buscar() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/comunicado'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(utf8.decode(res.bodyBytes)),
      );
    }
    throw Exception('Erro ao carregar comunicados: ${res.statusCode}');
  }

  Future<void> _marcarLido(int id) async {
    await http.patch(
      Uri.parse('${ApiClient.baseDomain}/comunicado/$id/ler'),
      headers: await ApiClient.getHeaders(),
    );
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunicados'),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureComunicados,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text('${snap.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _carregar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum comunicado recebido.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _carregar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _CartaoComunicado(
                comunicado: lista[i],
                onTap: () async {
                  if (lista[i]['lido'] == false) {
                    await _marcarLido(lista[i]['id']);
                  }
                  if (!mounted) return;
                  _abrirDetalhe(context, lista[i]);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _abrirDetalhe(BuildContext context, Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                c['titulo'] ?? 'Comunicado',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    c['nomeEscola'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    c['nomeAutor'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 13,
                      color: Colors.purple,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Análise gerada por IA · Coordenação Pedagógica',
                      style: TextStyle(fontSize: 11, color: Colors.purple),
                    ),
                  ],
                ),
              ),
              Text(
                c['corpo'] ?? '',
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoComunicado extends StatelessWidget {
  final Map<String, dynamic> comunicado;
  final VoidCallback onTap;

  const _CartaoComunicado({required this.comunicado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lido = comunicado['lido'] as bool? ?? false;

    return Card(
      elevation: 0,
      color: lido ? null : Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: lido ? Colors.grey.shade200 : Colors.orange.shade300,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (!lido)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comunicado['titulo'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: lido ? FontWeight.w500 : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'De: ${comunicado['nomeAutor'] ?? ''} · ${comunicado['nomeEscola'] ?? ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
