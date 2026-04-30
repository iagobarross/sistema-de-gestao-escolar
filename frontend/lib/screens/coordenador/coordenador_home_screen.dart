import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/notificacao.dart';
import 'package:gestao_escolar_app/services/api_client.dart';
import 'package:gestao_escolar_app/services/notificacao_service.dart';
import 'package:gestao_escolar_app/services/profile_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import 'package:gestao_escolar_app/widgets/charts.dart';
import 'package:http/http.dart' as http;

/// Dashboard inicial do Coordenador.
///
/// Exibe KPIs da escola (alunos, turmas, alertas pendentes),
/// a lista de turmas e os alertas mais recentes gerados pela IA.
/// Ao tocar em um alerta, abre o detalhe diretamente daqui.
class CoordenadorHomeScreen extends StatefulWidget {
  const CoordenadorHomeScreen({super.key});

  @override
  State<CoordenadorHomeScreen> createState() => _CoordenadorHomeScreenState();
}

class _CoordenadorHomeScreenState extends State<CoordenadorHomeScreen> {
  bool _carregando = true;
  int _totalAlunos = 0;
  int _totalTurmas = 0;
  int _notifPendentes = 0;
  List<Map<String, dynamic>> _turmas = [];
  List<Notificacao> _notificacoesRecentes = [];

  final NotificacaoService _notifService = NotificacaoService();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final escolaId = await ProfileService.instance.getEscolaId();

      // Dispara todas as chamadas em paralelo para economizar tempo
      final futures = await Future.wait([
        http.get(
          Uri.parse(
            '${ApiClient.baseDomain}/aluno?size=1'
            '${escolaId != null ? '&escolaId=$escolaId' : ''}',
          ),
          headers: await ApiClient.getHeaders(),
        ),
        http.get(
          Uri.parse('${ApiClient.baseDomain}/turma'),
          headers: await ApiClient.getHeaders(),
        ),
        http.get(
          Uri.parse('${ApiClient.baseDomain}/notificacao/pendentes/count'),
          headers: await ApiClient.getHeaders(),
        ),
      ]);

      // Total de alunos vem no campo totalElements da paginação
      final totalAlunos = futures[0].statusCode == 200
          ? (jsonDecode(futures[0].body)['totalElements'] as int? ?? 0)
          : 0;

      // Lista de turmas — o backend já filtra pela escola do coordenador
      final turmas = futures[1].statusCode == 200
          ? List<Map<String, dynamic>>.from(
              jsonDecode(utf8.decode(futures[1].bodyBytes)),
            )
          : <Map<String, dynamic>>[];

      // Quantidade de alertas pendentes para o badge
      final notifPendentes = futures[2].statusCode == 200
          ? (jsonDecode(futures[2].body)['total'] as int? ?? 0)
          : 0;

      // Carrega as 4 notificações mais recentes para o resumo
      final todasNotifs = await _notifService.listar();
      final recentes = todasNotifs.take(4).toList();

