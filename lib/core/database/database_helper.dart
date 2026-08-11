import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/venta_model.dart';
import '../../models/producto_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pos_general.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabla Productos
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        codigoBarras TEXT,
        precioUnitario REAL NOT NULL,
        stock REAL NOT NULL,
        unidadMedida TEXT NOT NULL
      )
    ''');

    // Tabla Ventas
    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fechaHora TEXT NOT NULL,
        cliente TEXT NOT NULL,
        totalVenta REAL NOT NULL,
        montoPagado REAL NOT NULL,
        saldo REAL NOT NULL,
        metodoPago TEXT NOT NULL
      )
    ''');

    // Tabla Detalle de Ventas
    await db.execute('''
      CREATE TABLE detalle_ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ventaId INTEGER NOT NULL,
        productoId INTEGER,
        nombreProducto TEXT NOT NULL,
        precioUnitario REAL NOT NULL,
        cantidad REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (ventaId) REFERENCES ventas (id) ON DELETE CASCADE
      )
    ''');
  }

  // ==================== OPERACIONES PRODUCTOS ====================

  Future<int> guardarProducto(ProductoModel producto) async {
    final db = await instance.database;
    return await db.insert('productos', producto.toMap());
  }

  Future<List<ProductoModel>> obtenerProductos() async {
    final db = await instance.database;
    final result = await db.query('productos', orderBy: 'nombre ASC');
    return result.map((json) => ProductoModel.fromMap(json)).toList();
  }

  // ==================== OPERACIONES VENTAS ====================

  Future<int> guardarVenta(VentaModel venta) async {
    final db = await instance.database;
    
    // Transacción para guardar venta y sus detalles de forma atómica
    return await db.transaction((txn) async {
      int ventaId = await txn.insert('ventas', venta.toMap());

      for (var detalle in venta.detalles) {
        await txn.insert('detalle_ventas', {
          'ventaId': ventaId,
          'productoId': detalle.productoId,
          'nombreProducto': detalle.nombreProducto,
          'precioUnitario': detalle.precioUnitario,
          'cantidad': detalle.cantidad,
          'subtotal': detalle.subtotal,
        });

        // Opcional: Descontar del stock si el producto existe
        if (detalle.productoId != null) {
          await txn.rawUpdate('''
            UPDATE productos 
            SET stock = stock - ? 
            WHERE id = ?
          ''', [detalle.cantidad, detalle.productoId]);
        }
      }
      return ventaId;
    });
  }

  Future<List<VentaModel>> obtenerTodasLasVentas() async {
    final db = await instance.database;
    final ventasData = await db.query('ventas', orderBy: 'fechaHora DESC');

    List<VentaModel> ventas = [];

    for (var v in ventasData) {
      final detallesData = await db.query(
        'detalle_ventas',
        where: 'ventaId = ?',
        whereArgs: [v['id']],
      );

      final detalles = detallesData.map((d) => DetalleVentaModel.fromMap(d)).toList();
      ventas.add(VentaModel.fromMap(v, detalles: detalles));
    }

    return ventas;
  }

  Future<int> eliminarVenta(int id) async {
    final db = await instance.database;
    return await db.delete('ventas', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== DASHBOARD / REPORTES ====================

  Future<double> obtenerTotalVentasPorFiltro(String filtro) async {
    final db = await instance.database;
    String query = '';

    if (filtro == 'hoy') {
      query = "SELECT SUM(totalVenta) FROM ventas WHERE date(fechaHora) = date('now', 'localtime')";
    } else if (filtro == 'semana') {
      query = "SELECT SUM(totalVenta) FROM ventas WHERE date(fechaHora) >= date('now', 'weekday 0', '-7 days')";
    } else if (filtro == 'mes') {
      query = "SELECT SUM(totalVenta) FROM ventas WHERE strftime('%m', fechaHora) = strftime('%m', 'now', 'localtime')";
    }

    final List<Map<String, dynamic>> result = await db.rawQuery(query);
    if (result.isNotEmpty && result.first.values.first != null) {
      return (result.first.values.first as num).toDouble();
    }
    return 0.0;
  }

  Future cerrar() async {
    final db = await instance.database;
    db.close();
  }
}