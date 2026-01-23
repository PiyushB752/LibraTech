import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../../auth/screens/login_screen.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final BookService _bookService = BookService();
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _bookService.getAllBooks();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading books',
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          final books = snapshot.data;

          if (books == null || books.isEmpty) {
            return const Center(
              child: Text('No books available'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final book = books[index];

              return Card(
                color: Colors.grey.shade900,
                elevation: 3,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(book: book),
                      ),
                    );
                  },
                  title: Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Author: ${book.author}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Available: ${book.availableCopies}/${book.totalCopies}',
                        style: TextStyle(
                          color: book.availableCopies > 0
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white54,
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
