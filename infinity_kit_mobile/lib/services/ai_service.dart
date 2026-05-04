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
          systemPrompt = "You are Infinity AI, a brilliant and friendly assistant. Use emojis where appropriate.";
          final historyString = context != null 
              ? context.map((m) => "${m['role']?.toUpperCase()}: ${m['content']}").join('\n') 
              : "";
          userPrompt = "$historyString\nUSER: $message\nINFINITY AI:";
          break;
        case 'improve':
          systemPrompt = "You are a world-class editor. Rewrite the following text to make it sound professional, persuasive, and elegant. Keep the meaning but elevate the vocabulary.";
          userPrompt = text ?? "";
          break;
        case 'summarize':
          systemPrompt = "You are an expert at information density. Summarize the text using clear bullet points. Include a 'Key Takeaway' at the end.";
          userPrompt = text ?? "";
          break;
        case 'code':
          systemPrompt = "You are a senior software engineer. Explain, fix, or optimize the following code. Provide clear explanations and clean code blocks.";
          userPrompt = text ?? "";
          break;
        case 'translate':
          systemPrompt = "You are a professional translator. Translate the following text accurately while preserving tone and context.";
          userPrompt = text ?? "";
          break;
        default:
          userPrompt = text ?? message ?? "";
      }

      final url = Uri.parse('$_textBaseUrl${Uri.encodeComponent(userPrompt)}?system=${Uri.encodeComponent(systemPrompt)}&model=openai');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('AI Error: $e');
      return null;
    }
  }

  static String getImageUrl(String prompt) {
    final seed = DateTime.now().millisecondsSinceEpoch % 1000000;
    return '$_imageBaseUrl${Uri.encodeComponent(prompt)}?seed=$seed&width=1024&height=1024&nologo=true&enhance=true';
  }
}
