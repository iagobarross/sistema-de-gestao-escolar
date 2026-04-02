import 'package:flutter/material.dart';
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
          label: 'Disciplinas',
          icon: Icons.book_outlined,
          page: const ListaDisciplinaScreen(podeCadastrar: false),
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
