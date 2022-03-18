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
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                      width: 250,
                      height: 50,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _choices.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ChoiceChip(
                              label: Text(_choices[index]),
                              selected: _defaultChoiceIndex == index,
                              selectedColor: Colors.yellow.shade700,
                              onSelected: (bool selected) {
                                setState(() {
                                  _defaultChoiceIndex = selected ? index : 0;
                                  markController.update();
                                });
                              },
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.black),
                            );
                          })),
                ]),
                SizedBox(
                  height: 400,
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
