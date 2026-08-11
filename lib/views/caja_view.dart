import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/pdf_generator.dart';
import '../providers/venta_provider.dart';
import '../models/venta_model.dart';
import '../models/producto_model.dart';

class CajaView extends StatefulWidget {
  const CajaView({super.key});

  @override
  State<CajaView> createState() => _CajaViewState();
}

class _CajaViewState extends State<CajaView> {
  final _clienteController = TextEditingController(text: 'Mostrador');
  final _nombreProductoController = TextEditingController();
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController(text: '1');
  final _montoPagadoController = TextEditingController();

  // Carrito de compras actual
  final List<DetalleVentaModel> _carrito = [];
  ProductoModel? _productoSeleccionado;

  String _metodoPago = 'Efectivo';

  // Paleta Material Design 3
  static const Color primaryTeal = Color(0xFF027F81);
  static const Color mintContainer = Color(0xFFE0F9F5);
  static const Color surfaceBackground = Color(0xFFF8FAF9);
  static const Color textDark = Color(0xFF191C1D);
  static const Color textMuted = Color(0xFF6F7979);

  @override
  void dispose() {
    _clienteController.dispose();
    _nombreProductoController.dispose();
    _precioController.dispose();
    _cantidadController.dispose();
    _montoPagadoController.dispose();
    super.dispose();
  }

  // Cálculos dinámicos del carrito
  double get _totalVenta => _carrito.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _montoPagado => double.tryParse(_montoPagadoController.text) ?? 0.0;
  double get _saldo => _totalVenta - _montoPagado;

