import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/widgets/scoped_shell.dart';
import 'package:gestao_escolar_app/widgets/main_shell.dart';
import 'package:gestao_escolar_app/screens/aluno/lista_alunos_screen.dart';
import 'package:gestao_escolar_app/screens/responsavel/lista_responsavel_screen.dart';
import 'package:gestao_escolar_app/screens/turma/lista_turmas_screen.dart';
import 'package:gestao_escolar_app/screens/chat/lista_conversas_screen.dart';

class SecretariaDashboard extends StatelessWidget {
  const SecretariaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedShell(
      titulo: 'Secretaria Escolar',
      role: 'SECRETARIA',
      itemsBuilder: (escolaId) => [
        // Secretaria PODE cadastrar alunos (backend: hasAnyRole ADMIN, SECRETARIA)
        NavItem(
          label: 'Alunos',
          icon: Icons.person_outlined,
          page: ListaAlunoScreen(escolaIdFiltro: escolaId, podeCadastrar: true),
        ),
        NavItem(
          label: 'Responsáveis',
          icon: Icons.family_restroom_outlined,
          page: const ListaResponsavelScreen(),
        ),
        NavItem(
          label: 'Turmas',
          icon: Icons.groups_outlined,
          // Secretaria pode criar turmas (backend: hasAnyRole ADMIN, DIRETOR, SECRETARIA)
          page: const ListaTurmaScreen(podeCadastrar: true),
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
