import 'package:flutter/cupertino.dart';
import 'homepage.dart';

// TODO: add a checker to see if the exercise already exists
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color.fromARGB(255, 173, 15, 226);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CupertinoApp(
        title: 'My Gym Tracker App',
        home: MyHomePage(),
        theme: CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: primaryColor,
        ),
      ),
    );
  }
}
