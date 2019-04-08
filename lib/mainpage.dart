import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'mmaobjects.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String statusString = 'Push the button to load MMA Events into Calendar';
  bool checkBoxPressed = false;
  bool queryUFC = true;
  bool queryBellator = true;
  bool queryInvictus = true;

  void _toggleQueryUFC(bool) {
    setState(() {
      queryUFC = bool;
    });
  }

  void _toggleQueryBellator(bool) {
    setState(() {
      queryBellator = bool;
    });
  }

  void _toggleQueryInvictus(bool) {
    setState(() {
      queryInvictus = bool;
    });
  }

  Future _queryMMAWebsite() async {
    //Method to query MMA Events from mmafighting.com

    var client = Client();
    Response response = await client.get('https://www.mmafighting.com/schedule');

    if (response.statusCode != 200){
      //If HTTP OK response is not received, return empty body and let user
      //know if connection error
      setState(() {
        statusString = 'Error Connecting to Network';
      });
      return response.body;
    }

    var document = parse(response.body);

    //Get Dates (Dates all have H3 headers)
    var eventDate = document.querySelectorAll('h3');
    var eventDateIterator = eventDate.iterator;

    //Get Fights and Event Titles
    //Event titles all contain 'fight-card' in link HREF attribute
    //Fights all contain '/fight/' in the link HREF attribute
    var fightLinks = document.querySelectorAll('a');
    var fightString = new StringBuffer('');

    List<MMAEvent> mmaEvents = [];

    for(var link in fightLinks){
      String title = link.text;
      String href = link.attributes['href'];
      if(href != null && href.contains('fight-card')){
        //fightString.write('\nFight Card : ' + title + '\n');
        var mmaEvent = new MMAEvent(title);
        mmaEvents.add(mmaEvent);
        if(eventDateIterator.moveNext()){
          mmaEvent.addDate(eventDateIterator.current.text);
          //fightString.write('Date: ' + eventDateIterator.current.text + '\n');
        }
      } else if(href != null && href.contains('/fight/')){
        mmaEvents.elementAt(mmaEvents.length - 1).addFight(title);
        //fightString.write('Fight: ' + title + '\n');
      }
    }

    for(var mmaEvent in mmaEvents){
      fightString.write(mmaEvent.toString());
    }

    setState(() {
      statusString = fightString.toString();
    });
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CheckboxListTile(
                    value: queryUFC,
                    title: const Text('UFC'),
                    onChanged: _toggleQueryUFC),
                CheckboxListTile(
                    value: queryBellator,
                    title: const Text('Bellator'),
                    onChanged: _toggleQueryBellator),
                CheckboxListTile(
                    value: queryInvictus,
                    title: const Text('Invictus'),
                    onChanged: _toggleQueryInvictus),
              ],
            ),
            new Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    statusString,
                  ),
                ),
            ),
            FloatingActionButton(
              onPressed: () {
                _queryMMAWebsite();
              },
            ),
          ],
        ),
      ),
    );
  }
}
