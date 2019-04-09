import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'mmaobjects.dart';
import 'package:mma_calendar_flutter/mainpage.dart';
import 'mainpage.dart';
import 'package:device_calendar/device_calendar.dart';

class CalendarPage extends StatefulWidget {

  Function calendarIDCallback;

  CalendarPage(this.calendarIDCallback);

  @override
  CalendarPageState createState() {
    return new CalendarPageState();
  }
}

class CalendarPageState extends State<CalendarPage> {
  DeviceCalendarPlugin _deviceCalendarPlugin;

  List<Calendar> _calendars;
  Calendar _selectedCalendar;
  List<Event> _calendarEvents;


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
                  onTap: () async {
                    await _retrieveCalendarEvents(_calendars[index].id);
                    setState(() {
                      _selectedCalendar = _calendars[index];
                      this.widget.calendarIDCallback(_selectedCalendar.id, _selectedCalendar.name);
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
                            : Icons.lock_open)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Container(
              decoration: new BoxDecoration(color: Colors.white),
              child: new ListView.builder(
                itemCount: _calendarEvents?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return new EventItem(
                      _calendarEvents[index], _deviceCalendarPlugin, () async {
                    await _retrieveCalendarEvents(_selectedCalendar.id);
                  });
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !(_selectedCalendar?.isReadOnly ?? true)
          ? new FloatingActionButton(
        onPressed: () async {
          final now = new DateTime.now();
          final eventToCreate = new Event(_selectedCalendar.id);
          eventToCreate.title =
          "Event created with Device Calendar Plugin";
          eventToCreate.start = now;
          eventToCreate.end = now.add(new Duration(hours: 1));
          final createEventResult = await _deviceCalendarPlugin
              .createOrUpdateEvent(eventToCreate);
          if (createEventResult.isSuccess &&
              (createEventResult.data?.isNotEmpty ?? false)) {
            _retrieveCalendarEvents(_selectedCalendar.id);
          }
        },
        child: new Icon(Icons.add),
      )
          : new Container(),
    );
  }

  void _retrieveCalendars() async {
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

  Future _retrieveCalendarEvents(String calendarId) async {
    try {
      final startDate = new DateTime.now().add(new Duration(days: -30));
      final endDate = new DateTime.now().add(new Duration(days: 30));
      final retrieveEventsParams =
      new RetrieveEventsParams(startDate: startDate, endDate: endDate);
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
          calendarId, retrieveEventsParams);

      setState(() {
        _calendarEvents = eventsResult?.data;
      });
    } catch (e) {
      print(e);
    }
  }
}

class EventItem extends StatelessWidget {
  final Event _calendarEvent;
  final DeviceCalendarPlugin _deviceCalendarPlugin;

  final Function onDeleteSucceeded;

  final double _eventFieldNameWidth = 75.0;

  EventItem(
      this._calendarEvent, this._deviceCalendarPlugin, this.onDeleteSucceeded);

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new ListTile(
              title: new Text(_calendarEvent.title ?? ''),
              subtitle: new Text(_calendarEvent.description ?? '')),
          new Container(
            padding: new EdgeInsets.symmetric(horizontal: 16.0),
            child: new Column(
              children: <Widget>[
                new Align(
                  alignment: Alignment.topLeft,
                  child: new Row(
                    children: <Widget>[
                      new Container(
                        width: _eventFieldNameWidth,
                        child: new Text('All day?'),
                      ),
                      new Text(
                          _calendarEvent.allDay != null && _calendarEvent.allDay
                              ? 'Yes'
                              : 'No'),
                    ],
                  ),
                ),
                new SizedBox(
                  height: 10.0,
                ),
                new Align(
                  alignment: Alignment.topLeft,
                  child: new Row(
                    children: <Widget>[
                      new Container(
                        width: _eventFieldNameWidth,
                        child: new Text('Location'),
                      ),
                      new Expanded(
                        child: new Text(
                          _calendarEvent?.location ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                new SizedBox(
                  height: 10.0,
                ),
                new Align(
                  alignment: Alignment.topLeft,
                  child: new Row(
                    children: <Widget>[
                      new Container(
                        width: _eventFieldNameWidth,
                        child: new Text('Attendees'),
                      ),
                      new Expanded(
                        child: new Text(
                          _calendarEvent?.attendees
                              ?.where((a) => a.name?.isNotEmpty ?? false)
                              ?.map((a) => a.name)
                              ?.join(', ') ??
                              '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          new ButtonTheme.bar(
            child: new ButtonBar(
              children: <Widget>[
                new IconButton(
                  onPressed: () async {
                    final deleteResult =
                    await _deviceCalendarPlugin.deleteEvent(
                        _calendarEvent.calendarId, _calendarEvent.eventId);
                    if (deleteResult.isSuccess && deleteResult.data) {
                      onDeleteSucceeded();
                    }
                  },
                  icon: new Icon(Icons.delete),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}