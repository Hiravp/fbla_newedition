import 'package:flutter/material.dart';

class PlaceholderWidget extends StatelessWidget {
  final String text;
  const PlaceholderWidget({Key? key, this.text = 'Placeholder'}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(child: Text(text));
}
