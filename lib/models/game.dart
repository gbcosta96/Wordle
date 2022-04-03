import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  String word;
  String referenceId;
  
  Game({required this.word, required this.referenceId});

  factory Game.fromSnapshot(DocumentSnapshot gameSnapshot) {
    Map<String, dynamic> gameData = gameSnapshot.data() as Map<String, dynamic>;
    final newGame = Game(
      word: gameData['word'],
      referenceId: gameSnapshot.reference.id,
    );                       
    return newGame;
  }

  toJson() {
    return <String, dynamic> {
      'word': word,
    };
  }
}
