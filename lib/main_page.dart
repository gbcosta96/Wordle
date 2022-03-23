import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle/models/game.dart';
import 'package:wordle/models/guess.dart';
import 'package:wordle/repository/data_repository.dart';
import 'package:wordle/widgets/app_icon.dart';
import 'package:wordle/constants/app_colors.dart';
import 'package:wordle/widgets/keyboard/custom_keyboard.dart';
import 'package:wordle/models/tile.dart';
import 'package:wordle/widgets/word_grid.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  MainPageState createState() => MainPageState();
}


class MainPageState extends State<MainPage> {
  int wordLen = 0;
  FocusNode myFocusNode = FocusNode();
  late List<List<List<Tile>>> grid;
  late List<Iterable<Tile>> flattenedGrid = [];
  late List<String> wrongs = [];
  late List<String> rights = [];
  late String guess = '';
  late String word;
  int currentLine = 0;
  bool over = false;
  late List<String> lstStr;
  String gameId = "6TfrtZAHSH6qp1jljkr3";
  String name = "gbcosta96";
  Game? game;
  List<List<Widget>> stackItems = [];

  final DataRepository repository = DataRepository();

  Future<String> _read() async {
    String text = '';
    text = await rootBundle.loadString('assets/words.txt');
    return text;
  }
  
  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async{
    String fileText = await _read();
    lstStr = fileText.split('\n');
    final stream = await repository.getDocument(gameId);
    game = Game.fromSnapshot(stream);
    resetWord(game!.players.indexWhere((element) => element.name == name) == 1);
  }

  void resetWord(bool database) async {
    Random rdm = Random();
    currentLine = 0;
    guess = '';
    wrongs = [];
    rights = [];
    over = false;
    final stream = await repository.getDocument(gameId);
    game = Game.fromSnapshot(stream);
    word = database ? game!.word : lstStr[rdm.nextInt(lstStr.length)].trim();
    if(!database){
      game!.word = word;
      game!.players[0].guesses = null;
      game!.players[1].guesses = null;
      game!.reset = true;
      repository.updateGame(game!);
    }

    setState(() {
      wordLen = word.length;
      grid = List.generate(2, (player) => List.generate(7, (y) => List.generate(wordLen, (x) => Tile(x, y, " ", AppColors.letterNeutral))));
      flattenedGrid = [];
      for(var playersGrid in grid){
        flattenedGrid.add(playersGrid.expand((e) => e));
      }
    });
    
  }

