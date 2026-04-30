// frontend/lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Paleta base (azul) ────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1565C0); // azul principal
  static const Color primaryDark = Color(0xFF0D47A1); // azul escuro
  static const Color primaryLight = Color(0xFF1E88E5); // azul médio
  static const Color accent = Color(0xFF42A5F5); // azul claro
  static const Color surface = Color(0xFFF8F9FA);
  static const Color cardBg = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // ── Cores por papel — todas em tons de azul ───────────────────────────────
  static const Color adminColor = Color(0xFF0D47A1); // azul muito escuro
  static const Color diretorColor = Color(0xFF1565C0); // primary
  static const Color coordenadorColor = Color(0xFF1976D2); // azul
  static const Color secretariaColor = Color(0xFF1E88E5); // azul médio
  static const Color professorColor = Color(0xFF2196F3); // azul vivo
  static const Color responsavelColor = Color(0xFF1565C0); // primary
  static const Color alunoColor = Color(0xFF0D47A1); // azul escuro

  static Color roleColor(String? role) => switch (role) {
    'ADMIN' => adminColor,
    'DIRETOR' => diretorColor,
    'COORDENADOR' => coordenadorColor,
    'SECRETARIA' => secretariaColor,
    'PROFESSOR' => professorColor,
    'RESPONSAVEL' => responsavelColor,
    'ALUNO' => alunoColor,
    _ => primary,
  };

  static String roleLabel(String? role) => switch (role) {
    'ADMIN' => 'Administrador',
    'DIRETOR' => 'Diretor',
    'COORDENADOR' => 'Coordenador',
    'SECRETARIA' => 'Secretaria',
    'PROFESSOR' => 'Professor',
    'RESPONSAVEL' => 'Responsável',
    'ALUNO' => 'Aluno',
    _ => 'Usuário',
  };

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.15,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: divider),
      ),
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      selectedColor: primary,
      checkmarkColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 12),
      side: const BorderSide(color: divider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      labelStyle: TextStyle(color: textSecondary),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: textSecondary,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(color: divider, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
  );
}
