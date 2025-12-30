import 'package:flutter/material.dart';

class ToastContext extends StatelessWidget {
  const ToastContext({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Toast Context')),
      body: Center(child: Text('ToastContext Widget')),
    );
  }
}
