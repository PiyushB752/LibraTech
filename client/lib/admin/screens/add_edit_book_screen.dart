import 'package:flutter/material.dart';
import '../services/admin_book_service.dart';
import '../../books/models/book.dart';

class AddEditBookScreen extends StatefulWidget {
  final Book? book;
  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminBookService();

  late TextEditingController title;
  late TextEditingController author;
  late TextEditingController isbn;
  late TextEditingController category;
  late TextEditingController description;
  late TextEditingController copies;

  @override
  void initState() {
    super.initState();

    title = TextEditingController(text: widget.book?.title ?? '');
    author = TextEditingController(text: widget.book?.author ?? '');
    isbn = TextEditingController(text: widget.book?.isbn ?? '');
    category = TextEditingController(text: widget.book?.category ?? '');
    description =
        TextEditingController(text: widget.book?.description ?? '');
    copies = TextEditingController(
      text: widget.book?.totalCopies.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.book != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Book' : 'Add Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(title, 'Title'),
              _field(author, 'Author'),
              _field(isbn, 'ISBN'),
              _field(category, 'Category'),
              _field(description, 'Description'),
              _field(copies, 'Total Copies', isNumber: true),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(isEdit ? 'Update Book' : 'Add Book'),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final total = int.parse(copies.text);

                  int available;

                  if (isEdit) {
                    final borrowedCount =
                        widget.book!.totalCopies -
                        widget.book!.availableCopies;

                    available = total - borrowedCount;

                    if (available < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Total copies cannot be less than borrowed books',
                          ),
                        ),
                      );
                      return;
                    }
                  } else {
                    available = total;
                  }

                  final book = Book(
                    id: widget.book?.id ?? '',
                    title: title.text,
                    author: author.text,
                    isbn: isbn.text,
                    category: category.text,
                    description: description.text,
                    totalCopies: total,
                    availableCopies: available,
                  );

                  if (isEdit) {
                    await _service.updateBook(book);
                  } else {
                    await _service.addBook(book);
                  }

                  if (!mounted) return;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }
}