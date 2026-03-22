import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ApiService {

  /// PDF SUMMARY
  static Future<String> getPdfSummary(File file) async {

    /// READ PDF
    List<int> bytes = await file.readAsBytes();

    PdfDocument document = PdfDocument(inputBytes: bytes);

    String text = PdfTextExtractor(document).extractText();

    document.dispose();

    /// SEND TEXT TO AI
    String prompt =
        "Summarize the following PDF document:\n\n$text";

    String response = await getData(prompt);

    return response;
  }

  /// NORMAL CHAT
  static Future<String> getData(String question) async {

    String url =
        "API";

    Uri uri = Uri.parse(url);

    var body = {
      "contents": [
        {
          "parts": [
            {"text": question}
          ]
        }
      ]
    };

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {

      var data = jsonDecode(response.body);

      String aiText =
      data["candidates"][0]["content"]["parts"][0]["text"];

      return aiText;

    } else {
      throw Exception("Failed to load data");
    }
  }
}