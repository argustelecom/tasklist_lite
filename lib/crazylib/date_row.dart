import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DateRow extends StatelessWidget{

  final DateTime date;

  const DateRow({Key? key, required this.date}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    ThemeData themeData = Theme.of(context);
    if(DateFormat('dd MMMM yyyy', "ru_RU").format(date) == DateFormat('dd MMMM yyyy', "ru_RU").format(DateTime.now())){
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Text("СЕГОДНЯ - ${DateFormat('dd MMMM yyyy', "ru_RU").format(date)}",
          textAlign:  TextAlign.center,), //Сюда выводим сегодняшнюю
        decoration: BoxDecoration(
            color: themeData.cardColor,
            shape: BoxShape.rectangle
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      );
    }
    else {
      if (DateFormat('dd MMMM yyyy', "ru_RU").format(date) == DateFormat('dd MMMM yyyy', "ru_RU").format(DateTime.now().subtract(Duration(days:1)))){
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Text("ВЧЕРА - ${DateFormat('dd MMMM yyyy', "ru_RU").format(date)}",
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
        child: Text("${DateFormat('dd MMMM yyyy', "ru_RU").format(date)}",
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

}