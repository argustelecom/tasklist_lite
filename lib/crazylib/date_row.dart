import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';


class DateRow extends StatelessWidget{

  final DateTime date;

  const DateRow({Key? key, required this.date}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    ThemeData themeData = Theme.of(context);
    if(date == DateFormat('dd MMMM yyyy', "ru_RU").format(DateTime.now()) ){
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Text("СЕГОДНЯ - $date",
          textAlign:  TextAlign.center,), //Сюда выводим сегодняшнюю
        decoration: BoxDecoration(
            color: themeData.cardColor,
            shape: BoxShape.rectangle
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      );
    }
    else if (date == DateFormat('dd MMMM yyyy', "ru_RU").format(DateTime.now().subtract(Duration(days:1)))){
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Text("ВЧЕРА - $date",
          textAlign:  TextAlign.center,), //Сюда выводим вчерашнюю дату
        decoration: BoxDecoration(
            color: themeData.cardColor,
            shape: BoxShape.rectangle
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      );
    }
    else {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Text("$date",
          textAlign:  TextAlign.center,), //Сюда выводим любую дату
        decoration: BoxDecoration(
            color: themeData.cardColor,
            shape: BoxShape.rectangle
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      );
    }
  }

}