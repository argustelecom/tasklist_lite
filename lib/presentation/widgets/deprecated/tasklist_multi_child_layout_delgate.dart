import 'package:flutter/cupertino.dart';

import '../../adaptive.dart';

// константы должны именоваться так же, как обычные переменные
// https://dart.dev/guides/language/effective-dart/style#prefer-using-lowercamelcase-for-constant-names
/// дескриптор карусели с выбором задачи в верхней части списка задач
const int carouselLayoutId = 1;

/// дескриптор "инспектора" по текущей выбранной задаче
const int taskDetailsLayoutId = 2;

/// дескриптор панели с фильтрами списка задач
const int taskFiltersLayoutId = 3;

/// назначение пока не придумано, но оно обязательно появится
const int taskExtrasLayoutId = 4;

// #TODO: высота не может быть постоянной , она зависит от высоты экрана
// в gallery считается, наприммер, как базовая высота, умноженная на коэффициент
// #TODO: интересно, почему высота в double?
final double carouselHeight = 200;

/// реализует responsive pattern reflow, визуально так же, как в gallery
/// но технологически иначе, попроще, меньше кастома.
class TasklistMultiChildLayoutDelegate extends MultiChildLayoutDelegate {
  late final bool _isDisplayDesktop;

  TasklistMultiChildLayoutDelegate(BuildContext buildContext) {
    _isDisplayDesktop = isDisplayDesktop(buildContext);
  }

  @override
  void performLayout(Size size) {
    final double _sheetWidth = _isDisplayDesktop ? size.width / 3 : size.width;
    // #TODO: унести эти переменные внутрь performLayout?
    final double _sheetHeight = size.height - carouselHeight;
    if (hasChild(carouselLayoutId)) {
      layoutChild(carouselLayoutId,
          BoxConstraints(maxHeight: carouselHeight, maxWidth: size.width));
      // карусель располагается в верхнем левом углу, без смещения
      positionChild(carouselLayoutId, Offset.zero);
    }
    // expand`ы ниже размещаем по-разному, в зависимости от размера экрана (isDisplayDesktop)
    // на desktop в ряд, друг рядом с другом, все распахнуты
    // на малых экранах друг под другом и под каруселью
    if (_isDisplayDesktop) {
      if (hasChild(taskDetailsLayoutId)) {
        layoutChild(
            taskDetailsLayoutId,
            BoxConstraints(
                minHeight: _sheetHeight,
                minWidth: _sheetWidth,
                maxHeight: _sheetHeight,
                maxWidth: _sheetWidth));
        // taskDetail располагается под каруселью, первым
        positionChild(taskDetailsLayoutId, Offset(0, carouselHeight));
      }
      if (hasChild(taskFiltersLayoutId)) {
        layoutChild(
            taskFiltersLayoutId,
            BoxConstraints(
                minHeight: _sheetHeight,
                minWidth: _sheetWidth,
                maxHeight: _sheetHeight,
                maxWidth: _sheetWidth));
        // фильтры располагаются под каруселью, посерединке
        positionChild(taskFiltersLayoutId, Offset(_sheetWidth, carouselHeight));
      }
      if (hasChild(taskExtrasLayoutId)) {
        layoutChild(
            taskExtrasLayoutId,
            BoxConstraints(
                minHeight: _sheetHeight,
                minWidth: _sheetWidth,
                maxHeight: _sheetHeight,
                maxWidth: _sheetWidth));
        // эта непонятная пока штука тоже располагается. где-то
        positionChild(
            taskExtrasLayoutId, Offset(_sheetWidth * 2, carouselHeight));
      }
    } else {
      late final Size taskDetailsSize;
      late final Size taskFiltersSize;
      if (hasChild(taskDetailsLayoutId)) {
        taskDetailsSize = layoutChild(taskDetailsLayoutId,
            BoxConstraints(maxHeight: _sheetHeight, maxWidth: _sheetWidth));
        // taskDetail располагается под каруселью, первым
        positionChild(taskDetailsLayoutId, Offset(0, carouselHeight));
      }
      if (hasChild(taskFiltersLayoutId)) {
        taskFiltersSize = layoutChild(taskFiltersLayoutId,
            BoxConstraints(maxHeight: _sheetHeight, maxWidth: _sheetWidth));
        // фильтры располагаются под каруселью, посерединке
        positionChild(taskFiltersLayoutId,
            Offset(0, carouselHeight + taskDetailsSize.height));
      }
      if (hasChild(taskExtrasLayoutId)) {
        layoutChild(taskExtrasLayoutId,
            BoxConstraints(maxHeight: _sheetHeight, maxWidth: _sheetWidth));
        // эта непонятная пока штука тоже располагается. где-то
        positionChild(
            taskExtrasLayoutId,
            Offset(
                0,
                carouselHeight +
                    taskDetailsSize.height +
                    taskFiltersSize.height));
      }
    }
  }

  @override
  bool shouldRelayout(covariant TasklistMultiChildLayoutDelegate oldDelegate) {
    return _isDisplayDesktop != oldDelegate._isDisplayDesktop;
  }
}
