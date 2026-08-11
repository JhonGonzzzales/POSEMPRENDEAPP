import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/venta_model.dart';
import '../models/producto_model.dart';

class VentaProvider extends ChangeNotifier {
  List<VentaModel> _ventas = [];
  List<ProductoModel> _productos = [];
  bool _cargando = false;

  double _totalHoy = 0.0;
  double _totalSemana = 0.0;
  double _totalMes = 0.0;

  List<VentaModel> get ventas => _ventas;
  List<ProductoModel> get productos => _productos;
  bool get cargando => _cargando;
  double get totalHoy => _totalHoy;
  double get totalSemana => _totalSemana;
  double get totalMes => _totalMes;

  Future<void> cargarDatos() async {
    _cargando = true;
    notifyListeners();

    try {
      _ventas = await DatabaseHelper.instance.obtenerTodasLasVentas();
      _productos = await DatabaseHelper.instance.obtenerProductos();

      _totalHoy = await DatabaseHelper.instance.obtenerTotalVentasPorFiltro('hoy');
      _totalSemana = await DatabaseHelper.instance.obtenerTotalVentasPorFiltro('semana');
      _totalMes = await DatabaseHelper.instance.obtenerTotalVentasPorFiltro('mes');
    } catch (e) {
      debugPrint("Error al cargar datos: $e");
    }

    _cargando = false;
    notifyListeners();
  }

  // Productos
  Future<void> agregarProducto(ProductoModel nuevoProducto) async {
    await DatabaseHelper.instance.guardarProducto(nuevoProducto);
    await cargarDatos();
  }

  // Ventas
  Future<void> agregarVenta(VentaModel nuevaVenta) async {
    await DatabaseHelper.instance.guardarVenta(nuevaVenta);
    await cargarDatos();
  }

  Future<void> borrarVenta(int id) async {
    await DatabaseHelper.instance.eliminarVenta(id);
    await cargarDatos();
  }
}