      if (!mounted) return;
      setState(() {
        _totalAlunos = totalAlunos;
        _totalTurmas = turmas.length;
        _notifPendentes = notifPendentes;
        _turmas = turmas;
        _notificacoesRecentes = recentes;
        _carregando = false;
      });
    } catch (e) {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirDetalheNotif(Notificacao n) async {
    // Marca como lida antes de abrir — ignora erros silenciosamente
    if (n.status == StatusNotificacao.PENDENTE) {
      try {
        await _notifService.marcarLida(n.id);
      } catch (_) {}
    }

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetalheNotifSheet(
        notificacao: n,
        onEncaminhar: () async {
          Navigator.pop(context);
          try {
            await _notifService.encaminharAoResponsavel(n.id);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Comunicado enviado ao responsável!'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$e'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );

    // Atualiza a lista após fechar o sheet para refletir a mudança de status
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── KPIs ────────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: KpiCard(
                  valor: '$_totalAlunos',
                  label: 'Alunos',
                  icon: Icons.person_outlined,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KpiCard(
                  valor: '$_totalTurmas',
                  label: 'Turmas',
                  icon: Icons.groups_outlined,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: KpiCard(
                  valor: '$_notifPendentes',
                  label: 'Alertas',
                  icon: Icons.psychology_outlined,
                  // Destaca em laranja quando há alertas pendentes
                  color: _notifPendentes > 0 ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Turmas ──────────────────────────────────────────────────────
          if (_turmas.isNotEmpty) ...[
            const Text(
              'Turmas sob sua coordenação',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            // Grid 2 colunas para as turmas
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _turmas.length > 8 ? 8 : _turmas.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemBuilder: (_, i) => _TurmaChip(turma: _turmas[i]),
            ),
            if (_turmas.length > 8)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'e mais ${_turmas.length - 8} turmas…',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],

          // ── Alertas recentes da IA ───────────────────────────────────────
          Row(
            children: [
              const Text(
                'Alertas recentes da IA',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              if (_notifPendentes > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_notifPendentes pendente${_notifPendentes > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          if (_notificacoesRecentes.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 44,
                      color: Colors.green.shade400,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nenhum alerta pendente.\n'
                      'Todos os alunos estão dentro dos parâmetros esperados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(_notificacoesRecentes.map(
              (n) => _NotifRecenteCard(
                notificacao: n,
                onTap: () => _abrirDetalheNotif(n),
                onEncaminhar: () => _abrirDetalheNotif(n),
              ),
            )),
        ],
      ),
    );
  }
}

// ─── Widget: chip de turma ─────────────────────────────────────────────────

class _TurmaChip extends StatelessWidget {
  final Map<String, dynamic> turma;
  const _TurmaChip({required this.turma});

  Color _corTurno(String t) {
    if (t.toLowerCase().contains('manhã') || t.toLowerCase().contains('manha'))
      return Colors.orange;
    if (t.toLowerCase().contains('tarde')) return Colors.blue;
    return Colors.indigo;
  }

  @override
  Widget build(BuildContext context) {
    final turno = turma['turno'] as String? ?? '';
    final cor = _corTurno(turno);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                turno.isNotEmpty ? turno[0] : '?',
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  turma['serie'] as String? ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  turno,
                  style: TextStyle(fontSize: 10, color: cor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget: card de notificação recente ──────────────────────────────────

class _NotifRecenteCard extends StatelessWidget {
  final Notificacao notificacao;
  final VoidCallback onTap;
  final VoidCallback onEncaminhar;

  const _NotifRecenteCard({
    required this.notificacao,
    required this.onTap,
    required this.onEncaminhar,
  });

  Color get _corTipo => switch (notificacao.tipo) {
    TipoNotificacao.BAIXO_DESEMPENHO => Colors.orange,
    TipoNotificacao.BAIXA_FREQUENCIA => Colors.red,
    TipoNotificacao.DESEMPENHO_E_FREQUENCIA => Colors.deepOrange,
  };

  @override
  Widget build(BuildContext context) {
    final isPendente = notificacao.status == StatusNotificacao.PENDENTE;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPendente ? _corTipo.withOpacity(0.4) : AppTheme.divider,
          width: isPendente ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, // abre o detalhe completo com o texto da IA
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: _corTipo,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificacao.nomeAluno,
                      style: TextStyle(
                        fontWeight: isPendente
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      notificacao.nomeTurma,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notificacao.resumo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Mostra "NOVO" se pendente, ou ícone de encaminhar se lida
              if (isPendente)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NOVO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                )
              else if (notificacao.status != StatusNotificacao.ENCAMINHADA)
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18)
              else
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade500,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom sheet de detalhe ─────────────────────────────────────────────────

class _DetalheNotifSheet extends StatelessWidget {
  final Notificacao notificacao;
  final VoidCallback onEncaminhar;

  const _DetalheNotifSheet({
    required this.notificacao,
    required this.onEncaminhar,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
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
            // Handle visual
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

            // Cabeçalho do aluno
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.coordenadorColor.withOpacity(0.1),
                  child: Text(
                    notificacao.nomeAluno[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.coordenadorColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificacao.nomeAluno,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${notificacao.nomeTurma} · RA: ${notificacao.matriculaAluno}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Badge "Análise por IA"
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Colors.purple,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Análise gerada por Inteligência Artificial',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Conteúdo gerado pela IA — o texto completo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                notificacao.conteudoIA,
                style: const TextStyle(fontSize: 14, height: 1.65),
              ),
            ),

            const SizedBox(height: 24),

            // Botão de encaminhar (ou mensagem de já encaminhada)
            if (notificacao.status != StatusNotificacao.ENCAMINHADA)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.coordenadorColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: onEncaminhar,
                  icon: const Icon(Icons.forward_to_inbox_outlined),
                  label: const Text(
                    'Encaminhar ao Responsável',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Comunicado já enviado ao responsável.',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
