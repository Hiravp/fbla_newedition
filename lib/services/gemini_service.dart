import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyDxeHrEVKtPL3vV7bVnbOOL2QgDl_9Q6Gc'; // Replace with your actual key
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> generateResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> getFBLAAdvice(String topic) async {
    final prompt = '''You are an expert FBLA (Future Business Leaders of America) advisor. 
    Provide helpful, accurate, and encouraging advice about: $topic
    Keep your response concise (2-3 paragraphs max) and relevant to high school/college students.''';
    return generateResponse(prompt);
  }

  Future<String> generateEventRecommendation(String userInterests) async {
    final prompt = '''Based on these FBLA member interests: $userInterests
    Suggest 3 FBLA events, competitions, or activities they should participate in.
    Explain why each is relevant. Format as a numbered list.''';
    return generateResponse(prompt);
  }

  Future<String> generateStudyGuide(String topic) async {
    final prompt = '''Create a concise study guide for a high school student learning about: $topic
    Include key concepts, examples, and practice questions. Keep it under 500 words.''';
    return generateResponse(prompt);
  }

  Future<String> answerFBLAQuestion(String question) async {
    final prompt = '''A FBLA member is asking: $question
    Provide a helpful, accurate answer that's appropriate for high school students.
    Reference FBLA programs/events if relevant.''';
    return generateResponse(prompt);
  }
}
