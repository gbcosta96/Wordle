import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'customKeyboard.dart';


const Color letterColor = Colors.white;
const Color disableLetterColor = Color(0xffb8b8b8);

const Color keysColor = Color.fromARGB(255, 0x76, 0x6d, 0x70);
const Color disableKeyColor = Color.fromARGB(255, 0x38, 0x34, 0x36);

const Color backColor = Color.fromARGB(255, 0x29, 0x28, 0x28);
const Color letterNeutral = Color.fromARGB(255, 0x8f, 0x88, 0x8a);
const Color letterPlace = Color.fromARGB(255, 0xcd, 0xa5, 0x5e);
const Color letterRight = Color.fromARGB(255, 0x2a, 0x89, 0x7b);


void main() {
  runApp(const PasswordApp());
}

class Tile{
  final int x;
  final int y;
  String val;
  Color color;

  Tile(this.x, this.y, this.val, this.color);
}


class PasswordApp extends StatelessWidget {
  const PasswordApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SENHA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Password(),
    );
  }
}

class Password extends StatefulWidget {
  const Password({Key? key}) : super(key: key);
  @override
  PasswordState createState() => PasswordState();
}


class PasswordState extends State<Password> {
  int gridLen = 0;
  FocusNode myFocusNode = FocusNode();
  late List<List<Tile>> grid;
  late Iterable<Tile> flattenedGrid = [];
  late List<String> wrongs = [];
  late String guess = '';
  late String word;
  int currentLine = 0;
  bool over = false;

  Future<String> _read() async {
    String text = '';
    try {
      text = await rootBundle.loadString('assets/words.txt');
      /*final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/assets/words.txt');
      text = await file.readAsString();*/
    } catch (e) {
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
    List<String> lstStr = fileText.split('\n');
    word = lstStr[rdm.nextInt(lstStr.length)].trim();
    setState(() {
      gridLen = word.length;
      grid = List.generate(gridLen, (y) => List.generate(gridLen, (x) => Tile(x, y, " ", letterNeutral)));
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
      _verifyWord();
      if(currentLine < gridLen - 1){
        currentLine++;
        guess = '';
      }
      else{
        over = true;
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
        grid[currentLine][i].color = letterRight;
        _word[i] = "#";
      }
    }
    for(var i = 0; i < _guess.length; i++){
      if(grid[currentLine][i].color == letterNeutral){
        if(_word.contains(_guess[i])){
          _word.remove(_guess[i]);
          grid[currentLine][i].color = letterPlace;
        }
        else{
          grid[currentLine][i].color = disableKeyColor;
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
    double gridSize = MediaQuery.of(context).orientation == Orientation.portrait ? 
                      MediaQuery.of(context).size.width*0.9 : MediaQuery.of(context).size.height*0.40;
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
                    color: letterColor,
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
        backgroundColor: backColor,
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
              const SizedBox(height: 35),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.9,
                height: MediaQuery.of(context).orientation == Orientation.portrait ? 
                          MediaQuery.of(context).size.height*0.10 : MediaQuery.of(context).size.height*0.15,
                child: const Text(
                  "Adivinhe a palavra\n" + 
                  "Cor verde significa letra certa no lugar certo\n" + 
                  "Cor amarela significa letra certa no lugar errado\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: letterColor,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(
                width: gridSize,
                height: MediaQuery.of(context).orientation == Orientation.portrait ? 
                          MediaQuery.of(context).size.height*0.05 : MediaQuery.of(context).size.height*0.08,
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: letterColor,
                    backgroundColor: letterRight,
                  ),
                  onPressed: () {asyncInit();},
                  child: const Text('Nova Palavra')
                ),
              ),
              SizedBox(height: MediaQuery.of(context).orientation == Orientation.portrait ? 20 : 10),
              Container(
                width: gridSize,
                height: gridSize,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: backColor,
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
                    color: letterColor,
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
