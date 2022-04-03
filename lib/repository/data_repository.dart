import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:wordle/models/guess.dart';
import 'package:wordle/models/player.dart';

import '../models/game.dart';

class DataRepository {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('games');

  Stream<DocumentSnapshot> getGameSnap(String id) {
    return collection.doc(id).snapshots();
  }

  Stream<QuerySnapshot> getPlayersSnap(String id) {
    return collection.doc(id).collection('players').snapshots();
  }

  Stream<QuerySnapshot> getGuessesSnap(String id) {
    return collection.doc(id).collection('guesses').snapshots();
  }

  Future<bool> checkGame(String id) {
    return collection.doc(id).get().then((value) => value.exists);
  }

  Future<List<String>> loadPossibleWords() async {
    String text = await rootBundle.loadString('assets/words.txt');
    return text.split('\n');
  }

  Future<Game> getGame(id) async {
    DocumentSnapshot gameSnapshot = await collection.doc(id).get();
    return Game.fromSnapshot(gameSnapshot);
  }

  Future<List<Player>> getPlayers(id) async {
    List<QueryDocumentSnapshot> playersSnapshot = 
      await collection.doc(id).collection('players').get()
      .then((value) => value.docs);
    
    return playersFromSnap(playersSnapshot);
  }

  List<Player> playersFromSnap(List<QueryDocumentSnapshot> snap) {
    final players = <Player>[];
    for(final player in snap) {
      players.add(Player.fromJson(player.data() as Map<String, dynamic>, player.reference.id));
    }
    return players;
  }

  Future<List<Guess>> getGuesses(id) async {
    List<QueryDocumentSnapshot> guessesSnapshot = 
      await collection.doc(id).collection('guesses').get()
      .then((value) => value.docs);
    
    return guessesFromSnap(guessesSnapshot);
  }

  List<Guess> guessesFromSnap(List<QueryDocumentSnapshot> snap) {
    final guesses = <Guess>[];
    for(final guess in snap) {
      guesses.add(Guess.fromJson(guess.data() as Map<String, dynamic>));
    }
    return guesses;
  }
  
  Future<void> addGame(Game game, Player host) async {
    await collection.doc(game.referenceId).set(game.toJson());
    await addPlayer(game.referenceId, host);
  }

  Future<void> addPlayer(String gameId, Player player) async {
    await collection.doc(gameId).collection('players')
      .doc(DateTime.now().millisecondsSinceEpoch.toString())
      .set(player.toJson());
  }

  Future<void> removePlayer(String gameId, Player player) async {
    await collection.doc(gameId).collection('players')
      .doc(player.refId).delete();
  }

  Future<void> addGuess(String gameId, Guess guess) async {
    await collection.doc(gameId).collection('guesses')
      .doc(DateTime.now().millisecondsSinceEpoch.toString())
      .set(guess.toJson());
  }

  Future<void> removeGuesses(String gameId) async {
    var snapshots = await collection.doc(gameId).collection('guesses').get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> newWord(String gameId, String word) async {
    await removeGuesses(gameId);
    await collection.doc(gameId).update({"word": word});
    //ready = false;
  }

  Future<void> updatePlayer(String gameId, Player player) async {
    await collection.doc(gameId).collection('players').doc(player.refId).update(player.toJson());
  }

}
