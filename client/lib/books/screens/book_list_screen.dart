import 'package:flutter/material.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LibraTech Library'),
      ),
      body: const Center(
        child: Text(
          'Books will be listed here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
