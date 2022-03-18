import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordle/constants/app_colors.dart';
import 'package:wordle/custom_keyboard.dart';
import 'package:wordle/tile.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  MainPageState createState() => MainPageState();
}


class MainPageState extends State<MainPage> {
  int gridLen = 0;
  FocusNode myFocusNode = FocusNode();
  late List<List<Tile>> grid;
  late Iterable<Tile> flattenedGrid = [];
  late List<String> wrongs = [];
  late String guess = '';
  late String word;
  int currentLine = 0;
  bool over = false;
  late List<String> lstStr;

  Future<String> _read() async {
    String text = '';
    try {
      text = await rootBundle.loadString('assets/words.txt');
    } 
    catch (e) {
    }
    return text;
  }
  
  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async{
    String fileText = await _read();
    Random rdm = Random();
    currentLine = 0;
    guess = '';
    wrongs = [];
    over = false;
    lstStr = fileText.split('\n');
    word = lstStr[rdm.nextInt(lstStr.length)].trim();
    setState(() {
      gridLen = word.length;
      grid = List.generate(gridLen, (y) => List.generate(gridLen, (x) => Tile(x, y, " ", AppColors.letterNeutral)));
      flattenedGrid = grid.expand((e) => e);
    });
    
  }

  void _insertText(String text){
    if(guess.length < gridLen && over == false){
      guess += text;
      setState(() {
        for(var i = 0; i < gridLen; i++){
          grid[currentLine][i].val = ' ';
        }
        for(var i = 0; i < guess.length; i++){
          grid[currentLine][i].val = guess[i];
        }
      });
    }
  }

  void _backspace(){
    if(guess.isNotEmpty){
      guess = guess.substring(0, guess.length - 1);
      setState(() {
        for(var i = 0; i < gridLen; i++){
          grid[currentLine][i].val = ' ';
        }
        for(var i = 0; i < guess.length; i++){
          grid[currentLine][i].val = guess[i];
        }
      });
    }
  }

  void _submit(){
    if(guess.length == gridLen){
      bool checkPossible = false;
      for(String possibleWords in lstStr){
        if(possibleWords.trim() == guess){
          checkPossible = true;
          break;
        }
      }
      if(checkPossible == true){
        _verifyWord();
        if(currentLine < gridLen - 1){
          currentLine++;
          guess = '';
        }
        else{
          over = true;
        }
      }
      else{
        guess = '';
        setState(() {
          for(var i = 0; i < gridLen; i++){
            grid[currentLine][i].val = ' ';
          }
          for(var i = 0; i < guess.length; i++){
            grid[currentLine][i].val = guess[i];
          }
        });
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
        grid[currentLine][i].color = AppColors.letterRight;
        _word[i] = "#";
      }
    }
    for(var i = 0; i < _guess.length; i++){
      if(grid[currentLine][i].color == AppColors.letterNeutral){
        if(_word.contains(_guess[i])){
          _word.remove(_guess[i]);
          grid[currentLine][i].color = AppColors.letterPlace;
        }
        else{
          grid[currentLine][i].color = AppColors.disableKeyColor;
          if(!word.contains(_guess[i])){ 
            wrongs.add(_guess[i]);
          }
        }
      }
    }
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    double gridSize = min(MediaQuery.of(context).size.width*0.8, MediaQuery.of(context).size.height*0.50);
    double tileSize = (gridSize - 2.5 * 2) / gridLen;
    List<Widget> stackItems = [];
    if(flattenedGrid.isNotEmpty)
    {
      stackItems.addAll(flattenedGrid.map((e) => Positioned(
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
            child: Center(
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  e.val,
                  style: const TextStyle(
                    color: AppColors.letterColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      )));
    }
  
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.05),
              SizedBox(
                width: gridSize,
                height: MediaQuery.of(context).orientation == Orientation.portrait ? 
                          MediaQuery.of(context).size.height*0.05 : MediaQuery.of(context).size.height*0.08,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: AppColors.letterColor,
                    backgroundColor: AppColors.letterRight,
                  ),
                  onPressed: () {asyncInit();},
                  child: const Text('Nova Palavra')
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.05),
              Container(
                width: gridSize,
                height: gridSize,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColors.backColor,
                ),
                child: Stack(
                    children: stackItems,
                ),
              ),
              over == true ?
              SizedBox(
                height: 20,
                child: Text(
                  word,
                  style: const TextStyle(
                    color: AppColors.letterColor,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ) : const SizedBox(),            
            ],
          ),
        ),
      ),
    );
  }
}
