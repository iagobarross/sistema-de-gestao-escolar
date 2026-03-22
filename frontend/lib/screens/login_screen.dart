import 'package:flutter/material.dart';
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
      _emailController.text,
      _senhaController.text,
    );

    if (success) {
      String? role = await _authService.getRole();
      setState(() => _isLoading = false);

      if (role != null) {
        // Redirecionamento baseado no cargo (Role)
        switch (role) {
          case 'ADMIN':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
            break;
          case 'DIRETOR':
          case 'SECRETARIA':
          case 'COORDENADOR':
            // Aqui você pode criar um DiretorDashboard no futuro.
            // Por enquanto, vamos mandar para o AdminDashboard ou HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()), // Mude para HomeScreen() se preferir
            );
            break;
          case 'PROFESSOR':
          case 'ALUNO':
          case 'RESPONSAVEL':
             // Exemplo de tela genérica para outros usuários
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()), // Substitua pela tela correta deles depois
            );
            break;
          default:
            _mostrarErro('Cargo desconhecido. Contate o suporte.');
            await _authService.logout();
        }
      } else {
        _mostrarErro('Erro ao ler as permissões do usuário.');
        await _authService.logout();
      }
    } else {
      setState(() => _isLoading = false);
      _mostrarErro('E-mail ou senha incorretos!');
    }
  }

  // Função auxiliar para mostrar as mensagens
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
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
