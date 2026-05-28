import 'dart:typed_data';
import 'package:flutter/foundation.dart';

@immutable
abstract class PdfSummaryState {}

class PdfSummaryInitial extends PdfSummaryState {}

class PdfSummaryUploaded extends PdfSummaryState {
  final Uint8List pdfBytes;
  final String fileName;
  final String fileSize;
  final DateTime uploadTime;

  PdfSummaryUploaded({required this.pdfBytes, required this.fileName, required this.fileSize, required this.uploadTime});
}

class PdfSummaryLoading extends PdfSummaryState {
  final Uint8List pdfBytes;
  final String fileName;
  final String fileSize;
  final DateTime uploadTime;

  PdfSummaryLoading({required this.pdfBytes, required this.fileName, required this.fileSize, required this.uploadTime});
}

class PdfSummaryLoaded extends PdfSummaryState {
  final Uint8List pdfBytes;
  final String fileName;
  final String fileSize;
  final DateTime uploadTime;
  final String summary;

  PdfSummaryLoaded({
    required this.pdfBytes,
    required this.fileName,
    required this.fileSize,
    required this.uploadTime,
    required this.summary,
  });
}

class PdfSummaryError extends PdfSummaryState {
  final String message;
  PdfSummaryError(this.message);
}
