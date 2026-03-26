import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/aula.dart';
import 'package:gestao_escolar_app/models/matriz_curricular.dart';
import 'package:gestao_escolar_app/screens/chamada/chamada_screen.dart';
import 'package:gestao_escolar_app/screens/professor/registrar_aula_screen.dart';
import 'package:gestao_escolar_app/screens/professor/lancar_notas_screen.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
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
    setState(() => _futureAulas = _buscarAulas());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: Column(
        children: [
          // Ações rápidas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _botaoAcao(
                    context,
                    'Registrar aula',
                    Icons.add_circle_outline,
                    Colors.teal,
                    () async {
                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegistrarAulaScreen(matriz: widget.matriz),
                        ),
                      );
                      if (ok == true) _carregar();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _botaoAcao(
                    context,
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

          const Divider(height: 1),

          // Lista de aulas registradas
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
                        Text(
                          'Nenhuma aula registrada ainda.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: aulas.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final aula = aulas[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: aula.chamadaLancada
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        child: Text(
                          '${aula.numeroAula}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
                      trailing: aula.chamadaLancada
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            )
                          : const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 18,
                            ),
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => ChamadaScreen(aula: aula),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoAcao(
    BuildContext ctx,
    String label,
    IconData icon,
    Color cor,
    VoidCallback onTap,
  ) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: cor,
        side: BorderSide(color: cor.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: onTap,
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }
}