  void _agregarAlCarrito() {
    final nombre = _nombreProductoController.text.trim();
    final precio = double.tryParse(_precioController.text) ?? 0.0;
    final cantidad = double.tryParse(_cantidadController.text) ?? 0.0;

    if (nombre.isEmpty || precio <= 0 || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.amber.shade900,
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Ingresa producto, precio y cantidad válidos')),
            ],
          ),
        ),
      );
      return;
    }

    setState(() {
      _carrito.add(
        DetalleVentaModel(
          productoId: _productoSeleccionado?.id,
          nombreProducto: nombre,
          precioUnitario: precio,
          cantidad: cantidad,
          subtotal: precio * cantidad,
        ),
      );

      // Limpiar campos de ítem rápido
      _nombreProductoController.clear();
      _precioController.clear();
      _cantidadController.text = '1';
      _productoSeleccionado = null;
    });
  }

  void _eliminarDelCarrito(int index) {
    setState(() {
      _carrito.removeAt(index);
    });
  }

  void _limpiarFormulario() {
    _clienteController.text = 'Mostrador';
    _nombreProductoController.clear();
    _precioController.clear();
    _cantidadController.text = '1';
    _montoPagadoController.clear();
    setState(() {
      _carrito.clear();
      _productoSeleccionado = null;
      _metodoPago = 'Efectivo';
    });
  }

  void _guardarTransaccion() {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.amber.shade900,
          content: const Row(
            children: [
              Icon(Icons.shopping_cart_outlined, color: Colors.white),
              SizedBox(width: 12),
              Text('Agrega al menos un producto al carrito'),
            ],
          ),
        ),
      );
      return;
    }

    final nuevaVenta = VentaModel(
      fechaHora: DateTime.now().toString().split('.')[0],
      cliente: _clienteController.text.isEmpty ? 'Mostrador' : _clienteController.text,
      totalVenta: _totalVenta,
      montoPagado: _montoPagado > 0 ? _montoPagado : _totalVenta,
      saldo: _saldo > 0 ? _saldo : 0.0,
      metodoPago: _metodoPago,
      detalles: List.from(_carrito),
    );

    Provider.of<VentaProvider>(context, listen: false).agregarVenta(nuevaVenta);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: textDark,
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: mintContainer),
            SizedBox(width: 12),
            Text('Venta registrada correctamente'),
          ],
        ),
      ),
    );

    _limpiarFormulario();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: primaryTeal, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VentaProvider>(context);

    return Scaffold(
      backgroundColor: surfaceBackground,
      appBar: AppBar(
        title: const Text(
          'POS Terminal',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Superior Estilo Material 3
            Card(
              elevation: 0,
              color: mintContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.point_of_sale_rounded, color: primaryTeal),
                    SizedBox(width: 10),
                    Text(
                      'Terminal de Cobro Rápido',
                      style: TextStyle(
                        color: primaryTeal,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de Cliente
            TextField(
              controller: _clienteController,
              decoration: _inputDecoration('Cliente', Icons.person_outline_rounded),
            ),
            const SizedBox(height: 16),

            // Card Formulario de Productos
            Card(
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
                    const Text(
                      'Agregar Producto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Selector de Catálogo si hay productos
                    if (provider.productos.isNotEmpty) ...[
                      DropdownButtonFormField<ProductoModel>(
                        decoration: _inputDecoration('Seleccionar del Catálogo', Icons.inventory_2_outlined),
                        initialValue: _productoSeleccionado,
                        dropdownColor: Colors.white,
                        items: provider.productos.map((prod) {
                          return DropdownMenuItem(
                            value: prod,
                            child: Text(
                              '${prod.nombre} (${prod.precioUnitario.toStringAsFixed(2)} Bs)',
                              style: const TextStyle(fontSize: 14, color: textDark),
                            ),
                          );
                        }).toList(),
                        onChanged: (prod) {
                          if (prod != null) {
                            setState(() {
                              _productoSeleccionado = prod;
                              _nombreProductoController.text = prod.nombre;
                              _precioController.text = prod.precioUnitario.toString();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextField(
                      controller: _nombreProductoController,
                      decoration: _inputDecoration('Nombre del Producto', Icons.shopping_bag_outlined),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _precioController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration('Precio (Bs)', Icons.attach_money_rounded),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _cantidadController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration('Cantidad', Icons.numbers_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryTeal,
                          side: const BorderSide(color: primaryTeal, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _agregarAlCarrito,
                        icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                        label: const Text(
                          'AÑADIR A LA VENTA',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vista del Carrito de Compras
            if (_carrito.isNotEmpty) ...[
              Card(
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
                      const Text(
                        'Resumen del Carrito',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _carrito.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final item = _carrito[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              item.nombreProducto,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: textDark, fontSize: 14),
                            ),
                            subtitle: Text(
                              '${item.cantidad} x ${item.precioUnitario.toStringAsFixed(2)} Bs',
                              style: const TextStyle(color: textMuted, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${item.subtotal.toStringAsFixed(2)} Bs',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryTeal, fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                                  onPressed: () => _eliminarDelCarrito(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Panel de Totales y Pago
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a Cobrar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
                        ),
                        Text(
                          '${_totalVenta.toStringAsFixed(2)} Bs.',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    TextField(
                      controller: _montoPagadoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration('Monto Recibido (Bs)', Icons.payments_outlined),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saldo / Cambio:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textMuted),
                        ),
                        Text(
                          '${_saldo.toStringAsFixed(2)} Bs.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _saldo <= 0 ? primaryTeal : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Método de Pago
            DropdownButtonFormField<String>(
              initialValue: _metodoPago,
              decoration: _inputDecoration('Método de Pago', Icons.account_balance_wallet_outlined),
              dropdownColor: Colors.white,
              items: ['Efectivo', 'QR', 'Tarjeta'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: textDark, fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _metodoPago = val!),
            ),
            const SizedBox(height: 20),

            // Botonera de Acciones
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: _guardarTransaccion,
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textDark,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _limpiarFormulario,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text('NUEVO', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Generar Recibo PDF
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryTeal,
                side: BorderSide(color: primaryTeal.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (provider.ventas.isNotEmpty) {
                  final ultimaVenta = provider.ventas.first;
                  PdfGenerator.generarNotaVenta(ultimaVenta);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      content: const Text('⚠️ No hay ventas registradas para generar recibo'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
              label: const Text('GENERAR RECIBO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}