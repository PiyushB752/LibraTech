import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/book_service.dart';

class MyBorrowedBooksScreen extends StatelessWidget {
  const MyBorrowedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bookService = BookService();

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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No borrowed books'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final dueAtTimestamp = data['dueAt'] as Timestamp?;
              final dueAt = dueAtTimestamp?.toDate();
              final isOverdue =
                  dueAt != null ? DateTime.now().isAfter(dueAt) : false;

              return Card(
                child: ListTile(
                  title: Text(data['bookTitle']),
                  subtitle: dueAt != null
                      ? Text(
                          isOverdue
                              ? 'OVERDUE (Due: ${dueAt.toLocal().toString().split(' ')[0]})'
                              : 'Due: ${dueAt.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.green,
                          ),
                        )
                      : null,
                  trailing: ElevatedButton(
                    child: const Text('Return'),
                    onPressed: () async {
                      try {
                        final bookSnap = await FirebaseFirestore.instance
                            .collection('books')
                            .doc(data['bookId'])
                            .get();

                        await bookService.returnBook(
                          borrowedDocId: doc.id,
                          bookId: data['bookId'],
                          currentAvailable: bookSnap['availableCopies'],
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Book returned successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
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