import 'package:flutter/material.dart';
import '../screens/ai/ai_screen.dart';

class GlobalAiFab extends StatelessWidget {
  const GlobalAiFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 16,
      child: FloatingActionButton(
        heroTag: 'global-ai',
        child: const Icon(Icons.smart_toy),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AiScreen()),
          );
        },
      ),
    );
  }
}
