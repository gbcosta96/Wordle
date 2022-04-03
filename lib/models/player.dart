
class Player {
  String name;
  bool ready;
  bool over;
  
  Player({
    required this.name,
    required this.ready,
    required this.over,
  });
  
  factory Player.fromJson(Map<String, dynamic> json) {
     return Player(
      name: json['name'],
      ready: json['ready'],
      over: json['over'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'name': name,
      'ready': ready,
      'over': over,
    };
  }
}
