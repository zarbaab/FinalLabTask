import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncToFirestore(Map<String, dynamic> classData) async {
    await _firestore.collection('classes').add(classData);
  }

  Future<void> deleteFromFirestore(int id) async {
    final snapshot =
        await _firestore.collection('classes').where('id', isEqualTo: id).get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
