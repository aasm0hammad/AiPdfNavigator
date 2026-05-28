import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService() : _model = GenerativeModel(
    model: 'gemini-2.5-flash', // Upgrading to 2.5-flash as shown in your earlier snippet
    apiKey: AppConstants.geminiApiKey,
  );

  Future<String> getChatResponse(String prompt, List<Map<String, String>> history) async {
    try {
      final chatSession = _model.startChat(
        history: history.map((e) => Content(e['role'] == 'user' ? 'user' : 'model', [TextPart(e['text'] ?? '')])).toList(),
      );
      final response = await chatSession.sendMessage(Content.text(prompt));
      return response.text ?? 'Sorry, I could not generate a response.';
    } catch (e) {
      throw Exception('Gemini API Error: $e');
    }
  }

  Future<String> getPdfSummary(Uint8List bytes, {String prompt = """
You are an expert document analyzer.

Summarize the following document in a structured way:

1. Key Points (5-7 bullet points)
2. Important Insights
3. Final Conclusion

Keep the language simple and easy to understand.
"""}) async {
    try {
      
      // Feed the PDF natively directly to Gemini instead of extracting text
      final pdfPart = DataPart('application/pdf', bytes);
      final textPart = TextPart(prompt);

      final response = await _model.generateContent([
        Content.multi([textPart, pdfPart])
      ]);
      return response.text ?? 'Failed to summarize.';
    } catch (e) {
       throw Exception('PDF Processing Error: $e');
    }
  }
}
