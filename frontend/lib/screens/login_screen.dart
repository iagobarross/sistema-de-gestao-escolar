import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/aluno/aluno_dashboard.dart';
import 'package:gestao_escolar_app/screens/coordenador/coordenador_dashboard.dart';
import 'package:gestao_escolar_app/screens/diretor/diretor_dashboard.dart';
import 'package:gestao_escolar_app/screens/professor/professor_dashboard.dart';
import 'package:gestao_escolar_app/screens/responsavel/responsavel_dashboard.dart';
import 'package:gestao_escolar_app/screens/secretaria/secretaria_dashboard.dart';
import '../services/auth_service.dart';
import 'admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    bool success = await _authService.login(
      _emailController.text.trim(),
      _senhaController.text,
    );

    if (!success) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail ou senha incorretos!')),
        );
      }
      return;
    }

    final String? role = await _authService.getRole();
    setState(() => _isLoading = false);

    if (!mounted) return;

    Widget destino;
    switch (role) {
      case 'ADMIN':
        destino = AdminDashboard();
        break;
      case 'DIRETOR':
        destino = const DiretorDashboard();
        break;
      case 'COORDENADOR':
        destino = const CoordenadorDashboard();
        break;
      case 'SECRETARIA':
        destino = const SecretariaDashboard();
        break;
      case 'PROFESSOR':
        destino = const ProfessorDashboard();
        break;
      case 'RESPONSAVEL':
        destino = const ResponsavelDashboard();
        break;
      case 'ALUNO':
        destino = const AlunoDashboard();
        break;
      default:
        await _authService.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role não reconhecida — acesso negado.'),
          ),
        );
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destino),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 80, color: Colors.red.shade900),
                const SizedBox(height: 20),
                Text(
                  'Gestão Escolar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _senhaController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          child: const Text('ENTRAR'),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
