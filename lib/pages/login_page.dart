import 'package:flutter/material.dart';
import 'package:wordle/models/game.dart';
import 'package:wordle/models/player.dart';
import 'package:wordle/pages/main_page.dart';
import 'package:wordle/repository/data_repository.dart';
import 'package:wordle/utils/app_colors.dart';
import 'package:wordle/utils/dimensions.dart';
import 'package:wordle/widgets/app_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FocusNode myFocusNode = FocusNode();
  final DataRepository repository = DataRepository();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerRoom= TextEditingController();
  
  Widget _inputField(Icon prefixIcon, String hintText, bool isPassword, TextEditingController controller) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      margin: EdgeInsets.only(bottom: Dimensions.height(Dimensions.loginSpacingHeight)),
      child: TextField(
        controller: controller,
        maxLength: 12,
        obscureText: isPassword,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.backColor,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.inputPaddingHeight),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.inputHint,
          ),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: prefixIcon,
          prefixIconConstraints: BoxConstraints(
            minWidth: Dimensions.width(Dimensions.inputPrefixWidth),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void putSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      )
    );
  }

  void joinRoom() {
    repository.checkGame(controllerRoom.text).then((doc) {
      if(doc) {
        repository.getGame(controllerRoom.text).then((game) {
          if(game.players.length < 4) {
            if(!game.players.any((player) => player.name == controllerName.text)) {
              game.players.add(Player(name: controllerName.text));
              repository.updateGame(game);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                  MainPage(
                    playerName: controllerName.text,
                    roomId: controllerRoom.text,
                    newWord: false,
                  ),
                )
              );
            }
            else {
              putSnack("Name taken!");
            }
          }
          else {
            putSnack("Room is full!");
          }
        });
      }
      else {
        putSnack("Room doesn't exists!");
      }
    });
  }

  void createRoom() {
    repository.checkGame(controllerRoom.text).then((value) {
      if(!value) {
        Game game = Game(players: [Player(name: controllerName.text)], word: 'WORD');
        repository.addGame(game, controllerRoom.text);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
            MainPage(
              playerName: controllerName.text,
              roomId: controllerRoom.text,
              newWord: true,
            ),
          )
        );
      }
      else {
        putSnack("Room already exists!");
      }
    });
  }

  void test() {
    repository.test('sala1');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: Center(
        child: SizedBox(
          width: Dimensions.width(MediaQuery.of(context).orientation == Orientation.portrait ?
              Dimensions.loginWidth : Dimensions.loginLandscapingWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppText(text: "Word vs Word", size: 40),
              SizedBox(height: Dimensions.height(Dimensions.loginSpacingHeight)),
              _inputField(const Icon(Icons.person), "Name", false, controllerName),
              _inputField(const Icon(Icons.person), "Room Name", false, controllerRoom),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      createRoom();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.buttonPaddingHeight),
                      color: AppColors.letterRight,
                      child: const Center(child:  AppText(text: "Create room")),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      joinRoom();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.buttonPaddingHeight),
                      color: AppColors.letterRight,
                      child: const Center(child:  AppText(text: "Join room")),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}