
class MMAEvent {

  //Class to store MMA Event Data

  bool readyForCalendar = true;
  String eventName;
  DateTime eventDate;
  StringBuffer eventDetails = new StringBuffer(''); //StringBuffer to display list of fights

  MMAEvent(this.eventName);

  @override
  String toString() {
    return '\n' + this.eventName + '\nDate: ' + this.eventDate.toIso8601String() +
        '\nFights: ' + eventDetails.toString();
  }

  void addDateUFCBellator(String date){
    //Add event date for UFC and Bellator Events
    //Add a dateTime for this event based on input String date parsed from website

    //Website date for UFC and Bellator events is in the following example format 'May 3, 2019'
    //Split the date by space to separate Month, Day and Year
    List<String> dateSplit = date.split(' ');

    //Create StringBuffer for formatted string for DateTime to parse using dateTime.parse() method
    //StringBuffer will be in format 'YYYY-MM-DD 17:00:00'
    //Time will be left as 17:00:00 for now since mmafighting website doesn't have event times
    StringBuffer formattedDateString = new StringBuffer('');
    
    String year = dateSplit.elementAt(2);
    String month = dateSplit.elementAt(0);
    String day = dateSplit.elementAt(1).substring(0, dateSplit.elementAt(1).indexOf(','));
    if(day.length == 1){
      //If the day is 1 digit, it must have a 0 in front of it for dateTime.parse() method to work properly
      day = '0' + day;
    }
    
    formattedDateString.write(year + '-');
    
    switch (month) {
      case 'January':
        formattedDateString.write('01-');
        break;
      case 'February':
        formattedDateString.write('02-');
        break;
      case 'March':
        formattedDateString.write('03-');
        break;
      case 'April':
        formattedDateString.write('04-');
        break;
      case 'May':
        formattedDateString.write('05-');
        break;
      case 'June':
        formattedDateString.write('06-');
        break;
      case 'July':
        formattedDateString.write('07-');
        break;
      case 'August':
        formattedDateString.write('08-');
        break;
      case 'September':
        formattedDateString.write('09-');
        break;
      case 'October':
        formattedDateString.write('10-');
        break;
      case 'November':
        formattedDateString.write('11-');
        break;
      case 'December':
        formattedDateString.write('12-');
        break;
      default:
        formattedDateString.write('01-');
        break;
    }

    formattedDateString.write(day + ' 17:00:00');

    try{
      this.eventDate = DateTime.parse(formattedDateString.toString());
      //Convert time to UTC Pacific time
      this.eventDate = new DateTime.utc(eventDate.year, eventDate.month, eventDate.day, eventDate.hour + 6);
    } catch(e){
      //If exception occurs when parsing date, ensure that date is not added to calendar
      readyForCalendar = false;
    }


  }

  void addDateOneFC(String date){
    //Add event date for OneFC Events
    //Add a dateTime for this event based on input String date parsed from website

    //Website date is in the following example format '06 Dec 2019'
    //Split the date by space to separate Month, Day and Year
    List<String> dateSplit = date.split(' ');

    //Create StringBuffer for formatted string for DateTime to parse using dateTime.parse() method
    //StringBuffer will be in format 'YYYY-MM-DD 17:00:00'
    //Time will be left as 05:00:00 for now since website doesn't have event times
    StringBuffer formattedDateString = new StringBuffer('');

    String year = dateSplit.elementAt(2);
    String month = dateSplit.elementAt(1);
    String day = dateSplit.elementAt(0);
    if(day.length == 1){
      //If the day is 1 digit, it must have a 0 in front of it for dateTime.parse() method to work properly
      day = '0' + day;
    }

    formattedDateString.write(year + '-');

    switch (month) {
      case 'Jan':
        formattedDateString.write('01-');
        break;
      case 'Feb':
        formattedDateString.write('02-');
        break;
      case 'Mar':
        formattedDateString.write('03-');
        break;
      case 'Apr':
        formattedDateString.write('04-');
        break;
      case 'May':
        formattedDateString.write('05-');
        break;
      case 'Jun':
        formattedDateString.write('06-');
        break;
      case 'Jul':
        formattedDateString.write('07-');
        break;
      case 'Aug':
        formattedDateString.write('08-');
        break;
      case 'Sep':
        formattedDateString.write('09-');
        break;
      case 'Oct':
        formattedDateString.write('10-');
        break;
      case 'Nov':
        formattedDateString.write('11-');
        break;
      case 'Dec':
        formattedDateString.write('12-');
        break;
      default:
        formattedDateString.write('01-');
        break;
    }

    formattedDateString.write(day + ' 17:00:00');

    try{
      this.eventDate = DateTime.parse(formattedDateString.toString());
      //Convert date to UTC Beijing time
      this.eventDate = new DateTime.utc(eventDate.year, eventDate.month, eventDate.day, eventDate.hour - 8);
    } catch(e){
      //If exception occurs when parsing date, ensure that date is not added to calendar
      readyForCalendar = false;
    }


  }

  void addDetails(String fight){
    //Add a details to the eventDetails String Buffer
    //Details typically consist of fight info (i.e. Guy1 vs. Guy2) or location
    //info (i.e. Beijing)
    eventDetails.write('\n' + fight);
  }

  String getPrefKey(){
    //Key used for the shared prefs to store the calendar event ID in case
    //the event needs to be updated
    //The first 4 digits of the event name are used since event titles
    //sometimes change, but the first 4 letters remain the same
    //The date is also used since the first 4 digits of name may be shared with
    //other events
    return eventName.substring(0,4) + eventDate.toIso8601String();
  }

  String getPrefBoolKey(){
    //Key used for bool preferences
    //Preferences must have different keys in shared_prefs library
    // or else conflicts occur
    return eventName.substring(0,5) + eventDate.toIso8601String();
  }

}

