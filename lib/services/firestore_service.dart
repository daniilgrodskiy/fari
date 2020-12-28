import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';


// SERVICE ONLY USED BY database.dart
class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  Future<void> setData({
    @required String path,
    @required Map<String, dynamic> data,
  }) async {
    final reference = Firestore.instance.document(path);
    print("Updating: $path: with $data");
    await reference.setData(data);
  }

  Future<void> deleteData({@required String path}) async {
    final reference = Firestore.instance.document(path);
    print('Deleting: $path');
    await reference.delete();
  }

  // TODO: Understand this collectionStream method!
  Stream<List<T>> collectionStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentID), // Do this to every document
    Query queryBuilder(Query query), // Closure for filtering through a document's properties
    int sort(T lhs, T rhs),
  }) {
    Query query = Firestore.instance.collection(path);

    // 'queryBuilder' is used to filter!
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.documents
          .map((snapshot) => builder(snapshot.data, snapshot.documentID))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<T> documentStream<T>({
    @required String path,
    @required T builder(Map<String, dynamic> data, String documentID),
  }) {
    final DocumentReference reference = Firestore.instance.document(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data, snapshot.documentID));
  }
}
