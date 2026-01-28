import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowedBook {
  final String id;
  final String bookId;
  final String bookTitle;
  final Timestamp borrowedAt;
  final Timestamp dueAt;

  BorrowedBook({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.borrowedAt,
    required this.dueAt,
  });

  factory BorrowedBook.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BorrowedBook(
      id: doc.id,
      bookId: data['bookId'],
      bookTitle: data['bookTitle'],
      borrowedAt: data['borrowedAt'],
      dueAt: data['dueAt'],
    );
  }
}