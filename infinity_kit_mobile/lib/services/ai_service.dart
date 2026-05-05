import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService {
  static const String _textBaseUrl = 'https://text.pollinations.ai/';
  static const String _imageBaseUrl = 'https://image.pollinations.ai/prompt/';

  static Future<String?> ask({
    required String type,
    String? message,
    String? text,
    String? prompt,
    List<Map<String, String>>? context,
  }) async {
    try {
      String systemPrompt = "You are Infinity AI, a premium and highly intelligent assistant. Provide detailed, helpful, and professional answers.";
      String userPrompt = "";

      switch (type) {
        case 'chat':
          systemPrompt = "You are Infinity AI, a brilliant, helpful, and friendly assistant. Provide direct, informative answers. Use markdown tables and lists for clarity when appropriate, but DO NOT use '---' as a separator. Be concise and professional.";
          final historyString = context != null 
              ? context.take(4).map((m) => "${m['role']?.toUpperCase()}: ${m['content']}").join('\n') 
              : "";
          userPrompt = "$historyString\nUSER: $message\nASSISTANT:";
          break;
        case 'improve':
          systemPrompt = "You are a world-class editor. Rewrite the following text to make it sound professional and elegant. Provide only the improved text.";
          userPrompt = text ?? "";
          break;
        case 'summarize':
          systemPrompt = "Summarize the following text using clear, concise bullet points.";
          userPrompt = text ?? "";
          break;
        case 'code':
          systemPrompt = "You are a senior software engineer. Explain the following code in detail, breaking down what each part does. If there are errors, suggest fixes. Use markdown code blocks.";
          userPrompt = "Please explain this code:\n\n$text";
          break;
        case 'translate':
          systemPrompt = "Translate the following text accurately. Provide only the translated result.";
          userPrompt = text ?? "";
          break;
        default:
          userPrompt = text ?? message ?? "";
      }

      if (userPrompt.trim().isEmpty) {
        return "Please provide more text for the AI to process.";
      }

      final url = Uri.parse('$_textBaseUrl${Uri.encodeComponent(userPrompt)}?system=${Uri.encodeComponent(systemPrompt)}&model=openai');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return response.body;
      } else {
        debugPrint('AI Status Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('AI Exception: $e');
      return null;
    }
  }

  static String getImageUrl(String prompt) {
    final seed = DateTime.now().millisecondsSinceEpoch % 1000000;
    return '$_imageBaseUrl${Uri.encodeComponent(prompt)}?seed=$seed&width=1024&height=1024&nologo=true&enhance=true';
  }
}
