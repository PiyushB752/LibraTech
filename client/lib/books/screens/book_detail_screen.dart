import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? _borrowedDocId;
  int _currentAvailable = 0;

  @override
  void initState() {
    super.initState();
    _loadBookData();
    _checkBorrowStatus();
  }

  Future<void> _loadBookData() async {
    final bookSnap = await FirebaseFirestore.instance
        .collection('books')
        .doc(widget.book.id)
        .get();
    if (!mounted) return;

    setState(() {
      _currentAvailable = bookSnap['availableCopies'];
    });
  }

  Future<void> _checkBorrowStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('borrowed_books')
        .where('userId', isEqualTo: user.uid)
        .where('bookId', isEqualTo: widget.book.id)
        .limit(1)
        .get();

    if (!mounted) return;

    setState(() {
      _borrowedDocId = snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
    });
  }

  Future<void> _borrowBook() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await _bookService.borrowBook(
        book: widget.book,
        userId: user.uid,
      );

      await _loadBookData(); 
      await _checkBorrowStatus(); 

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book borrowed successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _returnBook() async {
    if (_borrowedDocId == null) return;

    setState(() => _isLoading = true);

    try {
      await _bookService.returnBook(
        borrowedDocId: _borrowedDocId!,
        bookId: widget.book.id,
        currentAvailable: _currentAvailable,
      );

      await _loadBookData(); 

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book returned successfully')),
      );

      setState(() {
        _borrowedDocId = null; 
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final userHasBorrowed = _borrowedDocId != null;
    final isAvailable = _currentAvailable > 0;
    final canBorrow = isAvailable && !userHasBorrowed && !_isLoading;
    final canReturn = userHasBorrowed && !_isLoading;

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
            const SizedBox(height: 8),
            Text(
              userHasBorrowed
                  ? 'You have already borrowed this book'
                  : 'Available: $_currentAvailable/${book.totalCopies}',
              style: TextStyle(
                color: userHasBorrowed
                    ? Colors.orange
                    : (isAvailable ? Colors.green : Colors.red),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canBorrow
                    ? _borrowBook
                    : canReturn
                        ? _returnBook
                        : null,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : Text(userHasBorrowed
                        ? 'Return Book'
                        : (isAvailable ? 'Borrow Book' : 'Not Available')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}