  void _insertText(String text){
    if(guess.length < wordLen && over == false){
      guess += text;
      setState(() {
        for(var i = 0; i < wordLen; i++){
          grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].val = ' ';
        }
        for(var i = 0; i < guess.length; i++){
          grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].val = guess[i];
        }
      });
    }
  }

  void _backspace(){
    if(guess.isNotEmpty){
      guess = guess.substring(0, guess.length - 1);
      setState(() {
        for(var i = 0; i < wordLen; i++){
          grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].val = ' ';
        }
        for(var i = 0; i < guess.length; i++){
          grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].val = guess[i];
        }
      });
    }
  }

  void _submit(){
    if(guess.length == wordLen){
      bool checkPossible = false;
      for(String possibleWords in lstStr){
        if(possibleWords.trim() == guess){
          checkPossible = true;
          break;
        }
      }
      if(checkPossible == true){
        _verifyWord();
        if(currentLine < 6){
          currentLine++;
          guess = '';
        }
        else{
          over = true;
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Palavra inválida"),
            duration: Duration(seconds: 1),
          )
        );
      }
    }
  }

  void _verifyWord(){
    if(guess == word){
      over = true;
    }

    List<String> _guess = guess.split('');
    List<String> _word = word.split('');
    
    for(var i = 0; i < _guess.length; i++){
      if(_guess[i] == _word[i]){
        grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].color = AppColors.letterRight;
        rights.add(_guess[i]);
        _word[i] = "#";
      }
    }
    for(var i = 0; i < _guess.length; i++){
      if(grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].color == AppColors.letterNeutral){
        if(_word.contains(_guess[i])){
          _word.remove(_guess[i]);
          grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].color = AppColors.letterPlace;
        }
        else{
          grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].color = AppColors.disableKeyColor;
          if(!word.contains(_guess[i])){ 
            wrongs.add(_guess[i]);
          }
        }
      }
    }
    
    List<String> res = [];
    for(var i = 0; i < _guess.length; i++){
      if(grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].color == AppColors.letterRight) {
        res.add("2");
      } else if(grid[game!.players.indexWhere((element) => element.name == name)][currentLine][i].color == AppColors.letterPlace) {
        res.add("1");
      } else {
        res.add("0");
      }
    }
    if(game!.players[game!.players.indexWhere((element) => element.name == name)].guesses == null){
      game!.players[game!.players.indexWhere((element) => element.name == name)].guesses = [];
    }
    game!.players[game!.players.indexWhere((element) => element.name == name)].guesses?.add(Guess(word: guess, result: res.join('')));
    repository.updateGame(game!);
    setState(() { });
  }

  Widget getTiles(Tile e, double tileSize) {
    return Positioned(
      left: e.x * tileSize,
      top: e.y * tileSize,
      width: tileSize,
      height: tileSize,
      child: Center(
        child: Container(
          width: tileSize - 1.5 * 2,
          height: tileSize - 1.5 * 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: e.color,
          ),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            child: Center(
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  e.val,
                  style: const TextStyle(
                    color: AppColors.letterColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateStack(tileSize) {
    stackItems = [];
    for(var flatGrids in flattenedGrid)
    {
      if(flatGrids.isNotEmpty)
      {
        List<Widget> items = [];
        items.addAll(flatGrids.map((e) => getTiles(e, tileSize)));
        stackItems.add(items);
      }
    }   
  }

  @override
  Widget build(BuildContext context) {
    double gridWidth = MediaQuery.of(context).size.width*0.47;
    double tileSize = (gridWidth - 1.5 * 2) / wordLen;
    double gridHeight = tileSize*7 + 3;

    if(gridHeight >= MediaQuery.of(context).size.height*0.60) {
      gridHeight = MediaQuery.of(context).size.height*0.60;
      tileSize = (gridHeight - 1.5 * 2) / 7;
      gridWidth = tileSize*wordLen + 3;
    }
    updateStack(tileSize);
     
  
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event) {
        if(event.runtimeType == RawKeyUpEvent){
          String label = event.logicalKey.keyLabel;
          if(label == 'Backspace'){
            _backspace();
          }
          else if(label == 'Enter'){
            _submit();
          }
          else if(label.length == 1){
            if(label.codeUnitAt(0) >= 0x41 && label.codeUnitAt(0) <= 0x5A){ //A to Z
              _insertText(label[0]);
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backColor,
        bottomNavigationBar: CustomKeyboard(
          wrongs: wrongs,
          rights: rights,
          onTextInput: (myText) {
            _insertText(myText);
          },
          onBackspace: () {
            _backspace();
          },
          onSubmit: () {
            _submit();
          },
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height*0.05,
                  left: MediaQuery.of(context).size.width*0.05,
                  right :MediaQuery.of(context).size.width*0.05,
                ),
                height: MediaQuery.of(context).size.height*0.05,
                child: Row(
                  children: [
                    game?.players.indexWhere((element) => element.name == name) == 0 ? AppIcon(iconData: Icons.replay_outlined, onTap: () => resetWord(false)) : const SizedBox(),
                    game?.players.indexWhere((element) => element.name == name) == 0 ? const SizedBox(width: 10) : const SizedBox(),
                    AppIcon(iconData: Icons.book, onTap: () => {}),
                    const SizedBox(width: 10),
                    AppIcon(iconData: Icons.share, onTap: () => {})
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: repository.getDocumentSnap(gameId),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          game = Game.fromSnapshot(snapshot.data!);
                          if(game!.players.indexWhere((element) => element.name == name) == 1 && game!.reset == true)
                          {
                            resetWord(true);
                            game!.reset = false;
                            repository.updateGame(game!);
                          }
                          if(game!.players.firstWhere((element) => element.name != name).guesses != null) {
                            for(int i = 0; i < game!.players.firstWhere((element) => element.name != name).guesses!.length; i++) {
                              for(int j = 0; j < wordLen; j++) {
                                String _res = game!.players.firstWhere((element) => element.name != name).guesses![i].result[j];
                                grid[game!.players.indexWhere((element) => element.name != name)][i][j].color = _res == "2" ? AppColors.letterRight : _res ==  "1" ? AppColors.letterPlace : AppColors.disableKeyColor;
                              }
                            }
                            updateStack(tileSize);
                          } 
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            stackItems.isNotEmpty ?
                            WordGrid(
                              gridWidth: gridWidth,
                              gridHeight: gridHeight,
                              playerName: snapshot.hasData ? game!.players[0].name : "Waiting...",
                              stackItems: stackItems[0],
                              iconColor: snapshot.hasData ? AppColors.letterRight : AppColors.disableKeyColor,
                            ) : const SizedBox(),
                            stackItems.length >= 2 ?
                            WordGrid(
                              gridWidth: gridWidth,
                              gridHeight: gridHeight,
                              playerName: snapshot.hasData && game!.players.length > 1 ? game!.players[1].name : "Waiting...",
                              stackItems: stackItems[1],
                              iconColor: snapshot.hasData && game!.players.length > 1 ? AppColors.letterRight : AppColors.disableKeyColor,
                            ) : const SizedBox(),
                          ],
                        );
                      }
                    ),
                    over == true ?
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                      child: Text(
                        word,
                        style: const TextStyle(
                          color: AppColors.letterColor,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ) : SizedBox(height: MediaQuery.of(context).size.height*0.02),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
