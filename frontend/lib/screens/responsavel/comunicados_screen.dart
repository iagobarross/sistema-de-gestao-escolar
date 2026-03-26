import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
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
    setState(() => _futureComunicados = _buscarComunicados());
  }

  Future<List<Map<String, dynamic>>> _buscarComunicados() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/comunicado'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(utf8.decode(res.bodyBytes)),
      );
    }
    // Se o endpoint ainda não existir, retorna lista vazia
    // sem quebrar a tela
    if (res.statusCode == 404) return [];
    throw Exception('Erro ao carregar comunicados: ${res.statusCode}');
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
                  Text(
                    '${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
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

          final comunicados = snap.data ?? [];

          if (comunicados.isEmpty) {
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
                    'Nenhum comunicado no momento.',
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
              itemCount: comunicados.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _cartaoComunicado(ctx, comunicados[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _cartaoComunicado(BuildContext ctx, Map<String, dynamic> c) {
    final lido = c['lido'] as bool? ?? false;
    final titulo = c['titulo'] as String? ?? 'Sem título';
    final corpo = c['corpo'] as String? ?? '';
    final criadoEm = c['criadoEm'] as String?;
    final nomeEscola = c['nomeEscola'] as String? ?? '';

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
        onTap: () => _abrirComunicado(ctx, c),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!lido)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: lido ? FontWeight.w500 : FontWeight.bold,
                      ),
                    ),
                  ),
                  if (criadoEm != null)
                    Text(
                      _formatarData(criadoEm),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),

              if (nomeEscola.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  nomeEscola,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],

              if (corpo.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  corpo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _abrirComunicado(BuildContext ctx, Map<String, dynamic> c) {
    final titulo = c['titulo'] as String? ?? 'Comunicado';
    final corpo = c['corpo'] as String? ?? '';
    final criadoEm = c['criadoEm'] as String?;
    final nomeEscola = c['nomeEscola'] as String? ?? '';
    final nomeAutor = c['nomeAutor'] as String? ?? 'Escola';

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
                titulo,
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
                    nomeEscola,
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
                    nomeAutor,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),

              if (criadoEm != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatarDataCompleta(criadoEm),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],

              const Divider(height: 28),

              Text(corpo, style: const TextStyle(fontSize: 15, height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarData(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final agora = DateTime.now();
      if (dt.day == agora.day &&
          dt.month == agora.month &&
          dt.year == agora.year) {
        return 'Hoje';
      }
      final diff = agora.difference(dt).inDays;
      if (diff == 1) return 'Ontem';
      if (diff < 7) return 'Há $diff dias';
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _formatarDataCompleta(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const meses = [
        '',
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez',
      ];
      return '${dt.day} de ${meses[dt.month]} de ${dt.year}'
          ' às ${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
