import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/models/notificacao.dart';
import 'package:gestao_escolar_app/services/notificacao_service.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';

class NotificacoesCoordenadorScreen extends StatefulWidget {
  const NotificacoesCoordenadorScreen({super.key});

  @override
  State<NotificacoesCoordenadorScreen> createState() =>
      _NotificacoesCoordenadorScreenState();
}

class _NotificacoesCoordenadorScreenState
    extends State<NotificacoesCoordenadorScreen> {
  final NotificacaoService _service = NotificacaoService();
  late Future<List<Notificacao>> _futureNotificacoes;
  bool _analisando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futureNotificacoes = _service.listar();
    });
  }

  Future<void> _analisar() async {
    setState(() => _analisando = true);
    try {
      final mensagem = await _service.analisar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
      _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _analisando = false);
    }
  }

  Future<void> _encaminhar(Notificacao n) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Encaminhar ao Responsável'),
        content: Text(
          'Deseja enviar esta notificação sobre ${n.nomeAluno} '
          'ao responsável cadastrado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Encaminhar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    try {
      await _service.encaminharAoResponsavel(n.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comunicado enviado ao responsável com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _abrirDetalhes(Notificacao n) async {
    if (n.status == StatusNotificacao.PENDENTE) {
      await _service.marcarLida(n.id);
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetalheNotificacaoSheet(
        notificacao: n,
        onEncaminhar: () {
          Navigator.pop(context);
          _encaminhar(n);
        },
      ),
    );
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.coordenadorColor.withOpacity(0.06),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Análise por IA',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Detecta alunos com baixo desempenho '
                        'ou frequência abaixo de 75%.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.coordenadorColor,
                  ),
                  onPressed: _analisando ? null : _analisar,
                  icon: _analisando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.psychology_outlined, size: 18),
                  label: Text(_analisando ? 'Analisando...' : 'Analisar'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: FutureBuilder<List<Notificacao>>(
              future: _futureNotificacoes,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('${snap.error}'));
                }
                final lista = snap.data ?? [];
                if (lista.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhuma notificação ainda.\n'
                          'Clique em "Analisar" para iniciar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondary),
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
                    itemBuilder: (_, i) => _CartaoNotificacao(
                      notificacao: lista[i],
                      onTap: () => _abrirDetalhes(lista[i]),
                      onEncaminhar: () => _encaminhar(lista[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoNotificacao extends StatelessWidget {
  final Notificacao notificacao;
  final VoidCallback onTap;
  final VoidCallback onEncaminhar;

  const _CartaoNotificacao({
    required this.notificacao,
    required this.onTap,
    required this.onEncaminhar,
  });

  Color get _corTipo {
    return switch (notificacao.tipo) {
      TipoNotificacao.BAIXO_DESEMPENHO => Colors.orange,
      TipoNotificacao.BAIXA_FREQUENCIA => Colors.red,
      TipoNotificacao.DESEMPENHO_E_FREQUENCIA => Colors.deepOrange,
    };
  }

  String get _labelTipo {
    return switch (notificacao.tipo) {
      TipoNotificacao.BAIXO_DESEMPENHO => 'Desempenho',
      TipoNotificacao.BAIXA_FREQUENCIA => 'Frequência',
      TipoNotificacao.DESEMPENHO_E_FREQUENCIA => 'Desempenho e Frequência',
    };
  }

  Color get _corStatus {
    return switch (notificacao.status) {
      StatusNotificacao.PENDENTE => Colors.blue,
      StatusNotificacao.LIDA => Colors.grey,
      StatusNotificacao.ENCAMINHADA => Colors.green,
    };
  }

  String get _labelStatus {
    return switch (notificacao.status) {
      StatusNotificacao.PENDENTE => 'Pendente',
      StatusNotificacao.LIDA => 'Lida',
      StatusNotificacao.ENCAMINHADA => 'Encaminhada',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isPendente = notificacao.status == StatusNotificacao.PENDENTE;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPendente ? _corTipo.withOpacity(0.5) : Colors.grey.shade200,
          width: isPendente ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _corTipo,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _corStatus.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _labelStatus,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _corStatus,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _corTipo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _labelTipo,
                  style: TextStyle(
                    fontSize: 11,
                    color: _corTipo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              Text(
                notificacao.resumo,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    _formatarData(notificacao.criadaEm),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  const Spacer(),
                  if (notificacao.status != StatusNotificacao.ENCAMINHADA)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.coordenadorColor,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onEncaminhar,
                      icon: const Icon(
                        Icons.forward_to_inbox_outlined,
                        size: 16,
                      ),
                      label: const Text(
                        'Encaminhar',
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Encaminhada',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarData(DateTime dt) {
    final agora = DateTime.now();
    final diff = agora.difference(dt).inDays;
    if (diff == 0)
      return 'Hoje, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff == 1) return 'Ontem';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _DetalheNotificacaoSheet extends StatelessWidget {
  final Notificacao notificacao;
  final VoidCallback onEncaminhar;

  const _DetalheNotificacaoSheet({
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
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
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

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                notificacao.conteudoIA,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),

            const SizedBox(height: 24),

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
