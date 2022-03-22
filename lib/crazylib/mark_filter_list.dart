import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:tasklist_lite/state/mark_controller.dart';
import 'package:tasklist_lite/tasklist/model/mark.dart';

import 'mark_card.dart';

class MarkTypeFilter extends StatefulWidget {
  const MarkTypeFilter({Key? key}) : super(key: key);

  @override
  State createState() => CastFilterState();
}

class CastFilterState extends State<MarkTypeFilter> {
  final _choices = ["Все", "Зачисления", "Списания"];
  int _defaultChoiceIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MarkController>(
        init: MarkController(),
        builder: (markController) {
          return Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(children: [
                Wrap(
                    spacing: 8,
                    children: List.generate(_choices.length, (index) {
                      return ChoiceChip(
                        side: BorderSide(color: Colors.yellow.shade700),
                        label: Text(_choices[index]),
                        labelStyle: TextStyle(
                            fontFamily: "ABeeZee",
                            fontSize: 10,
                            color: Colors.black),
                        selected: _defaultChoiceIndex == index,
                        selectedColor: Colors.yellow.shade700,
                        onSelected: (bool selected) {
                          setState(() {
                            _defaultChoiceIndex = selected ? index : 0;
                            markController.update();
                          });
                        },
                        backgroundColor: Colors.white,
                      );
                    })),
                Expanded(
                  child: ListView.builder(
                      itemCount:
                          markController.getMarks(_defaultChoiceIndex).length,
                      controller: new ScrollController(),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            child: MarkCard(
                                mark: markController
                                    .getMarks(_defaultChoiceIndex)[index],
                                maxLines: 10));
                      }),
                )
              ]));
        });
  }
}
