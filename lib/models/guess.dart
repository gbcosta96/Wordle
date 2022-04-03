class Guess {
  String word;
  String result;
  String player;
  
  Guess({required this.word, required this.result, required this.player});
  
  factory Guess.fromJson(Map<String, dynamic> json) {
    return Guess(
      result: json['result'] as String,
      word: json['word'] as String,
      player: json['player'] as String,
    );
  }
  Map<String, dynamic> toJson() => _guessToJson(this);
}

 Map<String, dynamic> _guessToJson(Guess instance) =>
  <String, dynamic>{
    'result': instance.result,
    'word': instance.word,
    'player': instance.player,
  };