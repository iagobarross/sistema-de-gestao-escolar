import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/responsavel/lista_responsavel_screen.dart';
import 'package:gestao_escolar_app/widgets/main_shell.dart';
import '../disciplina/lista_disciplina_screen.dart';
import '../escola/lista_escola_screen.dart';
import '../turma/lista_turmas_screen.dart';
import '../aluno/lista_alunos_screen.dart';
import '../chat/lista_conversas_screen.dart';

class AdminDashboard extends StatelessWidget {
  //final AuthService _authService = AuthService();

  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MainShell(
      titulo: 'Sistema de Gestão Escolar',
      role: 'ADMIN',
      items: const [
        NavItem(
          label: 'Escolas',
          icon: Icons.school_outlined,
          page: ListaEscolaScreen(),
        ),
        NavItem(
          label: 'Turmas',
          icon: Icons.group_outlined,
          page: ListaTurmaScreen(),
        ),
        NavItem(
          label: 'Alunos',
          icon: Icons.person_outlined,
          page: ListaAlunoScreen(),
        ),
        NavItem(
          label: 'Responsáveis',
          icon: Icons.family_restroom_outlined,
          page: ListaResponsavelScreen(),
        ),
        NavItem(
          label: 'Disciplinas',
          icon: Icons.book_outlined,
          page: ListaDisciplinaScreen(),
        ),
        NavItem(
          label: 'Mensagens',
          icon: Icons.chat_bubble,
          page: ListaConversasScreen(),
        ),
      ],
    );
    /*return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await _authService.logout();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCard(
                  context,
                  'Alunos',
                  Icons.person,
                  Colors.blue,
                  ListaAlunoScreen(),
                ),
                _buildCard(
                  context,
                  'Escolas',
                  Icons.business,
                  Colors.green,
                  ListaEscolaScreen(),
                ),
//
                _buildCard(
                  context,
                  'Mensagens',
                  Icons.chat_bubble,
                  Colors.teal,
                  const ListaConversasScreen(),
                ),
                
                //_buildCard(
                //  context,
                //  'Mural Público',
                //  Icons.forum, // Mudei o ícone para fazer mais sentido
                //  Colors.teal,
                //  const ConversaScreen(
                //    conversaId: 1, // ID fictício para o teste
                //    titulo: 'Mural da Escola',
                //    subtitulo: 'Canal Público',
                //    meuId: 0,
                //  ),
                //),

                _buildCard(
                  context,
                  'Disciplinas',
                  Icons.book,
                  Colors.orange,
                  ListaDisciplinaScreen(),
                ),

                _buildCard(
                  context,
                  'Turmas',
                  Icons.groups,
                  Colors.purple,
                  ListaTurmaScreen(),
                ),

                _buildCard(
                  context,
                  'Responsáveis',
                  Icons.family_restroom,
                  Colors.yellow,
                  ListaResponsavelScreen(),
                ),

                _buildCard(
                  context,
                  'Configurações',
                  Icons.settings,
                  Colors.grey,
                  Container(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );*/
  }
}
