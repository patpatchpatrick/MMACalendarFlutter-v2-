import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'mmaobjects.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:mma_calendar_flutter/calendarpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  // Main Page (Stateful)

  // Page title
  final String title;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String statusString = ''; //Status string displayed to user

  //Booleans to track which mmaEvents to Query
  bool queryUFC = true;
  bool queryBellator = true;
  bool queryInvictaFC = true;
  bool queryPFL = true;
  bool queryOneFC = true;

  //Calendar Variables
  bool calendarSelected = false;
  String calendarButtonText = 'Select Calendar to Add Events';
  String _currentCalendarID = '';
  DeviceCalendarPlugin _deviceCalendarPlugin = new DeviceCalendarPlugin();

  void _setCalendarCallback(
      String calendarID, String calendarName, DeviceCalendarPlugin deviceCal) {
    //Calendar Callback Function used by Calendar Page
    //Calendar Page will call the callback to provide calendar info needed
    //to load mma events into calendar
    setState(() {
      _currentCalendarID = calendarID;
      calendarButtonText = calendarName;
      _deviceCalendarPlugin = deviceCal;
      calendarSelected = false;
    });
  }

  Widget calendarButtonOrCalendar() {
    //Returns a calendar button that displays 'Select Calendar' or Returns a
    // Calendar Page if the button was pressed
    if (!calendarSelected) {
      return new FlatButton.icon(
          icon: Icon(
            Icons.calendar_today,
            color: Colors.amber[600],
          ),
          label: Text(calendarButtonText,
              style: Theme.of(context).textTheme.body1),
          onPressed: () {
            setState(() {
              calendarSelected = true;
            });
          });
    } else {
      return new CalendarPage(this._setCalendarCallback);
    }
  }

  Widget loadFightsButton() {
    // Returns a null button if the Calendar was not selected, otherwise it returns
    // a button that is not null and can be used to query fights from the web
    // and add them to the user's selected calendar
    if (_currentCalendarID != '') {
      return new FlatButton.icon(
          onPressed: _queryMMAWebsite,
          icon: Icon(
            Icons.cached,
            color: Colors.amber[600],
          ),
          label: Text('Load Fights and Add to Calendar',
              style: Theme.of(context).textTheme.body1));
    } else {
      return new FlatButton.icon(
          onPressed: null,
          icon: Icon(
            Icons.cached,
            color: const Color(0xff979799),
          ),
          label: Text('Load Fights and Add to Calendar',
              style: Theme.of(context).textTheme.subhead));
    }
  }

  Text statusMessageHeader(){
    if(statusString != ''){
      return new Text('Events Added/Updated in Calendar:\n', style: Theme.of(context).textTheme.body2 );
    } else {
      return new Text('');
    }
  }

  void setDeviceCalendarCallback(DeviceCalendarPlugin deviceCalendar) {
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
    //Reset the status back to blank, then query MMA events for MMA Events
    //depending on the checkboxes the user selected
    statusString = '';
    if (queryUFC) {
      _queryAndParseWebsiteUFCBellator('ufc');
    }
    if (queryBellator) {
      _queryAndParseWebsiteUFCBellator('bellator');
    }
    if (queryInvictaFC) {
      _queryAndParseWebsiteUFCBellator('invicta-fc');
    }
    if (queryOneFC) {
      _queryAndParseWebsiteUFCBellator('one-fc');
    }
    if (queryPFL) {
      _queryAndParseWebsiteUFCBellator('pfl');
    }
  }

  Future _addEventsToCalendar(List<MMAEvent> mmaEvents) async {
    //Method to add events to the user's calendar
    //If called, the list of mmaEvents will be iterated through and the mma
    // Events will be added to the user's selected calendar

    //If the events have previously been added by the user, they will have a
    // shared preference key for the Event ID and the event will be UPDATED
    // instead of CREATED

    //If events are successfully created/added, then the events that were
    // CREATED/UPDATED will be displayed to the user in the status string

    var fightString = new StringBuffer('');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    for (var mmaEvent in mmaEvents) {
      //Before adding MMA Event to calendar, check if it is ready for calendar
      // (i.e. ensure it is properly formatted)
      if (mmaEvent.readyForCalendar) {
        final eventTime = mmaEvent.eventDate;
        final eventToCreate = new Event(_currentCalendarID);
        eventToCreate.title = mmaEvent.eventName;
        eventToCreate.start = eventTime;
        eventToCreate.description = mmaEvent.eventFights.toString();
        String mmaEventId = prefs.getString(mmaEvent.getPrefKey());
        if (mmaEventId != null) {
          eventToCreate.eventId = mmaEventId;
        }
        eventToCreate.end = eventTime.add(new Duration(hours: 3));
        final createEventResult =
            await _deviceCalendarPlugin.createOrUpdateEvent(eventToCreate);
        if (createEventResult.isSuccess &&
            (createEventResult.data?.isNotEmpty ?? false)) {
          prefs.setString(mmaEvent.getPrefKey(), createEventResult.data);
          fightString.write(mmaEvent.eventName + '\n');
        }
      }
    }

    setState(() {
      statusString = statusString + fightString.toString();
    });
  }

  Future _queryAndParseWebsiteUFCBellator(String eventType) async {
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

    //Add the queried events to the user's calendar
    _addEventsToCalendar(mmaEvents);

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
        title: new Image.asset('assets/Logo.png'),
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
                    title:
                        Text('UFC', style: Theme.of(context).textTheme.body1),
                    onChanged: _toggleQueryUFC),
                CheckboxListTile(
                    value: queryBellator,
                    title: Text('Bellator',
                        style: Theme.of(context).textTheme.body1),
                    onChanged: _toggleQueryBellator),
                CheckboxListTile(
                    value: queryInvictaFC,
                    title: Text('Invicta FC',
                        style: Theme.of(context).textTheme.body1),
                    onChanged: _toggleQueryInvictaFC),
                CheckboxListTile(
                    value: queryOneFC,
                    title: Text('One FC',
                        style: Theme.of(context).textTheme.body1),
                    onChanged: _toggleQueryOneFC),
                CheckboxListTile(
                    value: queryPFL,
                    title:
                        Text('PFL', style: Theme.of(context).textTheme.body1),
                    onChanged: _toggleQueryPFL),
              ],
            ),
            new Expanded(child: calendarButtonOrCalendar()),
            loadFightsButton(),
            statusMessageHeader(),
            new Expanded(
              child: SingleChildScrollView(
                child: Text(
                  statusString,
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
