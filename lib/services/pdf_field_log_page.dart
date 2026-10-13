import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/character.dart';

/// Page 3 of the exported PDF: fillable Field Log / After Action Report entries.
class PdfFieldLogPage {
  static const int entryCount = 3;

  static pw.Page build(Character character) {
    return pw.Page(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _header(character),
          pw.SizedBox(height: 10),
          for (var i = 1; i <= entryCount; i++) ...[
            _entry(i),
            if (i < entryCount) pw.SizedBox(height: 10),
          ],
          pw.Spacer(),
          pw.Text(
            'Fields are fillable in a PDF reader (Acrobat, Preview, browser). Print for hand-written entries.',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _header(Character character) {
    final callsign = character.nickname.isNotEmpty
        ? ' "${character.nickname}"'
        : '';
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        border: pw.Border.all(color: PdfColors.grey700, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'FIELD LOG / AFTER ACTION REPORT',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'REPORTING: ${character.name}$callsign',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  static pw.Widget _entry(int n) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700, width: 1),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ENTRY $n',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _field('DTG (DATE-TIME GROUP)', 'log${n}_dtg', 150, 16),
              pw.SizedBox(width: 6),
              _field('GRID REF / LOCATION', 'log${n}_grid', 150, 16),
              pw.SizedBox(width: 6),
              _field('SUBJECT / OPERATION', 'log${n}_subject', 200, 16),
            ],
          ),
          pw.SizedBox(height: 4),
          _field('DETAILS', 'log${n}_details', 504, 100, multiline: true),
        ],
      ),
    );
  }

  static pw.Widget _field(
    String label,
    String name,
    double width,
    double height, {
    bool multiline = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 1),
        pw.TextField(
          name: name,
          width: width,
          height: height,
          textStyle: const pw.TextStyle(fontSize: 9),
          fieldFlags: multiline ? {PdfFieldFlags.multiline} : null,
          child: pw.Container(
            width: width,
            height: height,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.grey500, width: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}
