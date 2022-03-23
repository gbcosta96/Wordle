import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/game.dart';

class DataRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('games');

  Stream<DocumentSnapshot> getDocumentSnap(String id) {
    return collection.doc(id).snapshots();
  }

  Future<DocumentSnapshot> getDocument(String id) {
    return collection.doc(id).get();
  }

  Future<DocumentReference> addGame(Game game) {
    return collection.add(game.toJson());
  }

  void updateGame(Game game) async {
    await collection.doc(game.referenceId).update(game.toJson());
  }

  void deleteGame(Game game) async {
    await collection.doc(game.referenceId).delete();
  }
}
