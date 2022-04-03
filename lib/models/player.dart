
import 'package:wordle/pages/main_page.dart';

class Player {
  String name;
  bool ready;
  PlayState state;
  int wins;
  String? refId;
  
  Player({
    required this.name,
    required this.ready,
    required this.state,
    required this.wins,
    this.refId,
  });
  
  factory Player.fromJson(Map<String, dynamic> json, String refId) {
     return Player(
      name: json['name'],
      ready: json['ready'],
      state: PlayState.values[json['state']],
      wins: json['wins'],
      refId: refId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic> {
      'name': name,
      'ready': ready,
      'state': state.index,
      'wins': wins,
    };
  }
}
