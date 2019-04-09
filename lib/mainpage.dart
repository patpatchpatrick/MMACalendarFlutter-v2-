import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'mmaobjects.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:mma_calendar_flutter/calendarpage.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  // Main Page (Stateful)

  // Page title
  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String statusString =
      'Push the button to load MMA Events into Calendar'; //Status displayed to user
  bool queryUFC = true;
  bool queryBellator = true;
  bool queryInvictaFC = true;
  bool queryPFL = true;
  bool queryOneFC = true;
  bool calendarSelected = false;
  String _currentCalendarID = '';
  DeviceCalendarPlugin _deviceCalendarPlugin = new DeviceCalendarPlugin();

  void setCalendarIDCallback(String calendarID, String calendarName) {
    setState(() {
      _currentCalendarID = calendarID;
      statusString = calendarID + calendarName;
      calendarSelected = false;
    });
  }

  Widget buttonOrNot(){
    if (!calendarSelected){
      return new IconButton(icon: Icon(Icons.calendar_today),
          onPressed: () {
        setState(() {
          calendarSelected = true;
        });
          }
      );
    } else {
      return new CalendarPage(this.setCalendarIDCallback);
    }
  }

  void setDeviceCalendarCallback(DeviceCalendarPlugin deviceCalendar){
    setState(() {
      _deviceCalendarPlugin = deviceCalendar;
    });
  }

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

  void _toggleQueryInvictaFC(bool) {
    setState(() {
      queryInvictaFC = bool;
    });
  }

  void _toggleQueryPFL(bool) {
    setState(() {
      queryPFL = bool;
    });
  }

  void _toggleQueryOneFC(bool) {
    setState(() {
      queryOneFC = bool;
    });
  }

  void _queryMMAWebsite() {
    if (queryUFC) {
      _queryAndParseMMAWebsite('ufc');
    }
    if (queryBellator) {
      _queryAndParseMMAWebsite('bellator');
    }
    if (queryInvictaFC) {
      _queryAndParseMMAWebsite('invicta-fc');
    }
    if (queryOneFC) {
      _queryAndParseMMAWebsite('one-fc');
    }
    if (queryPFL) {
      _queryAndParseMMAWebsite('pfl');
    }
  }

  Future _queryAndParseMMAWebsite(String eventType) async {
    //Method to query mmafighting.com parse data for upcoming MMA Events
    //eventType can be 'UFC', 'Bellator', 'Invicta-FC', 'PFL', 'ONE FC'
    //Different event types are queried depending on which checkboxes user has selected from main page UI

    var client = Client();
    StringBuffer url = new StringBuffer('https://www.mmafighting.com/schedule');
    url.write('/' + eventType);
    Response response = await client.get(url.toString());

    if (response.statusCode != 200) {
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

    //List of MMA Events to create from parsed data
    List<MMAEvent> mmaEvents = [];

    for (var link in fightLinks) {
      String title = link.text;
      String href = link.attributes['href'];
      if (title != null && href != null && href.contains('fight-card')) {
        //If link contains 'fight card', link is referencing the event name
        //Create a new event with the event name
        var mmaEvent = new MMAEvent(title);
        mmaEvents.add(mmaEvent);
        if (eventDateIterator.moveNext()) {
          //For every event name, there is an associated date (in the same order)
          //Move the iterator to the next date and add the date to the MMA Event
          mmaEvent.addDate(eventDateIterator.current.text);
        }
      } else if (title != null && href != null && href.contains('/fight/')) {
        //If the link contains '/fight/' then it is fight data
        //Add the fight data to the current event (last event in list of MMA events)
        mmaEvents.elementAt(mmaEvents.length - 1).addFight(title);
      }
    }

    for (var mmaEvent in mmaEvents) {
      fightString.write(mmaEvent.toString());
    }

    setState(() {
      statusString = statusString + fightString.toString();
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
                    value: queryInvictaFC,
                    title: const Text('Invicta FC'),
                    onChanged: _toggleQueryInvictaFC),
                CheckboxListTile(
                    value: queryOneFC,
                    title: const Text('One FC'),
                    onChanged: _toggleQueryOneFC),
                CheckboxListTile(
                    value: queryPFL,
                    title: const Text('PFL'),
                    onChanged: _toggleQueryPFL),
              ],
            ),
            new Expanded(child: buttonOrNot()),
            new Expanded(
              child: SingleChildScrollView(
                child: Text(
                  statusString,
                ),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                //_queryMMAWebsite();
              },
            ),
          ],
        ),
      ),
    );
  }
}
