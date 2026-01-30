import 'package:flutter/material.dart';
import '../services/admin_book_service.dart';
import '../../books/models/book.dart';
import 'add_edit_book_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminService = AdminBookService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditBookScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<List<Book>>(
        stream: adminService.getAllBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!;

          if (books.isEmpty) {
            return const Center(child: Text('No books found'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];

              return Card(
                child: ListTile(
                  title: Text(book.title),
                  subtitle: Text(
                    '${book.author} • ${book.category}\n'
                    'Available: ${book.availableCopies}/${book.totalCopies}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddEditBookScreen(book: book),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await adminService.deleteBook(book.id);
                        },
                      ),
                    ],
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