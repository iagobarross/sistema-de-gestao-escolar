import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/escola/resumo_escola_screen.dart';
import 'package:gestao_escolar_app/screens/funcionario/lista_funcionarios_screen.dart';
import 'package:gestao_escolar_app/widgets/scoped_shell.dart';
import 'package:gestao_escolar_app/widgets/main_shell.dart';
import 'package:gestao_escolar_app/screens/aluno/lista_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/escola/lista_escola_screen.dart';
import 'package:gestao_escolar_app/screens/turma/lista_turmas_screen.dart';
import 'package:gestao_escolar_app/screens/chat/lista_conversas_screen.dart';

class DiretorDashboard extends StatelessWidget {
  const DiretorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedShell(
      titulo: 'Painel da Direção',
      role: 'DIRETOR',
      itemsBuilder: (escolaId) => [
        NavItem(
          label: 'Início',
          icon: Icons.home_outlined,
          page: const ResumoEscolaScreen(),
        ),
        NavItem(
          label: 'Funcionários',
          icon: Icons.badge_outlined,
          page: ListaFuncionariosScreen(escolaIdFiltro: escolaId),
        ),
        NavItem(
          label: 'Alunos',
          icon: Icons.person_outlined,
          page: ListaAlunoScreen(
            escolaIdFiltro: escolaId,
            podeCadastrar: false,
          ),
        ),
        NavItem(
          label: 'Turmas',
          icon: Icons.groups_outlined,
          page: const ListaTurmaScreen(podeCadastrar: false),
        ),
        NavItem(
          label: 'Minha Escola',
          icon: Icons.school_outlined,
          page: ListaEscolaScreen(
            escolaIdFiltro: escolaId,
            podeCadastrar: false,
          ),
        ),
        NavItem(
          label: 'Mensagens',
          icon: Icons.chat_bubble_outline,
          page: const ListaConversasScreen(),
        ),
      ],
    );
  }
}
