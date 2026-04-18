import 'package:flutter/material.dart';

class AppTheme {
  static const Color primario = Color.fromARGB(255, 11, 7, 89);
  static const Color secundario = Color.fromARGB(255, 113, 177, 246);
  static const Color erro = Color(0xFFEF4444);
  static const Color sucesso = Color.fromARGB(255, 15, 152, 45);
  static const Color aviso = Color(0xFFF59E0B);
  static const Color superficieClara = Color(0xFFF8FAFC);
  static const Color textoSecundario = Color.fromARGB(255, 60, 73, 91);

  static ThemeData get tema => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primario),
    appBarTheme: const AppBarTheme(
      backgroundColor: primario,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primario,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primario, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
  );
}

const List<String> categorias = [
  'Streaming', 'Música', 'Jogos', 'Produtividade',
  'Educação', 'Saúde', 'Armazenamento', 'Outros',
];
