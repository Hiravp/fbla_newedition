import 'package:http/http.dart' as http;
import 'dart:convert';

class AiService {
  static const String _apiKey = 'sk-0d877ebb598a4158a5582c059bcb93da';
  static const String _baseUrl = 'https://api.openai.com/v1';

  /// Chat with ChatGPT using the OpenAI API
  Future<String> chat(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Analyze input with FBLA-specific context
  Future<String> analyze(String input) async {
    final fblaPrompt = '''You are an AI assistant for FBLA (Future Business Leaders of America) members. 
Provide helpful, concise responses related to business leadership, entrepreneurship, and FBLA activities.

User query: $input''';
    
    return chat(fblaPrompt);
  }

  /// Get FBLA-specific advice
  Future<String> getFBLAAdvice(String topic) async {
    final prompt = 'Provide practical FBLA advice about: $topic';
    return chat(prompt);
  }

  /// Generate event recommendations
  Future<String> generateEventRecommendation(List<String> interests) async {
    final prompt = 'Based on these interests: ${interests.join(", ")}, recommend relevant FBLA events and why they would be valuable.';
    return chat(prompt);
  }

  /// Generate study guide
  Future<String> generateStudyGuide(String topic) async {
    final prompt = 'Create a concise study guide for FBLA members on: $topic. Include key concepts and tips for success.';
    return chat(prompt);
  }

  /// Answer FBLA-specific questions
  Future<String> answerFBLAQuestion(String question) async {
    final prompt = 'Answer this FBLA-related question: $question';
    return chat(prompt);
  }
}
