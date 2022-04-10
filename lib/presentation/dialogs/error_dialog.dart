import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

final List<String> lastMessages = [];

void showErrorReportDialog() {
  Get.defaultDialog(
    title: "Сообщить об ошибке",
    content: SizedBox(
      height: 500,
      child: SelectableText.rich(TextSpan(
          text: lastMessages.map((e) {
        return "\n" + e.toString();
      }).toString())),
    ),
    actions: <Widget>[
      TextButton(
        child: const Text('Отправить'),
        onPressed: () {
          // #TODO[ВС]: пробрасывать ServerName или DBName сервера или каую-то такую инфу. Ее же неплохо бы выводить
          // #TODO[ВС]: фиксировать имя учетной записи и время отправки
          // #TODO[ВС]: мб телеграм ссылку? мб сделать чтобы настраивалось?
          // наверное, так
          String subject = "version DBName/instance date error.name";
          String body =
              "*********************************************************************\n" +
                  lastMessages.toString() +
                  "\n" +
                  "*********************************************************************\n";

          String url = "mailto:figaro-support@argustelecom.ru?subject=" +
              subject +
              "&body=" +
              body;
          final String encodedURl = Uri.encodeFull(url);
          launch(encodedURl);
        },
      ),
      TextButton(
        child: const Text('Отмена'),
        onPressed: () {
          GetDelegate routerDelegate = Get.find();
          routerDelegate.popRoute();
        },
      ),
    ],
  );
}
