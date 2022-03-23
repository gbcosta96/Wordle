import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordle/models/player.dart';

class Game {
  List<Player> players;
  String word;
  bool reset;
  String? referenceId;
  
  Game({required this.players, required this.word, this.referenceId, required this.reset});

  factory Game.fromSnapshot(DocumentSnapshot snapshot) {
    final newGame = Game.fromJson(snapshot.data() as Map<String, dynamic>);
    newGame.referenceId = snapshot.reference.id;
    return newGame;
  }
  
  
  factory Game.fromJson(Map<String, dynamic> json) =>
    _gameFromJson(json);
  
  Map<String, dynamic> toJson() => _gameToJson(this);

}

Game _gameFromJson(Map<String, dynamic> json) {
  return Game(
    word: json['word'] as String,
    players: _convertPlayers(json['players'] as List<dynamic>),
    reset: json['reset'],
  );
}

List<Player> _convertPlayers(List<dynamic> playerMap) {
  final players = <Player>[];
  
  for(final player in playerMap) {
    players.add(Player.fromJson(player as Map<String, dynamic>));
  }
  return players;
}

 Map<String, dynamic> _gameToJson(Game instance) {
  return <String, dynamic> {
    'players': _playerList(instance.players),
    'word': instance.word,
    'reset': instance.reset,
  };
}

List<Map<String, dynamic>>? _playerList(List<Player>? players) {
  if (players == null) {
    return null;
  }
  final playerMap = <Map<String, dynamic>>[];
  for (var player in players) {
    playerMap.add(player.toJson());
  }
  return playerMap;
}
