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
        // Return helpful fallback response
        return _getFallbackResponse(message);
      }
    } catch (e) {
      print('AI API error: $e');
      // Return helpful fallback response
      return _getFallbackResponse(message);
    }
  }

  /// Fallback response when API unavailable
  String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('competition')) {
      return 'Great question about competition! In demo mode, I recommend: 1) Study case studies thoroughly, 2) Practice time management, 3) Attend workshops, 4) Network with other members. For real AI responses, ensure API connection is available.';
    } else if (lowerMessage.contains('how to prepare') || lowerMessage.contains('prepare for')) {
      return 'Here\'s how to prepare effectively: 1) Start early with case study analysis, 2) Form a study group, 3) Attend all training sessions, 4) Practice presentations, 5) Review rules and guidelines. (Demo mode - connect for personalized AI advice)';
    } else if (lowerMessage.contains('event') || lowerMessage.contains('conference')) {
      return 'Check the Calendar tab to see upcoming events and competitions! FBLA offers various competitions throughout the year. Attending regional and state competitions helps you build skills and network with other members. (Demo mode - real data syncs when online)';
    } else if (lowerMessage.contains('help') || lowerMessage.contains('assist')) {
      return 'I\'m your FBLA AI Assistant! I can help with: competition tips, event recommendations, study guides, FBLA advice, and career guidance. What would you like to know? (Currently in demo mode)';
    } else {
      return 'Thanks for your question! In demo mode, I can provide general FBLA guidance. For real AI responses powered by ChatGPT, please ensure your internet connection is active. I can help with competitions, events, study tips, and career advice!';
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
