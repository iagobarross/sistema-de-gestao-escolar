import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aula.dart';
import 'package:gestao_escolar_app/models/matriz_curricular.dart';
import 'package:gestao_escolar_app/screens/chamada/chamada_screen.dart';
import 'package:gestao_escolar_app/screens/professor/registrar_aula_screen.dart';
import 'package:gestao_escolar_app/screens/professor/lancar_notas_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class DiarioScreen extends StatefulWidget {
  final MatrizCurricular matriz;
  const DiarioScreen({required this.matriz, super.key});

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  late Future<List<Aula>> _futureAulas;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    // FIX: bloco {} garante que o callback retorna void, não Future.
    setState(() {
      _futureAulas = _buscarAulas();
    });
  }

  Future<List<Aula>> _buscarAulas() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseDomain}/aula/matriz/${widget.matriz.id}'),
      headers: await ApiClient.getHeaders(),
    );
    if (res.statusCode == 200) {
      final List lista = jsonDecode(utf8.decode(res.bodyBytes));
      return lista.map((j) => Aula.fromJson(j)).toList();
    }
    return [];
  }

  String _formatarData(DateTime data) =>
      '${data.day.toString().padLeft(2, '0')}/'
      '${data.month.toString().padLeft(2, '0')}/'
      '${data.year}';

  @override
  Widget build(BuildContext context) {
    final ativa = widget.matriz.status == 'ATIVA';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.professorColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.matriz.nomeDisciplina),
            Text(
              widget.matriz.nomeTurma,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: Column(
        children: [
          // ── Ações rápidas ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _botaoAcao(
                    'Registrar aula',
                    Icons.add_circle_outline,
                    AppTheme.professorColor,
                    ativa
                        ? () async {
                            final ok = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RegistrarAulaScreen(matriz: widget.matriz),
                              ),
                            );
                            if (ok == true) _carregar();
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _botaoAcao(
                    'Avaliações',
                    Icons.quiz_outlined,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LancarNotasScreen(matriz: widget.matriz),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!ativa)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Matriz encerrada — somente leitura.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // ── Lista de aulas ─────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Aula>>(
              future: _futureAulas,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final aulas = snap.data ?? [];

                if (aulas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 56,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Nenhuma aula registrada ainda.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _carregar(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: aulas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final aula = aulas[i];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: aula.chamadaLancada
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            child: Text(
                              '${aula.numeroAula}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: aula.chamadaLancada
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                          title: Text(
                            aula.conteudo.isNotEmpty
                                ? aula.conteudo
                                : '(sem conteúdo registrado)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            _formatarData(aula.data),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Icon(
                            aula.chamadaLancada
                                ? Icons.check_circle
                                : Icons.warning_amber_rounded,
                            color: aula.chamadaLancada
                                ? Colors.green
                                : Colors.orange,
                            size: 20,
                          ),
                          onTap: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => ChamadaScreen(aula: aula),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoAcao(
    String label,
    IconData icon,
    Color cor,
    VoidCallback? onTap,
  ) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: onTap != null ? cor : Colors.grey,
        side: BorderSide(
          color: onTap != null
              ? cor.withOpacity(0.4)
              : Colors.grey.withOpacity(0.3),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: onTap,
    );
  }
}
