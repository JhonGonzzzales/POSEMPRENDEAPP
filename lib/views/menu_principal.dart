import 'package:flutter/material.dart';
import '../main.dart';
import 'caja_view.dart';
import 'base_datos_view.dart';
import 'dashboard_view.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int _indexActual = 0;

  final List<Widget> _pantallas = const [
    CajaView(),
    BaseDatosView(),
    DashboardView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indexActual,
        children: _pantallas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexActual,
        onDestinationSelected: (int index) {
          setState(() {
            _indexActual = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: PosEmprendeApp.mintContainer,
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale_rounded, color: PosEmprendeApp.primaryTeal),
            label: 'POS Terminal',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: PosEmprendeApp.primaryTeal),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded, color: PosEmprendeApp.primaryTeal),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}