import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wordle/main_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
    await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCtce2OebRZDk6cE-XsOPsXMpcJgMw7gFQ",
      appId: "1:707137472833:web:d8b3056eec3933835639c0",
      messagingSenderId: "707137472833",
      projectId: "wordvsword-ba8ef"
    ),
  );
  } else {
    await Firebase.initializeApp();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      title: 'Word x Word',
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
