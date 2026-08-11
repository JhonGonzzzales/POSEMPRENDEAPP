import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/venta_provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  // Paleta Material Design 3
  static const Color primaryTeal = Color(0xFF027F81);
  static const Color mintContainer = Color(0xFFE0F9F5);
  static const Color surfaceBackground = Color(0xFFF8FAF9);
  static const Color textDark = Color(0xFF191C1D);
  static const Color textMuted = Color(0xFF6F7979);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBackground,
      appBar: AppBar(
        title: const Text(
          'Resumen de Caja',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: surfaceBackground,
        elevation: 0,
        centerTitle: false,
      ),
      body: Consumer<VentaProvider>(
        builder: (context, provider, child) {
          if (provider.cargando) {
            return const Center(
              child: CircularProgressIndicator(color: primaryTeal),
            );
          }

          // Métodos de pago
          double efectivoTotal = 0;
          double qrTotal = 0;
          double tarjetaTotal = 0;

          for (var venta in provider.ventas) {
            if (venta.metodoPago == 'Efectivo') efectivoTotal += venta.totalVenta;
            if (venta.metodoPago == 'QR') qrTotal += venta.totalVenta;
            if (venta.metodoPago == 'Tarjeta') tarjetaTotal += venta.totalVenta;
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tarjeta Principal (Ventas de Hoy - Hero)
                Card(
                  elevation: 0,
                  color: mintContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryTeal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.today_rounded, color: primaryTeal, size: 24),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${provider.ventas.where((v) => v.fechaHora.startsWith(DateTime.now().toString().split(' ')[0])).length} transacciones',
                                style: const TextStyle(
                                  color: primaryTeal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ventas de Hoy',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.totalHoy.toStringAsFixed(2)} Bs.',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Fila de Métricas Secundarias (Semana y Mes)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Esta Semana',
                        amount: provider.totalSemana,
                        icon: Icons.calendar_view_week_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Este Mes',
                        amount: provider.totalMes,
                        icon: Icons.calendar_month_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Distribución de Ingresos
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Distribución por Pago',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildPaymentMethodTile('Efectivo', efectivoTotal, Icons.payments_outlined),
                            _buildPaymentMethodTile('QR', qrTotal, Icons.qr_code_scanner_rounded),
                            _buildPaymentMethodTile('Tarjeta', tarjetaTotal, Icons.credit_card_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Lista de Últimas Transacciones
                if (provider.ventas.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transacciones Recientes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todas', style: TextStyle(color: primaryTeal)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.ventas.take(3).length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (context, index) {
                        final v = provider.ventas[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: const CircleAvatar(
                            backgroundColor: mintContainer,
                            child: Icon(Icons.receipt_long_rounded, color: primaryTeal, size: 20),
                          ),
                          title: Text(
                            v.cliente,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 14),
                          ),
                          subtitle: Text(
                            '${v.fechaHora} • ${v.metodoPago}',
                            style: const TextStyle(fontSize: 12, color: textMuted),
                          ),
                          trailing: Text(
                            '+${v.totalVenta.toStringAsFixed(2)} Bs.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryTeal,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Botón de Acción Principal Material 3
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await provider.cargarDatos();
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: textDark,
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: mintContainer),
                            SizedBox(width: 12),
                            Text('Métricas actualizadas'),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.sync_rounded, size: 22),
                  label: const Text(
                    'ACTUALIZAR DATOS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  // Sub-tarjeta para métricas de semana/mes
  Widget _buildMetricCard({
    required String title,
    required double amount,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryTeal, size: 22),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: textMuted, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              '${amount.toStringAsFixed(2)} Bs.',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ítem de método de pago ordenado
  Widget _buildPaymentMethodTile(String title, double amount, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: surfaceBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryTeal, size: 22),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: textMuted)),
          const SizedBox(height: 2),
          Text(
            '${amount.toStringAsFixed(1)} Bs.',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
          ),
        ],
      ),
    );
  }
}