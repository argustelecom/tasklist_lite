import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../tasklist/fixture/task_fixtures.dart';
import '../tasklist/model/task.dart';

/// Данный класс описывает кнопку-клизму, которая умеет проваливаться в
/// яндекскарту и копировать координаты по лонгпрессу(TODO:второе пока не умеет, надо научить)

class LocationButton extends StatelessWidget {
  late Task? task;
  LocationButton({required this.task});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Padding(
        padding: EdgeInsets.only(left: 12, right: 16),
        child: task != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // #TODO: в макете у иконки еще elevation присутствует, с ходу не получилось сделать
                  IconButton(
                      onPressed: () async {
                        // Есть map_launcher, но он в вебе не работает (ругается)
                        // но можно открывать урл к yandex maps например
                        // https://stackoverflow.com/questions/52052232/flutter-url-launcher-google-maps
                        String baseUrl = "https://yandex.ru/maps/?l=map&z=11";
                        // параметры открытия яндекса см. https://yandex.com/dev/yandex-apps-launch/maps/doc/concepts/yandexmaps-web.html
                        // #TODO: если бы у нас были текущиие координаты (а они будут в следующих версиях), можно открывать прям маршрут,
                        // см. Plot Route https://yandex.com/dev/yandex-apps-launch/maps/doc/concepts/yandexmaps-web.html#yandexmaps-web__buildroute
                        if ((task!.latitude != null) &&
                            (task!.longitude != null)) {
                          baseUrl = baseUrl +
                              "&pt=" +
                              task!.longitude.toString() +
                              "," +
                              task!.latitude.toString();
                        } else if (task!.address != null) {
                          // если координаты не заданы, поищем по адресу
                          baseUrl = baseUrl + "&text=" + task!.address!;
                        }
                        final String encodedURl = Uri.encodeFull(baseUrl);
                        // тут можно было бы проверить через canLaunch, но вроде не обязательно
                        // в крайнем случае откроет просто карту в неподходящем месте
                        launch(encodedURl);
                      },
                      icon: Column(
                        children: [
                          Expanded(
                            child: Icon(
                              Icons.place,
                              color: themeData.colorScheme.primary,
                            ),
                          ),
                          // #TODO: согласно макету, под иконкой должно быть не равномерное подчеркивание,
                          // а тень, хитро полученная как тень рамки иконки в figma. Подобного эффекта пока
                          // достичь не удалось.
                          // Еще вариант -- такая вот иконка https://www.iconfinder.com/icons/2344289/gps_location_map_place_icon
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 20,
                              ),
                              child: Divider(
                                thickness: 3,
                              ),
                            ),
                          ),
                        ],
                      )),
                  Text(task!.flexibleAttribs[
                              TaskFixtures.distanceToObjectFlexAttrName]
                          ?.toString() ??
                      "")
                ],
              )
            : Container());
  }


}
