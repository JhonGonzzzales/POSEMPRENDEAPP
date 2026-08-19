import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:posemprendeapp/views/menu_principal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'providers/venta_provider.dart';
import 'views/onboarding_view.dart';

void main() async {
  // Asegura la inicialización de los bindings de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el driver de SQLite si la app corre en un navegador Web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  bool mostrarOnboarding = true;
  try {
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingVisto = prefs.getBool('onboarding_visto') ?? false;
    mostrarOnboarding = !onboardingVisto;
  } catch (e) {
    // Si falla SharedPreferences, no rompe la app
    mostrarOnboarding = false;
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final provider = VentaProvider();
        provider.cargarDatos();
        return provider;
      },
      child: PosEmprendeApp(mostrarOnboarding: mostrarOnboarding),
    ),
  );
}

class PosEmprendeApp extends StatelessWidget {
  final bool mostrarOnboarding;

  const PosEmprendeApp({
    super.key,
    this.mostrarOnboarding = false,
  });

  static const Color primaryTeal = Color(0xFF027F81);
  static const Color mintContainer = Color(0xFFE0F9F5);
  static const Color surfaceBackground = Color(0xFFF8FAF9);
  static const Color textDark = Color(0xFF191C1D);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS EMPRENDE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: surfaceBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          primary: primaryTeal,
          surface: surfaceBackground,
          surfaceContainerLowest: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceBackground,
          scrolledUnderElevation: 0,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
      home: mostrarOnboarding ? const OnboardingView() : const MenuPrincipal(),
    );
  }
}