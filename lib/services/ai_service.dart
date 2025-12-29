class AiService {
  Future<String> analyze(String input) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'AI response for: $input';
  }
}
