import 'package:posemprendeapp/views/menu_principal.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  // Contenido de las diapositivas de onboarding
  final List<OnboardingItem> _items = const [
    OnboardingItem(
      icono: Icons.point_of_sale_rounded,
      titulo: 'Cobros Rápidos y Eficientes',
      descripcion:
          'Registra ventas al instante desde la terminal POS, gestiona tu carrito y genera recibos en PDF para tus clientes.',
    ),
    OnboardingItem(
      icono: Icons.history_edu_rounded,
      titulo: 'Historial Organizado',
      descripcion:
          'Consulta el detalle de todas tus transacciones, saldos pendientes y filtra por métodos de pago como QR o Efectivo.',
    ),
    OnboardingItem(
      icono: Icons.insights_rounded,
      titulo: 'Métricas de Tu Negocio',
      descripcion:
          'Visualiza el rendimiento de tus ventas diarias y mensuales a través de un dashboard claro y en tiempo real.',
    ),
  ];

  Future<void> _finalizarOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_visto', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MenuPrincipal()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF027F81);
    const mintContainer = Color(0xFFE0F9F5);
    const textDark = Color(0xFF191C1D);
    const textMuted = Color(0xFF6F7979);

    final esUltimaPagina = _paginaActual == _items.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!esUltimaPagina)
            TextButton(
              onPressed: _finalizarOnboarding,
              child: const Text(
                'Omitir',
                style: TextStyle(
                  color: textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Vista deslizable de paginas
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _paginaActual = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: const BoxDecoration(
                            color: mintContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icono,
                            size: 80,
                            color: primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item.titulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.descripcion,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: textMuted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicadores y Botones de control
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Indicadores de pagina (Dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _paginaActual == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _paginaActual == index ? primaryTeal : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Boton Principal de Navegacion
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (esUltimaPagina) {
                          _finalizarOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        esUltimaPagina ? 'COMENZAR' : 'SIGUIENTE',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const OnboardingItem({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });
}