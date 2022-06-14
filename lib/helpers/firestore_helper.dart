import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/models/employee_model.dart';

class FirestoreHelper {
  FirestoreHelper._();
  static final FirestoreHelper firestoreHelper = FirestoreHelper._();

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference? collectionReference;

  void initDB() {
    collectionReference = firestore.collection('employees');
  }

  Future<void> insertData({required Employee data, required String? id}) async {
    initDB();

    Map<String, dynamic> emp = {
      'name': data.name,
      'age': data.age,
      'role': data.role,
    };

    DocumentSnapshot documentSnapshot =
        await firestore.collection('counter').doc('emp_counter').get();

    Map myId = documentSnapshot.data() as Map;

    int fetchedId = myId['id'];

    await collectionReference!.doc(id).set(emp);

    await firestore
        .collection('counter')
        .doc('emp_counter')
        .update({'id': ++fetchedId});
  }

  Future<void> deleteData({required String id}) async {
    initDB();

    DocumentSnapshot documentSnapshot =
        await firestore.collection('counter').doc('emp_counter').get();

    Map myId = documentSnapshot.data() as Map;

    int fetchedId = myId['id'];

    await collectionReference!.doc(id).delete();

    await firestore
        .collection('counter')
        .doc('emp_counter')
        .update({'id': --fetchedId});
  }

  Future<void> updateData({required Employee data, required String? id}) async {
    initDB();

    Map<String, dynamic> emp = {
      'name': data.name,
      'age': data.age,
      'role': data.role,
    };

    await collectionReference!.doc(id).update(emp);
  }
}
