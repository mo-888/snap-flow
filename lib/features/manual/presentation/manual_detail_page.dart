import 'package:flutter/material.dart';

class ManualDetailPage extends StatelessWidget {
  final String manualId;
  const ManualDetailPage({super.key, required this.manualId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('手册详情')),
      body: Center(child: Text('Manual: $manualId')),
    );
  }
}