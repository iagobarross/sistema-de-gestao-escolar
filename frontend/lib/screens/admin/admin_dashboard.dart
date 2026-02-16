import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/responsavel/lista_responsavel_screen.dart';
import '../disciplina/lista_disciplina_screen.dart';
import '../escola/lista_escola_screen.dart';
import '../turma/lista_turmas_screen.dart';
import '../aluno/lista_alunos_screen.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';

class AdminDashboard extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
