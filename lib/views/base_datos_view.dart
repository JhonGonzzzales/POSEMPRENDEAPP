import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/venta_provider.dart';
import '../models/venta_model.dart';

class BaseDatosView extends StatelessWidget {
  const BaseDatosView({super.key});

  // Paleta de colores oficial de Material Design 3
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
          'Historial de Ventas',
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

          if (provider.ventas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: mintContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 48,
                      color: primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin ventas registradas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Usa la pestaña POS Terminal para realizar cobros.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: provider.ventas.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final venta = provider.ventas[index];
              final resumenProductos = _generarResumenProductos(venta);

              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  onTap: () => _mostrarDetalleVenta(context, venta),
                  leading: CircleAvatar(
                    backgroundColor: _obtenerColorMetodo(venta.metodoPago).withValues(alpha: 0.15),
                    child: Icon(
                      _obtenerIconoMetodo(venta.metodoPago),
                      color: _obtenerColorMetodo(venta.metodoPago),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    resumenProductos,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Cliente: ${venta.cliente}\nFecha: ${venta.fechaHora}',
                      style: const TextStyle(fontSize: 12, color: textMuted, height: 1.3),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${venta.totalVenta.toStringAsFixed(2)} Bs',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: primaryTeal,
                            ),
                          ),
                          if (venta.saldo > 0)
                            Text(
                              'Saldo: ${venta.saldo.toStringAsFixed(2)} Bs',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                        onPressed: () {
                          _confirmarEliminacion(
                            context,
                            provider,
                            venta.id!,
                            resumenProductos,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _generarResumenProductos(VentaModel venta) {
    if (venta.detalles.isEmpty) {
      return 'Venta sin detalle de ítems';
    }
    if (venta.detalles.length == 1) {
      final item = venta.detalles.first;
      return '${item.nombreProducto} x${item.cantidad}';
    }
    final totalItems = venta.detalles.fold<double>(0, (sum, d) => sum + d.cantidad);
    return '${venta.detalles.length} productos (${totalItems.toStringAsFixed(0)} ítems)';
  }

  void _mostrarDetalleVenta(BuildContext context, VentaModel venta) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.receipt_outlined, color: primaryTeal),
            const SizedBox(width: 8),
            Text(
              'Venta #${venta.id ?? '-'}',
              style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoRow('Cliente:', venta.cliente),
                _infoRow('Fecha:', venta.fechaHora),
                _infoRow('Método:', venta.metodoPago),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                const SizedBox(height: 8),
                ...venta.detalles.map((detalle) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${detalle.cantidad}x ${detalle.nombreProducto}',
                              style: const TextStyle(color: textDark, fontSize: 13),
                            ),
                          ),
                          Text(
                            '${detalle.subtotal.toStringAsFixed(2)} Bs',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                    Text(
                      '${venta.totalVenta.toStringAsFixed(2)} Bs',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pagado:', style: TextStyle(color: textMuted, fontSize: 13)),
                    Text('${venta.montoPagado.toStringAsFixed(2)} Bs', style: const TextStyle(color: textMuted, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CERRAR', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text('$label ', style: const TextStyle(color: textMuted, fontSize: 13)),
          Text(value, style: const TextStyle(color: textDark, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Color _obtenerColorMetodo(String metodo) {
    switch (metodo) {
      case 'QR':
        return Colors.purple;
      case 'Tarjeta':
        return Colors.blue;
      default:
        return primaryTeal;
    }
  }

  IconData _obtenerIconoMetodo(String metodo) {
    switch (metodo) {
      case 'QR':
        return Icons.qr_code_rounded;
      case 'Tarjeta':
        return Icons.credit_card_rounded;
      default:
        return Icons.payments_outlined;
    }
  }

  void _confirmarEliminacion(
    BuildContext context,
    VentaProvider provider,
    int id,
    String resumen,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '¿Eliminar registro?',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          '¿Estás seguro de que deseas borrar el registro de "$resumen"?',
          style: const TextStyle(color: textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR', style: TextStyle(color: textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              provider.borrarVenta(id);
              Navigator.pop(dialogContext);

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: textDark,
                  content: const Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Registro eliminado correctamente'),
                    ],
                  ),
                ),
              );
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}