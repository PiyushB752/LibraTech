import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../../auth/screens/login_screen.dart';
import 'my_borrowed_books_screen.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final BookService _bookService = BookService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final user = FirebaseAuth.instance.currentUser;

  void _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  List<String> _getCategories(List<Book> books) {
    final categories = books.map((b) => b.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

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
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by title or author',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          StreamBuilder<List<Book>>(
            stream: _bookService.getBooksStream(),
            builder: (context, snapshot) {
              final books = snapshot.data ?? [];
              final categories = _getCategories(books);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedCategory = value);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: _bookService.getBooksStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = snapshot.data!;
                final filteredBooks = books.where((book) {
                  final matchesSearch = book.title
                          .toLowerCase()
                          .contains(_searchQuery) ||
                      book.author.toLowerCase().contains(_searchQuery);
                  final matchesCategory = _selectedCategory == 'All' ||
                      book.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredBooks.isEmpty) {
                  return const Center(child: Text('No books found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBooks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];

                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('borrowed_books')
                          .where('userId', isEqualTo: user!.uid)
                          .where('bookId', isEqualTo: book.id)
                          .limit(1)
                          .get(),
                      builder: (context, borrowedSnap) {
                        final alreadyBorrowed =
                            borrowedSnap.data?.docs.isNotEmpty ?? false;
                        final isAvailable = book.availableCopies > 0;

                        return Card(
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookDetailScreen(book: book),
                                ),
                              );
                            },
                            title: Text(book.title),
                            subtitle: Text(
                              alreadyBorrowed
                                  ? 'Already borrowed'
                                  : 'Available: ${book.availableCopies}/${book.totalCopies}',
                              style: TextStyle(
                                color: alreadyBorrowed
                                    ? Colors.orange
                                    : (isAvailable
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: (!isAvailable || alreadyBorrowed)
                                  ? null
                                  : () async {
                                      try {
                                        await _bookService.borrowBook(
                                          book: book,
                                          userId: user!.uid,
                                        );
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                          ),
                                        );
                                      }
                                    },
                              child: const Text('Borrow'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}