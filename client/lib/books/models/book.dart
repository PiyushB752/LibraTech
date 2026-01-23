import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final int totalCopies;
  final int availableCopies;
  final String description;
  final Timestamp createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.totalCopies,
    required this.availableCopies,
    required this.description,
    required this.createdAt,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Book(
      id: doc.id,
      title: data['title'],
      author: data['author'],
      isbn: data['isbn'],
      category: data['category'],
      totalCopies: data['totalCopies'],
      availableCopies: data['availableCopies'],
      description: data['description'],
      createdAt: data['createdAt'],
    );
  }
}