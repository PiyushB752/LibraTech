import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookService _bookService = BookService();
  bool _isLoading = false;

  Future<void> _borrowBook() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null){
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _bookService.borrowBook(
        book: widget.book,
        userId: user.uid,
      );

      if (!mounted){
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book borrowed successfully')),
      );

      Navigator.pop(context); 
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final isAvailable = book.availableCopies > 0;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Author: ${book.author}'),
            Text('ISBN: ${book.isbn}'),
            Text('Category: ${book.category}'),
            const SizedBox(height: 12),
            Text(book.description),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isAvailable && !_isLoading ? _borrowBook : null,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        isAvailable
                            ? 'Borrow Book'
                            : 'Not Available',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}