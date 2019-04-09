import 'package:flutter/material.dart';
import 'mainpage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MMA Calendar App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        unselectedWidgetColor: Colors.white,
        primaryColor: const Color(0xff666680),
        accentColor: Colors.amber[600],
        canvasColor: const Color(0xff515161),
        brightness: Brightness.light,

        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          body1: TextStyle(fontSize: 15.0, fontFamily: 'Hind', color: Colors.white),
          body2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold,fontFamily: 'Hind', color: Colors.white),
          subhead: TextStyle(fontSize: 15.0, fontFamily: 'Hind', color:const Color(0xff979799)),
        ),
      ),
      home: MainPage(title: 'MMA Calendar'),
    );
  }
}

