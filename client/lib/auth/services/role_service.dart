import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc['role'] as String?;
  }
}