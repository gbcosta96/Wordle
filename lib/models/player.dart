import 'package:wordle/models/guess.dart';

class Player {
  String name;
  List<Guess>? guesses;
  bool? reset;
  
  Player({required this.name, this.guesses, this.reset});
  
  factory Player.fromJson(Map<String, dynamic> json) =>
    _playerFromJson(json);
  
  Map<String, dynamic> toJson() => _playerToJson(this);

}

Player _playerFromJson(Map<String, dynamic> json) {
  return Player(
    name: json['name'] as String,
    guesses: json['guesses'] != null ? _convertGuesses(json['guesses'] as List<dynamic>) : null,
    reset: json['reset']
  );
}

List<Guess> _convertGuesses(List<dynamic> guessMap) {
  final guesses = <Guess>[];
  
  for(final guess in guessMap) {
    guesses.add(Guess.fromJson(guess as Map<String, dynamic>));
  }
  return guesses;
}

Map<String, dynamic> _playerToJson(Player instance) {
  return <String, dynamic>{
  'name': instance.name,
  'guesses': _guessList(instance.guesses),
  'reset': instance.reset,
  };
}

List<Map<String, dynamic>>? _guessList(List<Guess>? guesses) {
  if (guesses == null) {
    return null;
  }
  final guessMap = <Map<String, dynamic>>[];
  for (var guess in guesses) {
    guessMap.add(guess.toJson());
  }
  return guessMap;
}
