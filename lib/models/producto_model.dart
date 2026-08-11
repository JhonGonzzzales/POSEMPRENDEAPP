class ProductoModel {
  final int? id;
  final String nombre;
  final String? codigoBarras;
  final double precioUnitario;
  final double stock;
  final String unidadMedida;

  ProductoModel({
    this.id,
    required this.nombre,
    this.codigoBarras,
    required this.precioUnitario,
    this.stock = 0.0,
    this.unidadMedida = 'unidad',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'codigoBarras': codigoBarras,
      'precioUnitario': precioUnitario,
      'stock': stock,
      'unidadMedida': unidadMedida,
    };
  }

  factory ProductoModel.fromMap(Map<String, dynamic> map) {
    return ProductoModel(
      id: map['id'],
      nombre: map['nombre'],
      codigoBarras: map['codigoBarras'],
      precioUnitario: (map['precioUnitario'] as num).toDouble(),
      stock: (map['stock'] as num).toDouble(),
      unidadMedida: map['unidadMedida'] ?? 'unidad',
    );
  }
}