import 'package:flutter/material.dart';

class AppTheme {
  // Cores baseadas na logo e turismo
  static const Color azulPrimario = Color(0xFF1976D2);     // Azul oceano/céu
  static const Color azulClaro = Color(0xFF42A5F5);        // Azul claro
  static const Color azulEscuro = Color(0xFF0D47A1);       // Azul escuro
  static const Color laranjaAcento = Color(0xFFFF9800);    // Laranja aventura
  static const Color verdeNatureza = Color(0xFF4CAF50);    // Verde natureza
  static const Color cinzaTexto = Color(0xFF757575);       // Cinza texto
  static const Color branco = Color(0xFFFFFFFF);           // Branco
  static const Color cinzaClaro = Color(0xFFF5F5F5);       // Cinza claro

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: azulPrimario,
        brightness: Brightness.light,
        primary: azulPrimario,
        secondary: laranjaAcento,
        tertiary: verdeNatureza,
        surface: branco,
        background: cinzaClaro,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: azulPrimario,
        foregroundColor: branco,
        iconTheme: IconThemeData(color: branco),
        titleTextStyle: TextStyle(
          color: branco,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: branco,
        shadowColor: azulPrimario.withAlpha(25),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: azulPrimario, width: 2),
        ),
        filled: true,
        fillColor: cinzaClaro,
        prefixIconColor: azulPrimario,
        suffixIconColor: azulPrimario,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: azulPrimario,
          foregroundColor: branco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 3,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: azulPrimario,
          side: const BorderSide(color: azulPrimario),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: azulPrimario,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: laranjaAcento,
        foregroundColor: branco,
        elevation: 6,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: azulClaro.withAlpha(50),
        selectedColor: azulPrimario,
        labelStyle: const TextStyle(color: azulEscuro),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: azulEscuro,
        contentTextStyle: const TextStyle(color: branco),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
