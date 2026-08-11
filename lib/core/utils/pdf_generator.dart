import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/venta_model.dart';

class PdfGenerator {
  // Colores primarios para el PDF
  static const PdfColor primaryTeal = PdfColor.fromInt(0xFF027F81);
  static const PdfColor textDark = PdfColor.fromInt(0xFF191C1D);
  static const PdfColor textMuted = PdfColor.fromInt(0xFF70777C);
  static const PdfColor lineDivider = PdfColor.fromInt(0xFFE0E3E5);

  static Future<void> generarNotaVenta(VentaModel venta) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Center(
                child: pw.Text(
                  'POS EMPRENDEDOR',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'Comprobante de Venta',
                  style: const pw.TextStyle(fontSize: 8, color: textMuted),
                ),
              ),
              pw.SizedBox(height: 10),

              // Divider estilizado
              pw.Container(height: 1, color: lineDivider),
              pw.SizedBox(height: 8),

              // Metadata
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('FECHA', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: textMuted)),
                  pw.Text(venta.fechaHora, style: const pw.TextStyle(fontSize: 7, color: textDark)),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('CLIENTE', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: textMuted)),
                  pw.Text(venta.cliente, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: textDark)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Container(height: 1, color: lineDivider),
              pw.SizedBox(height: 8),

              // Tabla Encabezados
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text('Descripción', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: textDark)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('Cant.', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: textDark)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: textDark)),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),

              // Lista de Detalles
              if (venta.detalles.isNotEmpty) ...[
                ...venta.detalles.map((item) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 3),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 4,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(item.nombreProducto, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textDark)),
                                pw.Text('${item.precioUnitario.toStringAsFixed(2)} Bs. / un', style: const pw.TextStyle(fontSize: 7, color: textMuted)),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text('${item.cantidad}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, color: textDark)),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text('${item.subtotal.toStringAsFixed(2)} Bs.', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textDark)),
                          ),
                        ],
                      ),
                    )),
              ] else ...[
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Sin productos registrados', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                  ),
                ),
              ],

              pw.SizedBox(height: 8),
              pw.Container(height: 1, color: lineDivider),
              pw.SizedBox(height: 8),

              // Sección Totales
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: primaryTeal)),
                  pw.Text('${venta.totalVenta.toStringAsFixed(2)} Bs.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: primaryTeal)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Monto Recibido:', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                  pw.Text('${venta.montoPagado.toStringAsFixed(2)} Bs.', style: const pw.TextStyle(fontSize: 8, color: textDark)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cambio / Saldo:', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                  pw.Text('${venta.saldo.toStringAsFixed(2)} Bs.', style: const pw.TextStyle(fontSize: 8, color: textDark)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Método de Pago:', style: const pw.TextStyle(fontSize: 8, color: textMuted)),
                  pw.Text(venta.metodoPago, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textDark)),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  '¡Gracias por su preferencia!',
                  style: const pw.TextStyle(fontSize: 8, color: textMuted),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Nota_Venta_${venta.cliente.replaceAll(' ', '_')}.pdf',
    );
  }
}