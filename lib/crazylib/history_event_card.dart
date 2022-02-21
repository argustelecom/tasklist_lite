import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Это карточка исторического события, данные карточки используем на task_page
/// для представления исторических событий на соответсвующей вкладке
class HistoryEventCard extends StatelessWidget {
  final String person;
  final String type;
  var content;
  final DateTime date;
  final isAlarm;

  HistoryEventCard(
      {Key? key,
      required this.person,
      required this.type,
      required this.content,
      required this.date,
      required this.isAlarm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, top: 8),
                  child: Text("$person",
                      style: TextStyle(
                        fontSize: 14,
                      )),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, right: 8),
                child: Icon(
                  isAlarm ? Icons.notifications_active : null,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, right: 16),
                child: Text(
                  "$type",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Text(
                "$content",
                softWrap: true,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("${DateFormat('dd.MM.yyyy HH:mm', "ru_RU").format(date)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
