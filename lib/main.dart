import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wordle/pages/login_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:wordle/utils/app_colors.dart';

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
    final ThemeData theme = ThemeData();
    return GetMaterialApp(
      title: 'Word x Word',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: AppColors.letterRight,
        )
      ),
      home: const LoginPage(),
    );
  }
}
