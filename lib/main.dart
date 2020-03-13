import 'package:flutter/material.dart';
import 'screens/home.dart';

main(List<String> args) => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Late Count',
      home: HomeExtended(),
    );
  }
}
