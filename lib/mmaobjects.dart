import 'package:flutter/material.dart';
import 'mainpage.dart';

class MMAEvent {

  String eventName;
  DateTime eventDate;
  StringBuffer eventFights = new StringBuffer(''); //StringBuffer to display list of fights

  MMAEvent(this.eventName);

  @override
  String toString() {
    return '\n' + this.eventName + '\nDate: ' + this.eventDate.toIso8601String() +
        '\nFights: ' + eventFights.toString();
  }

  void addDate(String date){
    List<String> dateSplit = date.split(' ');
    StringBuffer formattedDateString = new StringBuffer('');
    
    String year = dateSplit.elementAt(2);
    String month = dateSplit.elementAt(0);
    String day = dateSplit.elementAt(1).substring(0, dateSplit.elementAt(1).indexOf(','));
    if(day.length == 1){
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

    formattedDateString.write(day + ' 12:00:00');

    try{
      this.eventDate = DateTime.parse(formattedDateString.toString());
    } catch(e){

    }


  }

  void addFight(String fight){
    //Add a fight to the fights String Buffer
    eventFights.write('\n' + fight);
  }

}

