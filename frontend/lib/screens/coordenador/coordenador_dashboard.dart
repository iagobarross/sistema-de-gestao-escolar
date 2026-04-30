import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/coordenador/coordenador_home_screen.dart';
import 'package:gestao_escolar_app/screens/coordenador/notificacoes_coordenador_screen.dart';
import 'package:gestao_escolar_app/screens/funcionario/lista_funcionarios_screen.dart';
import 'package:gestao_escolar_app/widgets/scoped_shell.dart';
import 'package:gestao_escolar_app/widgets/main_shell.dart';
import 'package:gestao_escolar_app/screens/aluno/lista_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/turma/lista_turmas_screen.dart';
import 'package:gestao_escolar_app/screens/disciplina/lista_disciplina_screen.dart';
import 'package:gestao_escolar_app/screens/chat/lista_conversas_screen.dart';

class CoordenadorDashboard extends StatelessWidget {
  const CoordenadorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedShell(
      titulo: 'Coordenação Pedagógica',
      role: 'COORDENADOR',
      itemsBuilder: (escolaId) => [
        NavItem(
          label: 'Início',
          icon: Icons.person_outlined,
          page: const CoordenadorHomeScreen(),
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
          label: 'Funcionários',
          icon: Icons.badge_outlined,
          page: ListaFuncionariosScreen(escolaIdFiltro: escolaId),
        ),
        NavItem(
          label: 'Turmas',
          icon: Icons.groups_outlined,
          page: const ListaTurmaScreen(podeCadastrar: false),
        ),
        NavItem(
          label: 'Disciplinas',
          icon: Icons.book_outlined,
          page: const ListaDisciplinaScreen(podeCadastrar: false),
        ),
        NavItem(
          label: 'Notificações IA',
          icon: Icons.psychology_outlined,
          page: const NotificacoesCoordenadorScreen(),
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
