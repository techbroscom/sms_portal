import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class ExportUtil {
  static final DateFormat _dateFormatter = DateFormat('yyyyMMdd_HHmmss');

  /// Generate standardized file name with optional timestamp and unique ID
  static String generateFileName({
    required String baseName,
    bool includeTimestamp = true,
    bool includeUniqueId = true,
  }) {
    final timestamp = includeTimestamp ? '_${_dateFormatter.format(DateTime.now())}' : '';
    final uniqueId = includeUniqueId ? '_${_generateUniqueId(4)}' : '';
    final fileName = '${baseName.trim()}$timestamp$uniqueId';

    if (kDebugMode) {
      print("Generated Filename: $fileName");
    } // Debugging
    return fileName;
  }

  /// Generate a short random string for uniqueness
  static String _generateUniqueId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Platform-aware file path resolution
  static Future<String?> _getSavePath(String fileName, String extension) async {
    if (kIsWeb) return null;

    final directory = await getApplicationDocumentsDirectory();
    final sanitized = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
    return '${directory.path}/$sanitized.$extension';
  }

  /// Generic file export handler
  static Future<void> exportFile({
    required String fileName,
    required String extension,
    required List<int> bytes,
    String mimeType = 'application/octet-stream',
  }) async {
    try {
      if (kIsWeb) {
        final blob = html.Blob([bytes], mimeType);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', '$fileName.$extension')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final path = await _getSavePath(fileName, extension);
        if (path == null) return;

        final file = File(path);
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(path)]);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Export error: $e');
      }
      rethrow;
    }
  }

  /// CSV Export with flexible parameters
  static Future<void> exportToCSV({
    required String fileName,
    bool includeTimestamp = true,
    required List<String> headers,
    required List<List<dynamic>> data,
  }) async {
    final csvName = generateFileName(
      baseName: fileName,
      includeTimestamp: includeTimestamp,
    );
    if (kDebugMode) {
      print("Final CSV Filename: $csvName");
    } // Debugging

    final csvData = [headers, ...data];
    final csvString = const ListToCsvConverter().convert(csvData);
    final bytes = utf8.encode(csvString);

    await exportFile(
      fileName: csvName,
      extension: 'csv',
      bytes: bytes,
      mimeType: 'text/csv',
    );
  }

  /// Excel Export with styling options
  static Future<void> exportToExcel({
    required String fileName,
    bool includeTimestamp = true,
    required List<String> headers,
    required List<List<dynamic>> data,
    CellStyle? headerStyle,
  }) async {
    final excelName = generateFileName(
      baseName: fileName,
      includeTimestamp: includeTimestamp,
    );
    if (kDebugMode) {
      print("Final Excel Filename: $excelName");
    } // Debugging

    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Add headers with optional styling
    headers.asMap().forEach((index, header) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: index, rowIndex: 0));
      cell.value = header;
      if (headerStyle != null) cell.cellStyle = headerStyle;
    });

    // Add data rows
    data.asMap().forEach((rowIndex, row) {
      row.asMap().forEach((colIndex, value) {
        sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: colIndex,
          rowIndex: rowIndex + 1, // Offset for header row
        )).value = value;
      });
    });

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to generate Excel file');

    await exportFile(
      fileName: excelName,
      extension: 'xlsx',
      bytes: bytes,
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }
}