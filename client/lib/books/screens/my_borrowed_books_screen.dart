import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/book_service.dart';

class MyBorrowedBooksScreen extends StatelessWidget {
  const MyBorrowedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final BookService bookService = BookService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Borrowed Books')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrowed_books')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No borrowed books'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(data['bookTitle']),
                  trailing: ElevatedButton(
                    child: const Text('Return'),
                    onPressed: () async {
                      final bookSnap = await FirebaseFirestore.instance
                          .collection('books')
                          .doc(data['bookId'])
                          .get();

                      final currentAvailable =
                          bookSnap['availableCopies'];

                      await bookService.returnBook(
                        borrowedDocId: doc.id,
                        bookId: data['bookId'],
                        currentAvailable: currentAvailable,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}