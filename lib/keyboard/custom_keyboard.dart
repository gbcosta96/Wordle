import 'package:flutter/material.dart';
import 'package:wordle/keyboard/submit_key.dart';
import 'package:wordle/keyboard/textKey.dart';

import 'backspace_key.dart';


class CustomKeyboard extends StatefulWidget {
  const CustomKeyboard({
    Key? key,
    required this.wrongs,
    required this.rights,
    required this.onTextInput,
    required this.onBackspace,
    required this.onSubmit
  }) : super(key: key);
  final List<String> wrongs;
  final List<String> rights;
  final ValueSetter<String> onTextInput;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard> {
  final List<String> row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  final List<String> row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  final List<String> row3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];
  void _textInputHandler(String text) => widget.onTextInput.call(text);
  void _backspaceHandler() => widget.onBackspace.call();
  void _submitHandler() => widget.onSubmit.call();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.27,
      padding: const EdgeInsets.only(
        left: 6.0,
        right: 6.0,
        bottom: 3.0,
      ),
      child: Column(        // <-- Column
        children: [
          buildRowOne(),    // <-- Row
          buildRowTwo(),    // <-- Row
          buildRowThree(),    // <-- Row
        ],
      ),
    );
  }

  Expanded buildRowOne() {
    return Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).orientation == Orientation.portrait ? 
                MediaQuery.of(context).size.width : MediaQuery.of(context).size.width*0.5,
        child: Row(
          children: [
            for (var letter in row1) 
            TextKey(
              text: letter,
              onTextInput: _textInputHandler,
              wrong: widget.wrongs.contains(letter),
              right: widget.rights.contains(letter),
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildRowTwo() {
    return Expanded(
      child: SizedBox(
        width: MediaQuery.of(context).orientation == Orientation.portrait ? 
                MediaQuery.of(context).size.width : MediaQuery.of(context).size.width*0.5,
        child: Row(
          children: [
            for (var letter in row2) 
            TextKey(
              text: letter,
              onTextInput: _textInputHandler,
              wrong: widget.wrongs.contains(letter),
              right: widget.rights.contains(letter),
            ),
            BackspaceKey(
              onBackspace: _backspaceHandler,
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildRowThree() {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).orientation == Orientation.portrait ? 
                MediaQuery.of(context).size.width : MediaQuery.of(context).size.width*0.5,
        child: Row(
          children: [
            for (var letter in row3) 
            TextKey(
              text: letter,
              onTextInput: _textInputHandler,
              wrong: widget.wrongs.contains(letter),
              right: widget.rights.contains(letter),
            ),
            SubmitKey(
              flex: 3,
              onSubmit: _submitHandler,
            ),
          ],
        ),
      ),
    );
  }
}