import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';

class CalendarPage extends StatefulWidget {

  Function _calendarCallback;

  CalendarPage(this._calendarCallback);

  @override
  CalendarPageState createState() {
    return new CalendarPageState();
  }
}

class CalendarPageState extends State<CalendarPage> {
  DeviceCalendarPlugin _deviceCalendarPlugin;

  List<Calendar> _calendars;
  Calendar _selectedCalendar;


  CalendarPageState() {
    _deviceCalendarPlugin = new DeviceCalendarPlugin();
  }

  @override
  initState() {
    super.initState();
    _retrieveCalendars();
  }

  @override
  Widget build(BuildContext context) {
    //Scaffold shows a list of the users calendars that can be selected by the
    //user
    //After a calendar is selected, calendar info is sent back to main page
    //via calenderCallback function
    return new Scaffold(
      body: new Column(
        children: <Widget>[
          Text('Select Calendar'),
          new ConstrainedBox(
            constraints: new BoxConstraints(maxHeight: 150.0),
            child: new ListView.builder(
              itemCount: _calendars?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCalendar = _calendars[index];
                      this.widget._calendarCallback(_selectedCalendar.id, _selectedCalendar.name, _deviceCalendarPlugin);
                    });
                  },
                  child: new Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          flex: 1,
                          child: new Text(
                            _calendars[index].name,
                            style: new TextStyle(fontSize: 25.0),
                          ),
                        ),
                        new Icon(_calendars[index].isReadOnly
                            ? Icons.lock
                            : Icons.lock_open, color: Colors.white,)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _retrieveCalendars() async {
    //Retrieve user's calendars from mobile device
    //Request permissions first if they haven't been granted
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      setState(() {
        _calendars = calendarsResult?.data;
      });
    } catch (e) {
      print(e);
    }
  }


}