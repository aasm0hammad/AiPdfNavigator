import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/constants.dart';
import 'bloc/pdf_summary_bloc.dart';
import 'bloc/pdf_summary_event.dart';
import 'bloc/pdf_summary_state.dart';

class PdfSummaryScreen extends StatefulWidget {
  const PdfSummaryScreen({super.key});

  @override
  State<PdfSummaryScreen> createState() => _PdfSummaryScreenState();
}

class _PdfSummaryScreenState extends State<PdfSummaryScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.appBackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Text App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text("Document Chat", style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: BlocConsumer<PdfSummaryBloc, PdfSummaryState>(
                  listener: (context, state) {
                    if (state is PdfSummaryError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent));
                    }
                    if (state is PdfSummaryLoaded || state is PdfSummaryUploaded) {
                      _scrollToBottom();
                    }
                  },
                  builder: (context, state) {
                    if (state is PdfSummaryInitial) {
                      return _buildInitialState(context);
                    }

                    // Build the chat history based on states mapping
                    List<Widget> messages = [];

                    // If anything has been uploaded, we show the uploaded file bubble
                    String? fName; String? fSize; DateTime? time;
                    
                    if (state is PdfSummaryUploaded) { fName = state.fileName; fSize = state.fileSize; time = state.uploadTime; }
                    else if (state is PdfSummaryLoading) { fName = state.fileName; fSize = state.fileSize; time = state.uploadTime; }
                    else if (state is PdfSummaryLoaded) { fName = state.fileName; fSize = state.fileSize; time = state.uploadTime; }

                    if (fName != null && fSize != null && time != null) {
                      messages.add(_buildFileBubble(fName, fSize, time, context));
                    }

                    if (state is PdfSummaryLoading) {
                      messages.add(_buildLoadingBubble());
                    }

                    if (state is PdfSummaryLoaded) {
                      messages.add(_buildAiSummaryBubble(state.summary, context));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      itemCount: messages.length,
                      itemBuilder: (context, index) => messages[index],
                    );
                  },
                ),
              ),
              
              // Bottom Chat Input Bar
              _buildBottomBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.white.withOpacity(0.5), shape: BoxShape.circle),
            child: const Icon(Icons.description_outlined, size: 60, color: AppColors.iconPink),
          ),
          const SizedBox(height: 24),
          const Text("No document attached.", style: TextStyle(fontSize: 18, color: AppColors.textDark, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tap the + icon below to upload a PDF.", style: TextStyle(color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildFileBubble(String fileName, String fileSize, DateTime time, BuildContext context) {
    String formattedTime = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.userBubbleGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(5),
          ),
          boxShadow: [
             BoxShadow(color: AppColors.iconPink.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.picture_as_pdf, color: AppColors.iconPink, size: 24),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text("PDF • $fileSize", style: const TextStyle(color: AppColors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(formattedTime, style: TextStyle(color: AppColors.white.withOpacity(0.8), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: AppColors.aiBubble,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.iconPink)),
            SizedBox(width: 12),
            Text("Analyzing document...", style: TextStyle(color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildAiSummaryBubble(String summary, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.aiBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(5),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: MarkdownBody(
          data: summary,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(color: AppColors.textDark, fontSize: 15, height: 1.5),
            h1: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textDark),
            h2: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark),
            code: TextStyle(backgroundColor: Colors.grey.shade100, color: AppColors.iconPink, fontFamily: 'monospace'),
            codeblockDecoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
     return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              BlocBuilder<PdfSummaryBloc, PdfSummaryState>(
                builder: (context, state) {
                  return IconButton(
                    icon: Icon(state is PdfSummaryInitial ? Icons.add_circle : Icons.change_circle, color: AppColors.iconPink, size: 30),
                    onPressed: state is PdfSummaryLoading ? null : () => context.read<PdfSummaryBloc>().add(PickPdfEvent()),
                  );
                }
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                     color: AppColors.inputFill,
                     borderRadius: BorderRadius.circular(25),
                  ),
                  child: BlocBuilder<PdfSummaryBloc, PdfSummaryState>(
                    builder: (context, state) {
                      String hint = "Upload a PDF to get started...";
                      if (state is PdfSummaryUploaded) hint = "Ready to summarize!";
                      if (state is PdfSummaryLoading) hint = "Thinking...";
                      if (state is PdfSummaryLoaded) hint = "Summary generated!";
                      
                      return Text(hint, style: TextStyle(color: AppColors.textLight));
                    }
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<PdfSummaryBloc, PdfSummaryState>(
                builder: (context, state) {
                  return IconButton(
                    icon: const Icon(Icons.arrow_circle_up, color: AppColors.authPrimary, size: 34),
                    onPressed: (state is PdfSummaryUploaded) 
                      ? () => context.read<PdfSummaryBloc>().add(GeneratePdfSummaryEvent())
                      : null,
                  );
                }
              ),
            ],
          ),
        ),
      );
  }
}
