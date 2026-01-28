import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<Book>> getBooksStream() {
    return _firestore.collection('books').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList(),
        );
  }

  Future<bool> hasUserAlreadyBorrowed({
    required String userId,
    required String bookId,
  }) async {
    final snapshot = await _firestore
        .collection('borrowed_books')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> borrowBook({
    required Book book,
    required String userId,
  }) async {
    if (book.availableCopies <= 0) return;

    final alreadyBorrowed = await hasUserAlreadyBorrowed(
      userId: userId,
      bookId: book.id,
    );

    if (alreadyBorrowed) {
      throw Exception('You already borrowed this book');
    }

    final dueDate = DateTime.now().add(const Duration(days: 14));
    final batch = _firestore.batch();
    final bookRef = _firestore.collection('books').doc(book.id);
    final borrowedRef = _firestore.collection('borrowed_books').doc();

    batch.update(bookRef, {
      'availableCopies': book.availableCopies - 1,
    });

    batch.set(borrowedRef, {
      'bookId': book.id,
      'bookTitle': book.title,
      'userId': userId,
      'borrowedAt': FieldValue.serverTimestamp(),
      'dueAt': Timestamp.fromDate(dueDate),
    });

    await batch.commit();
  }

  Future<void> returnBook({
    required String borrowedDocId,
    required String bookId,
    required int currentAvailable,
  }) async {
    final batch = _firestore.batch();

    final borrowedRef = _firestore.collection('borrowed_books').doc(borrowedDocId);
    final bookRef = _firestore.collection('books').doc(bookId);

    batch.delete(borrowedRef);
    batch.update(bookRef, {
      'availableCopies': currentAvailable + 1,
    });

    await batch.commit();
  }
}