import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withAlpha((0.1 * 255).round()),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}