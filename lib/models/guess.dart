class Guess {
  String word;
  String result;
  
  Guess({required this.word, required this.result});
  
  
  factory Guess.fromJson(Map<String, dynamic> json) =>
    _guessFromJson(json);
  
  Map<String, dynamic> toJson() => _guessToJson(this);

}

Guess _guessFromJson(Map<String, dynamic> json) {
  return Guess(
    result: json['result'] as String,
    word: json['word'] as String,
  );
}

 Map<String, dynamic> _guessToJson(Guess instance) =>
  <String, dynamic>{
    'result': instance.result,
    'word': instance.word,
  };