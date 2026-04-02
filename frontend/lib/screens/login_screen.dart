import 'package:flutter/material.dart';
import 'package:gestao_escolar_app/screens/aluno/aluno_dashboard.dart';
import 'package:gestao_escolar_app/screens/coordenador/coordenador_dashboard.dart';
import 'package:gestao_escolar_app/screens/diretor/diretor_dashboard.dart';
import 'package:gestao_escolar_app/screens/professor/professor_dashboard.dart';
import 'package:gestao_escolar_app/screens/responsavel/responsavel_dashboard.dart';
import 'package:gestao_escolar_app/screens/secretaria/secretaria_dashboard.dart';
import 'package:gestao_escolar_app/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _mostrarSenha = false;
  String? _erro;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    final ok = await _authService.login(
      _emailController.text.trim(),
      _senhaController.text,
    );

    if (!ok) {
      setState(() {
        _isLoading = false;
        _erro = 'E-mail ou senha incorretos.';
      });
      return;
    }

    final role = await _authService.getRole();
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
        setState(() => _erro = 'Perfil de acesso não reconhecido.');
        return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => destino));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SIGA',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Sistema de Gestão Escolar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _senhaController,
                    obscureText: !_mostrarSenha,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _mostrarSenha
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _mostrarSenha = !_mostrarSenha),
                      ),
                    ),
                  ),

                  if (_erro != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _erro!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('ENTRAR'),
                  ),

                  const SizedBox(height: 40),
                  Text(
                    '© 2025 SIGA — Fatec Zona Leste',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
