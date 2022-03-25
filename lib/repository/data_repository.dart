import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../models/game.dart';

class DataRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('games');

  Stream<DocumentSnapshot> getDocumentSnap(String id) {
    return collection.doc(id).snapshots();
  }

  Future<Game> getGame(String id) {
    return collection.doc(id).get().then((value) => Game.fromSnapshot(value));
  }

  Future<void> addGame(Game game, String id) {
    return collection.doc(id).set(game.toJson());
  }

  Future<void> updateGame(Game game) async {
    await collection.doc(game.referenceId).update(game.toJson());
  }

  void deleteGame(Game game) async {
    await collection.doc(game.referenceId).delete();
  }

  Future<bool> checkGame(String id) {
    return collection.doc(id).get().then((value) => value.exists);
  }

  Future<List<String>> loadPossibleWords() async {
    String text = await rootBundle.loadString('assets/words.txt');
    return text.split('\n');
  }

}
