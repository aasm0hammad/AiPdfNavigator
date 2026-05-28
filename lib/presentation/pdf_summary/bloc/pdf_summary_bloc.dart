import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../data/services/gemini_service.dart';
import 'pdf_summary_event.dart';
import 'pdf_summary_state.dart';

class PdfSummaryBloc extends Bloc<PdfSummaryEvent, PdfSummaryState> {
  final GeminiService _geminiService;

  Uint8List? currentFileBytes;
  String? currentFileName;
  String? currentFileSize;
  DateTime? currentUploadTime;

  PdfSummaryBloc({required GeminiService geminiService}) 
      : _geminiService = geminiService,
        super(PdfSummaryInitial()) {
    on<PickPdfEvent>(_onPickPdf);
    on<GeneratePdfSummaryEvent>(_onGenerateSummary);
    on<RemovePdfEvent>(_onRemovePdf);
  }

  Future<void> _onPickPdf(PickPdfEvent event, Emitter<PdfSummaryState> emit) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
      
      if (result != null && result.files.single.bytes != null) {
        currentFileBytes = result.files.single.bytes;
        currentFileName = result.files.single.name;
        currentUploadTime = DateTime.now();
        
        int bytes = result.files.single.size;
        currentFileSize = bytes < 1024 * 1024 ? "${(bytes / 1024).toStringAsFixed(1)} KB" : "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
        
        emit(PdfSummaryUploaded(
           pdfBytes: currentFileBytes!, 
           fileName: currentFileName!, 
           fileSize: currentFileSize!,
           uploadTime: currentUploadTime!,
        ));
      } else {
        if (currentFileBytes == null) emit(PdfSummaryInitial());
      }
    } catch (e) {
      emit(PdfSummaryError("Failed to pick PDF."));
      if (currentFileBytes == null) emit(PdfSummaryInitial());
    }
  }

  Future<void> _onGenerateSummary(GeneratePdfSummaryEvent event, Emitter<PdfSummaryState> emit) async {
    if (currentFileBytes == null) return emit(PdfSummaryError("Please upload a PDF first."));
    
    emit(PdfSummaryLoading(
      pdfBytes: currentFileBytes!, 
      fileName: currentFileName!, 
      fileSize: currentFileSize!,
      uploadTime: currentUploadTime!
    ));
    
    try {
      String summary = await _geminiService.getPdfSummary(currentFileBytes!, prompt: event.prompt);
      
      emit(PdfSummaryLoaded(
        pdfBytes: currentFileBytes!, 
        fileName: currentFileName!, 
        fileSize: currentFileSize!, 
        uploadTime: currentUploadTime!,
        summary: summary
      ));
    } catch (e) {
      emit(PdfSummaryError("Empty or unreadable PDF. API limit reached or processing failed."));
      emit(PdfSummaryUploaded(
        pdfBytes: currentFileBytes!, 
        fileName: currentFileName!, 
        fileSize: currentFileSize!,
        uploadTime: currentUploadTime!
      ));
    }
  }

  void _onRemovePdf(RemovePdfEvent event, Emitter<PdfSummaryState> emit) {
    currentFileBytes = null; 
    currentFileName = null; 
    currentFileSize = null;
    currentUploadTime = null;
    emit(PdfSummaryInitial());
  }
}
