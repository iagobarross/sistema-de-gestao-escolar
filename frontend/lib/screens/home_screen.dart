import 'package:flutter/material.dart';
import 'escola/lista_escola_screen.dart';
import 'disciplina/lista_disciplina_screen.dart';
import 'aluno/lista_alunos_screen.dart';
import 'turma/lista_turmas_screen.dart';
import 'responsavel/lista_responsavel_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _telas = <Widget>[
    ListaEscolaScreen(),
    ListaDisciplinaScreen(),
    ListaResponsavelScreen(),
    ListaAlunoScreen(),
    ListaTurmaScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              tooltip: 'Menu',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('Gestão Escolar', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
      drawer: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            child: Text(
              'Menu Principal',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(child: _telas.elementAt(_selectedIndex)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.school), label: 'Escolas'),
          NavigationDestination(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Disciplinas',
          ),
          NavigationDestination(
            icon: Icon(Icons.supervisor_account),
            label: 'Responsáveis',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Alunos'),
          NavigationDestination(icon: Icon(Icons.groups), label: 'Turmas'),
        ],
      ),
    );
  }
}

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu,
              color: Colors.white),
              tooltip: 'Menu',
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }
        ),
        title: Text('Gestão Escolar', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        
      ),
      drawer: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text(
                'Menu Principal',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaEscolaScreen()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Gerenciar Escolas'),
                  SizedBox(height: 5),
                  Icon(Icons.school),
                ],
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListaDisciplinaScreen(),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Gerenciar Disciplinas'),
                  SizedBox(height: 5),
                  Icon(Icons.menu_book_rounded),
                ],
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              child: Text('Gerenciar Responsáveis'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaResponsavelScreen()),
                );
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
              child: Text('Gerenciar Alunos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaAlunoScreen()),
                );
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
              child: Text('Gerenciar Turmas'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaTurmaScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }*/

