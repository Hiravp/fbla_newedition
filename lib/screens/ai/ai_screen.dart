import 'package:flutter/material.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  // FBLA knowledge base
  final Map<String, String> fblaData = {
    "events":
        "Upcoming FBLA Events:\n• Regional Leadership Conference – Jan 15\n• State Leadership Conference – Mar 15–17\n• National Leadership Conference – Jun 28–Jul 1 (Atlanta, GA)",
    "resources":
        "FBLA Resources:\n• Competitive Events Guidelines\n• Member Handbook\n• Business Plan Templates\n• Scholarship Opportunities",
    "rules":
        "FBLA Rules:\n• Members may compete in 1 individual/team event + 1 chapter event.\n• Must follow dress code.\n• Must be registered for NLC.\n• Must stay in official FBLA housing.",
  };

  // Quiz questions
  final List<Map<String, dynamic>> quizQuestions = [
    {
      "q": "When was FBLA founded?",
      "a": ["1940", "1942", "1950", "1961"],
      "correct": 1
    },
    {
      "q": "What does FBLA stand for?",
      "a": [
        "Future Business Leaders of America",
        "Federal Business Leadership Association",
        "Future Banking Leaders Association",
        "Finance & Business Learning Academy"
      ],
      "correct": 0
    },
    {
      "q": "Where is NLC 2026 being held?",
      "a": ["Chicago", "Atlanta", "Dallas", "Orlando"],
      "correct": 1
    },
  ];

  int quizIndex = -1;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _controller.clear();
      _isTyping = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _handleBotResponse(text);
    });
  }

  void _handleBotResponse(String input) {
    String response = "";

    // Quiz mode
    if (input.toLowerCase() == "/quiz") {
      quizIndex = 0;
      response = _formatQuizQuestion();
    } else if (quizIndex >= 0) {
      response = _checkQuizAnswer(input);
    }

    // Commands
    else if (input.toLowerCase() == "/help") {
      response = "Commands:\n"
          "• /quiz – Start FBLA quiz\n"
          "• /events – View upcoming events\n"
          "• /resources – View resources\n"
          "• /rules – View FBLA rules\n"
          "• Ask anything!";
    } else if (fblaData.containsKey(input.toLowerCase())) {
      response = fblaData[input.toLowerCase()]!;
    }

    // General fallback
    else {
      response =
          "I'm your FBLA Assistant! Try asking about events, competitions, rules, or type /help.";
    }

    setState(() {
      _messages.add({"sender": "bot", "text": response});
      _isTyping = false;
    });
  }

  String _formatQuizQuestion() {
    final q = quizQuestions[quizIndex];
    String formatted = "Question ${quizIndex + 1}:\n${q['q']}\n\n";

    for (int i = 0; i < q["a"].length; i++) {
      formatted += "${i + 1}. ${q['a'][i]}\n";
    }

    return formatted;
  }

  String _checkQuizAnswer(String input) {
    final q = quizQuestions[quizIndex];
    int? userAnswer = int.tryParse(input);

    if (userAnswer == null || userAnswer < 1 || userAnswer > 4) {
      return "Please answer with a number 1–4.";
    }

    if (userAnswer - 1 == q["correct"]) {
      quizIndex++;
      if (quizIndex >= quizQuestions.length) {
        quizIndex = -1;
        return "Correct! 🎉\nYou've completed the quiz!";
      }
      return "Correct! 🎉\n\n${_formatQuizQuestion()}";
    } else {
      return "Incorrect. Try again!";
    }
  }

  Widget _bubble(Map<String, dynamic> msg) {
    final isUser = msg["sender"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          msg["text"],
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _typingIndicator() {
    return Row(
      children: [
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text("Typing..."),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var msg in _messages) _bubble(msg),
                if (_isTyping) _typingIndicator(),
              ],
            ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: const Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask me anything... or type /help",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
