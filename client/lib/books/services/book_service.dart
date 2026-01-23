import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Book>> getAllBooks() async {
    final snapshot = await _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Book.fromFirestore(doc))
        .toList();
  }
}