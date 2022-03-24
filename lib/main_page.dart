import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle/models/game.dart';
import 'package:wordle/models/guess.dart';
import 'package:wordle/repository/data_repository.dart';
import 'package:wordle/utils/app_colors.dart';
import 'package:wordle/utils/dimensions.dart';
import 'package:wordle/widgets/app_icon.dart';
import 'package:wordle/widgets/keyboard/custom_keyboard.dart';
import 'package:wordle/models/tile.dart';
import 'package:wordle/widgets/word_grid.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  MainPageState createState() => MainPageState();
}


class MainPageState extends State<MainPage> {
  final int kPlayers = 2;
  final FocusNode myFocusNode = FocusNode();
  final DataRepository repository = DataRepository();

  double? gridWidth, gridHeight, tileSize;

  List<String> wrongLetters = [];
  List<String> rightLetters = [];

  List<List<List<Tile>>> grids = [];
  List<Iterable<Tile>> flattenedGrids = [];
  List<List<Widget>> tiles = [];
  Game? game;

  late List<String> possibleWords;
  late String guess;
  
  bool over = false;
  
  String gameId = "6TfrtZAHSH6qp1jljkr3";
  String name = "gbcosta96";

  
  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async{
    possibleWords = await repository.loadPossibleWords();
    game = await repository.getGame(gameId);
    resetWord(false);
  }

  void resetWord(bool newWord) async {
    
    over = false;

    rightLetters = [];
    wrongLetters = [];

    guess = '';
    game = await repository.getGame(gameId);

    if(newWord){
      Random rdm = Random();
      game!.word = possibleWords[rdm.nextInt(possibleWords.length)].trim();
      game!.players[0].guesses = null;
      game!.players[1].guesses = null;
      game!.reset = true;
      await repository.updateGame(game!);
    }
        
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

    setState(() {});
  }

  void _insertText(String text){
    if(guess.length < game!.word.length && over == false){
      guess += text;
      setState(() {
        for(var i = 0; i < game!.word.length; i++){
          grids[game!.playerPos(name)][game!.players[game!.playerPos(name)].guesses?.length ?? 0][i].val = ' ';
        }
        for(var i = 0; i < guess.length; i++){
          grids[game!.playerPos(name)][game!.players[game!.playerPos(name)].guesses?.length ?? 0][i].val = guess[i];
        }
      });
    }
  }

  void _backspace(){
    if(guess.isNotEmpty){
      guess = guess.substring(0, guess.length - 1);
      setState(() {
        for(var i = 0; i < game!.word.length; i++){
          grids[game!.playerPos(name)][game!.players[game!.playerPos(name)].guesses?.length ?? 0][i].val = ' ';
        }
        for(var i = 0; i < guess.length; i++){
          grids[game!.playerPos(name)][game!.players[game!.playerPos(name)].guesses?.length ?? 0][i].val = guess[i];
        }
      });
    }
  }

  void _submit(){
    if(guess.length == game!.word.length){
      if(possibleWords.indexWhere((element) => element.trim() == guess) >= 0) {
        _verifyWord();
        if((game!.players[game!.playerPos(name)].guesses?.length ?? 0) < (game!.word.length + 2)){
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
    if(guess == game!.word){
      over = true;
    }

    List<String> _guess = guess.split('');
    List<String> _word = game!.word.split('');
    List<String> _result = List.generate(game!.word.length, (index) => '0');
    
    for(var i = 0; i < _guess.length; i++){
      if(_guess[i] == _word[i]){
        rightLetters.add(_guess[i]);
        _word[i] = "#";
        _result[i] = "2";
      }
    }
    for(var i = 0; i < _guess.length; i++){
      if(_result[i] == "0"){
        if(_word.contains(_guess[i])){
          _word.remove(_guess[i]);
          _result[i] = "1";
        }
        else{
            wrongLetters.add(_guess[i]);
        }
      }
    }
    
    if(game!.players[game!.playerPos(name)].guesses == null){
      game!.players[game!.playerPos(name)].guesses = [];
    }
    game!.players[game!.playerPos(name)].guesses?.add(Guess(word: guess, result: _result.join('')));
    repository.updateGame(game!);
    setState(() { });
  }

  Widget widgetTile(Tile e, double tileSize) {
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

  void updateTiles() {
    tiles = [];
    if(game != null) {
      gridWidth = Dimensions.width(Dimensions.gridMaxWidth);
      tileSize = (gridWidth! - Dimensions.gridPadding * 2) / game!.word.length;
      gridHeight = tileSize!*(game!.word.length + 2) + (Dimensions.gridPadding * 2);

      if(gridHeight! >= Dimensions.height(Dimensions.gridMaxHeight)) {
        gridHeight = Dimensions.height(Dimensions.gridMaxHeight);
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
                  bottom: Dimensions.height(Dimensions.headerMarginHeight),
                  left: Dimensions.width(Dimensions.headerMarginWidth),
                  right : Dimensions.width(Dimensions.headerMarginWidth),
                ),
                height: Dimensions.height(Dimensions.headerHeight),
                child: Row(
                  children: [
                    game?.playerPos(name) == 0 ? AppIcon(iconData: Icons.replay_outlined, onTap: () => resetWord(true)) : const SizedBox(),
                    game?.playerPos(name) == 0 ? SizedBox(width: Dimensions.width(Dimensions.iconSeparatorWidth)) : const SizedBox(),
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
                    StreamBuilder<DocumentSnapshot>(
                      stream: repository.getDocumentSnap(gameId),
                      builder: (context, snapshot) {
                        if(snapshot.hasData) {
                          game = Game.fromSnapshot(snapshot.data!);
                          if(game!.playerPos(name) == 1 && game!.reset == true)
                          {
                            resetWord(false);
                            game!.reset = false;
                            repository.updateGame(game!);
                          }
                          for(int player = 0; player < kPlayers; player++) {
                            if(game!.players[player].guesses != null) {
                              for(int i = 0; i < game!.players[player].guesses!.length; i++) {
                                for(int j = 0; j < game!.word.length; j++) {
                                  String _res = game!.players[player].guesses![i].result[j];
                                  if(grids.isNotEmpty) {
                                    grids[player][i][j].color = _res == "2" ? AppColors.letterRight : _res ==  "1" ? AppColors.letterPlace : AppColors.disableKeyColor;
                                    if(player == game!.playerPos(name)) {
                                      grids[player][i][j].val = game!.players[player].guesses![i].word[j];
                                    }
                                  }
                                  
                                }
                              }
                            }
                            updateTiles();
                          }
                        }

                        return game == null || gridHeight == null || gridWidth == null ? const CircularProgressIndicator() : 
                          Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            tiles.isNotEmpty ?
                            WordGrid(
                              gridWidth: gridWidth!,
                              gridHeight: gridHeight!,
                              playerName: game!.players[0].name,
                              stackItems: tiles[0],
                              iconColor: AppColors.letterRight,
                            ) : const SizedBox(),
                            tiles.length >= 2 ?
                            WordGrid(
                              gridWidth: gridWidth!,
                              gridHeight: gridHeight!,
                              playerName: game!.players.length > 1 ? game!.players[1].name : "Waiting...",
                              stackItems: tiles[1],
                              iconColor: game!.players.length > 1 ? AppColors.letterRight : AppColors.disableKeyColor,
                            ) : const SizedBox(),
                          ],
                        );
                      }
                    ),
                    over == true ?
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.02,
                      child: Text(
                        game!.word,
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
