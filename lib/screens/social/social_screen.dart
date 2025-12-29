import 'package:flutter/material.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Social')),
      body: const Center(child: Text('Social screen placeholder')),
    );
  }
}
