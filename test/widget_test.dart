import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:posemprendeapp/main.dart';
import 'package:posemprendeapp/providers/venta_provider.dart';

void main() {
  testWidgets('Prueba básica de carga de CarniCajaApp', (WidgetTester tester) async {
    // Construye la aplicación envuelta en su proveedor de datos simulado
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => VentaProvider(),
        child: const PosEmprendeApp(),
      ),
    );

    // Verifica que el menú por pestañas de la aplicación se renderice en pantalla
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}