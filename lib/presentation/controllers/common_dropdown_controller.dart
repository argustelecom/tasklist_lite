import 'package:get/get_state_manager/src/simple/get_controllers.dart';

/// Существует, только чтобы хранить состояние текущего dropdown`а на текущей странице.
/// Оказывается, весьма непросто определить, в какой момент был свернут dropdown, чтобы
/// как-то отреагировать на это событие/изменение state. Подробнее см. proposal request
/// на эту тему, https://github.com/flutter/flutter/issues/87989
/// Поэтому был выбран такой извращенный способ, через общий контроллер. Также отметим,
/// что нет способа установить, какой именно dropdown свернулся. По previous route
/// не получится по крайней мере для loginPage, т.к. в случае логаута эта страница
/// показывается для того route, к которому относилась страница, с которой произошел логаут.
/// Но это вроде не страшно, ведь всегда может быть открыт только один dropdown.
///
/// #TODO: в те светлые и недалекие времена, когда данный feature request будет реализован,
/// поднять версию dropdown`а и убрать этот костыль.
///
/// Как этим пользоваться? допустим, ты хочешь, чтобы border у твоей dropdown button был
/// синенький, если dropdown выпал, и черненький иначе (как на LoginPage). В методе onTap
/// своего dropdownButton`а вызывай someDropdownTapped = true, тогда хитрый код в main
/// вызовет someDropdownTapped = false, когда пользователь выберет значение либо сделает
/// dismiss (кликнет в другое место, что приведет к закрытию dropdown`а). Осталость только
/// выбирать цвет в зависимости от someDropdownTapped здесь.
/// Еще, обрати внимание, что подключать CommonDropdownController надо через GetBuilder,
/// а не через Get.find(). Иначе, видимо, метод build не будет считаться зависимым от
/// контроллера и не будет перестраиваться при изменении state здесь.
class CommonDropdownController extends GetxController {
  bool _someDropdownShowed = false;

  bool get someDropdownTapped => _someDropdownShowed;

  set someDropdownTapped(bool value) {
    _someDropdownShowed = value;
    update();
  }
}
