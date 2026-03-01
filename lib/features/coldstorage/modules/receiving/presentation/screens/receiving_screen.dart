import 'package:flutter/material.dart';

class ReceivingScreen extends StatelessWidget {
  const ReceivingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Receiving form starts here'),
        ),
      ),
    );
  }
}
