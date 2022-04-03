import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle/models/game.dart';
import 'package:wordle/models/guess.dart';
import 'package:wordle/models/player.dart';
import 'package:wordle/repository/data_repository.dart';
import 'package:wordle/utils/app_colors.dart';
import 'package:wordle/utils/dimensions.dart';
import 'package:wordle/widgets/app_icon.dart';
import 'package:wordle/widgets/app_text.dart';
import 'package:wordle/widgets/keyboard/custom_keyboard.dart';
import 'package:wordle/models/tile.dart';
import 'package:wordle/widgets/word_grid.dart';


class MainPage extends StatefulWidget {
  final String roomId;
  final String playerName;
  const MainPage({Key? key, required this.roomId, required this.playerName}) : super(key: key);
  @override
  MainPageState createState() => MainPageState();
}


class MainPageState extends State<MainPage> {
  final int kPlayers = 4;
  final FocusNode myFocusNode = FocusNode();
  final DataRepository repository = DataRepository();

  double? gridWidth, gridHeight, tileSize;

  List<String> wrongLetters = [];
  List<String> rightLetters = [];

  List<List<List<Tile>>> grids = [];
  List<Iterable<Tile>> flattenedGrids = [];
  List<List<Widget>> tiles = [];
  Game? game;
  List<Player> players = [];
  List<Guess> guesses = [];

  late List<int> rowPerPlayer;
                                  
  late List<String> possibleWords;
  late String guess;
  
