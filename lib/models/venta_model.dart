class DetalleVentaModel {
  final int? id;
  final int? ventaId;
  final int? productoId;
  final String nombreProducto;
  final double precioUnitario;
  final double cantidad;
  final double subtotal;

  DetalleVentaModel({
    this.id,
    this.ventaId,
    this.productoId,
    required this.nombreProducto,
    required this.precioUnitario,
    required this.cantidad,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ventaId': ventaId,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'precioUnitario': precioUnitario,
      'cantidad': cantidad,
      'subtotal': subtotal,
    };
  }

  factory DetalleVentaModel.fromMap(Map<String, dynamic> map) {
    return DetalleVentaModel(
      id: map['id'],
      ventaId: map['ventaId'],
      productoId: map['productoId'],
      nombreProducto: map['nombreProducto'] ?? '',
      precioUnitario: (map['precioUnitario'] as num).toDouble(),
      cantidad: (map['cantidad'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }
}

class VentaModel {
  final int? id;
  final String fechaHora;
  final String cliente;
  final double totalVenta;
  final double montoPagado;
  final double saldo;
  final String metodoPago;
  final List<DetalleVentaModel> detalles;

  VentaModel({
    this.id,
    required this.fechaHora,
    required this.cliente,
    required this.totalVenta,
    required this.montoPagado,
    required this.saldo,
    required this.metodoPago,
    this.detalles = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fechaHora': fechaHora,
      'cliente': cliente,
      'totalVenta': totalVenta,
      'montoPagado': montoPagado,
      'saldo': saldo,
      'metodoPago': metodoPago,
    };
  }

  factory VentaModel.fromMap(Map<String, dynamic> map, {List<DetalleVentaModel> detalles = const []}) {
    return VentaModel(
      id: map['id'],
      fechaHora: map['fechaHora'],
      cliente: map['cliente'] ?? 'Cliente General',
      totalVenta: (map['totalVenta'] as num).toDouble(),
      montoPagado: (map['montoPagado'] as num).toDouble(),
      saldo: (map['saldo'] as num).toDouble(),
      metodoPago: map['metodoPago'] ?? 'Efectivo',
      detalles: detalles,
    );
  }
}