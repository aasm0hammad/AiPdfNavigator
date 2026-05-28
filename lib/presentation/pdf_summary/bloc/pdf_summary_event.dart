import 'package:flutter/foundation.dart';

@immutable
abstract class PdfSummaryEvent {}

class PickPdfEvent extends PdfSummaryEvent {}

class GeneratePdfSummaryEvent extends PdfSummaryEvent {
  final String prompt;
  GeneratePdfSummaryEvent({this.prompt = "Summarize this document in simple English with bullet points and a short conclusion"});
}

class RemovePdfEvent extends PdfSummaryEvent {}