  bool over = false;
  late StreamSubscription<DocumentSnapshot> subsGame;
  late StreamSubscription<QuerySnapshot> subsPlayer;
  late StreamSubscription<QuerySnapshot> subsGuess;
  
  
  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async{
    possibleWords = await repository.loadPossibleWords();
    game = await repository.getGame(widget.roomId);
    resetWord(false);
    
    subsGame = repository.getGameSnap(widget.roomId).listen((event) { 
      Map<String, dynamic> data = event.data() as Map<String, dynamic>;
      if(data['word'] != game!.word && playerPos(widget.playerName) != 0){
        resetWord(false);
      } 
    });

    subsPlayer = repository.getPlayersSnap(widget.roomId).listen((event) { 
      setState(() {
        players = repository.playersFromSnap(event.docs);
      });
    });

    subsGuess = repository.getGuessesSnap(widget.roomId).listen((event) {
      guesses = repository.guessesFromSnap(event.docs);
      loadGuesses();
      
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    subsGame.cancel();
    subsPlayer.cancel();
    subsGame.cancel();
    super.dispose();
  }

  void resetWord(bool newWord) async {
    over = false;

    rightLetters = [];
    wrongLetters = [];    
    guess = '';
    rowPerPlayer = List.generate(kPlayers, (index) => 0);

    if(newWord){
      Random rdm = Random();
      String word = possibleWords[rdm.nextInt(possibleWords.length)].trim();
      await repository.newWord(widget.roomId, word);
    }

    game = await repository.getGame(widget.roomId);
    players = await repository.getPlayers(widget.roomId);
    guesses = await repository.getGuesses(widget.roomId);
        
    grids = List.generate(kPlayers, (player) =>
            List.generate(game!.word.length + 2, (y) =>
              List.generate(game!.word.length, (x) =>
                Tile(x, y, " ", AppColors.letterNeutral)
              )
            )
          );
          
    flattenedGrids = [];
    for(var _grid in grids){
      flattenedGrids.add(_grid.expand((e) => e));
    }

    loadGuesses();

    setState(() {});
  }

  int playerPos(String name) {
    return players.indexWhere((element) => element.name == name);
  }

  Player getPlayer(String name){
    return players.firstWhere((element) => element.name == name);
  }

  void loadGuesses() {
    rowPerPlayer = List.generate(kPlayers, (index) => 0);
      for(Guess _guess in guesses) {
        for(int i = 0; i < game!.word.length; i++) {
          String _res = _guess.result[i];
          if(grids.isNotEmpty) {
            grids[playerPos(_guess.player)][rowPerPlayer[playerPos(_guess.player)]][i].color = 
              _res == "2" ? AppColors.letterRight : _res ==  "1" ? AppColors.letterPlace : AppColors.disableKeyColor;
            if(_guess.player == widget.playerName) {
              grids[playerPos(_guess.player)][rowPerPlayer[playerPos(_guess.player)]][i].val = _guess.word[i];
            }
          }
        }
        rowPerPlayer[playerPos(_guess.player)]++;
      }
      setState(() {});
  }

  void _insertText(String text){
    if(guess.length < game!.word.length && over == false){
      guess += text;
      _loadText();
    }
  }

  void _backspace(){
    if(guess.isNotEmpty){
      guess = guess.substring(0, guess.length - 1);
      _loadText();
    }
  }

  void _loadText() {
    int index = 0;
    for (; index < guess.length; index++) {
      grids[playerPos(widget.playerName)][rowPerPlayer[playerPos(widget.playerName)]][index].val = guess[index];
    }
    for(; index < game!.word.length; index++){
      grids[playerPos(widget.playerName)][rowPerPlayer[playerPos(widget.playerName)]][index].val = ' ';
    }
    setState(() {});
  }

  void _submit(){
    if (guess.length == game!.word.length){
      if (possibleWords.indexWhere((element) => element.trim() == guess) >= 0) {
        _verifyWord();
        if (rowPerPlayer[playerPos(widget.playerName)] < (game!.word.length + 2)) {
          guess = '';
        }
        else {
          over = true;
        }
        _loadText();
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
    if(guess == game!.word){
      over = true;
    }

    List<String> _guess = guess.split('');
    List<String> _word = game!.word.split('');
    List<String> _result = List.generate(game!.word.length, (index) => '0');
    
    for(var i = 0; i < _guess.length; i++) {
      if(_guess[i] == _word[i]){
        rightLetters.add(_guess[i]);
        _word[i] = "#";
        _result[i] = "2";
      }
    }
    for(var i = 0; i < _guess.length; i++){
      if(_result[i] == "0"){
        if(_word.contains(_guess[i])) {
          _word.remove(_guess[i]);
          _result[i] = "1";
        }
        else if(!game!.word.contains(_guess[i])) {
            wrongLetters.add(_guess[i]);
        }
      }
    }

    Guess newGuess = Guess(
      player: widget.playerName,
      result: _result.join(''),
      word: guess,
    );
    
    repository.addGuess(widget.roomId, newGuess);
    //setState(() { });
  }

  Widget widgetTile(Tile e, double tileSize) {
    return Positioned(
      left: e.x * tileSize,
      top: e.y * tileSize,
      width: tileSize,
      height: tileSize,
      child: Center(
        child: Container(
          width: tileSize - Dimensions.smallest(Dimensions.innerGridPadding) * 2,
          height: tileSize - Dimensions.smallest(Dimensions.innerGridPadding) * 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.smallest(Dimensions.innerGridRadius)),
            color: e.color,
          ),
          child: Container(
            padding: EdgeInsets.all(Dimensions.smallest(Dimensions.innerGridPadding)),
            child: Center(
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: AppText(text: e.val, size: 50),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateTiles() {
    tiles = [];
    if(game != null) {
      gridWidth = Dimensions.width(players.length >= 3 && MediaQuery.of(context).orientation == Orientation.landscape ?
      Dimensions.gridMaxWidth4 : Dimensions.gridMaxWidth);
      tileSize = (gridWidth! - Dimensions.gridPadding * 2) / game!.word.length;
      gridHeight = tileSize!*(game!.word.length + 2) + (Dimensions.gridPadding * 2);

      if(gridHeight! >= Dimensions.height(players.length >= 3 && MediaQuery.of(context).orientation == Orientation.portrait ?
        Dimensions.gridMaxHeight4 : Dimensions.gridMaxHeight)) {
        gridHeight = Dimensions.height(players.length >= 3 && MediaQuery.of(context).orientation == Orientation.portrait ?
          Dimensions.gridMaxHeight4 : Dimensions.gridMaxHeight);
        tileSize = (gridHeight! - Dimensions.gridPadding * 2) / (game!.word.length + 2);
        gridWidth = tileSize!*game!.word.length + (Dimensions.gridPadding * 2);
      }
    
      for(var _flatGrid in flattenedGrids)
      {
        if(_flatGrid.isNotEmpty)
        {
          List<Widget> items = [];
          items.addAll(_flatGrid.map((e) => widgetTile(e, tileSize!)));
          tiles.add(items);
        }
      }  
    }
  }

  @override
  Widget build(BuildContext context) {
    updateTiles();
    
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
          wrongs: wrongLetters,
          rights: rightLetters,
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
                  top: Dimensions.height(Dimensions.headerMarginHeight),
                  left: Dimensions.width(Dimensions.headerMarginWidth),
                  right : Dimensions.width(Dimensions.headerMarginWidth),
                ),
                height: Dimensions.height(Dimensions.headerHeight),
                child: Row(
                  children: [
                    playerPos(widget.playerName) == 0 ? AppIcon(iconData: Icons.replay_outlined, onTap: () => resetWord(true)) : const SizedBox(),
                    playerPos(widget.playerName) == 0 ? SizedBox(width: Dimensions.width(Dimensions.iconSeparatorWidth)) : const SizedBox(),
                    AppIcon(iconData: Icons.book, onTap: () => {}),
                    SizedBox(width: Dimensions.width(Dimensions.iconSeparatorWidth)),
                    AppIcon(iconData: Icons.share, onTap: () => {})
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    game == null || gridHeight == null || gridWidth == null ? const CircularProgressIndicator() : 
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (tiles.isNotEmpty)
                            WordGrid(
                              gridWidth: gridWidth!,
                              gridHeight: gridHeight!,
                              playerName: players[0].name,
                              stackItems: tiles[0],
                              iconColor: AppColors.letterRight,
                            ),
                            if(tiles.length > 1)
                            WordGrid(
                              gridWidth: gridWidth!,
                              gridHeight: gridHeight!,
                              playerName: players.length > 1 ? players[1].name : "Waiting...",
                              stackItems: tiles[1],
                              iconColor: players.length > 1 ? AppColors.letterRight : AppColors.disableKeyColor,
                            ),
                            if (MediaQuery.of(context).orientation == Orientation.landscape && players.length >= 3 && tiles.length > 2)
                            WordGrid(
                              gridWidth: gridWidth!,
                              gridHeight: gridHeight!,
                              playerName: players[2].name,
                              stackItems: tiles[2],
                              iconColor: AppColors.letterRight,
                            ),
                            if (MediaQuery.of(context).orientation == Orientation.landscape && players.length >= 4 && tiles.length > 3)
                            WordGrid(
                              gridWidth: gridWidth!,
                              gridHeight: gridHeight!,
                              playerName: players[3].name,
                              stackItems: tiles[3],
                              iconColor: AppColors.letterRight,
                            ),
                          ],
                        ),
                        if (MediaQuery.of(context).orientation == Orientation.portrait && players.length >= 3 && tiles.length > 2)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            WordGrid(
                              gridWidth: gridWidth!,
                              gridHeight: gridHeight!,
                              playerName: players[2].name,
                              stackItems: tiles[2],
                              iconColor: AppColors.letterRight,
                            ),
                            if (players.length >= 4 && tiles.length > 3)
                            WordGrid(
                              gridWidth: gridWidth!,
                              gridHeight: gridHeight!,
                              playerName: players[3].name,
                              stackItems: tiles[3],
                              iconColor: AppColors.letterRight,
                            ),
                          ],
                        ),
                      ],
                    ),
                    over == true ?
                    SizedBox(
                      height: Dimensions.height(Dimensions.wordSize),
                      child: AppText(text: game!.word),
                    ) : SizedBox(height: Dimensions.height(Dimensions.wordSize)),
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
