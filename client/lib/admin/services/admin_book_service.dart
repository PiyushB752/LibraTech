import 'package:cloud_firestore/cloud_firestore.dart';
import '../../books/models/book.dart';

class AdminBookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Book>> getAllBooks() {
    return _firestore.collection('books').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addBook(Book book) async {
    final docRef = _firestore.collection('books').doc();

    await docRef.set({
      'title': book.title,
      'author': book.author,
      'isbn': book.isbn,
      'category': book.category,
      'description': book.description,
      'totalCopies': book.totalCopies,
      'availableCopies': book.totalCopies,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBook(Book book) async {
    await _firestore.collection('books').doc(book.id).update({
      'title': book.title,
      'author': book.author,
      'isbn': book.isbn,
      'category': book.category,
      'description': book.description,
      'totalCopies': book.totalCopies,
      'availableCopies': book.availableCopies,
    });
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }
}