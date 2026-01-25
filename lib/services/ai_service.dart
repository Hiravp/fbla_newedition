import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String _url = 'http://127.0.0.1:8000/chat';

  Future<String> chat(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['response'];
      } else {
        return 'AI server error.';
      }
    } catch (e) {
      return 'Could not reach AI server.';
    }
  }
}
