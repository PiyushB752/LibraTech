import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../../auth/screens/login_screen.dart';
import 'my_borrowed_books_screen.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted){
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BookService bookService = BookService();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyBorrowedBooksScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: bookService.getBooksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading books'));
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(child: Text('No books available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final book = books[index];
              final isAvailable = book.availableCopies > 0;

              return Card(
                elevation: 3,
                child: ListTile(
                  title: Text(book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Author: ${book.author}'),
                      Text(
                        'Available: ${book.availableCopies}/${book.totalCopies}',
                        style: TextStyle(
                          color: isAvailable
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: isAvailable
                        ? () async {
                            await bookService.borrowBook(
                              book: book,
                              userId: user!.uid,
                            );
                          }
                        : null,
                    child: const Text('Borrow'),
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