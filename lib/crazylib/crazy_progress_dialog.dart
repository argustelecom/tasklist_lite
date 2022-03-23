import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tasklist_lite/state/application_state.dart';

///*******************************************************************************
///
/// circular-progress-индикатор, представляющий собой вращаюущуюся змейку,
/// внутри которой логотип приложения (который берется из asset), Стартовый угол,
/// откуда начинается вращение змейки, смещается на 15 градусов при каждом вращении.
/// Соответствует макету, предложенному аналитиками.
///
/// Сам по себе просто виджет, расположенный внутри center. Задача расположения поверх
/// остального контента, например, через Stack или Overlay`и, здесь не решается.
/// Но для этого тоже есть инструменты, см. ниже.
///*******************************************************************************
class CrazyProgressIndicator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CrazyProgressIndicatorState();
  }
}

class CrazyProgressIndicatorState extends State<CrazyProgressIndicator> {
  final ApplicationState applicationState = Get.find();

  /// в соответствии с макетом, начальный угол (тот, от которого начинает строиться дуга
  /// прогресса) переменный. Чтобы в ui это смотрелось свежее, пусть он каждый раз будет
  /// разный, с шагом сектора в 15 градусов (то есть возможные значения 0, 15, 30,..360).
  final Rx<double> _angle = (Random().nextInt(24).toDouble() * 15).obs;

  CrazyProgressIndicatorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        // прекрасный, мощнейший circular-индикатор прогресса, гораздо более гибкий, чем встроенный
        // CircularProgressIndicator. Ради него даже не жалко подключить отдельный package percent_indicator
        return CircularPercentIndicator(
          radius: 100,
          animation: true,
          animationDuration: 700,
          // Сознательно откажемся от штатного повтора, опираясь на магию в onAnimationEnd.
          // Не смотря на то, что повтор анимации выключен, она будет повторяться бесконечно
          // пояснение этому космическому уникальному читу ищи ниже!
          //restartAnimation: true,
          percent: 1,
          backgroundColor: Colors.transparent,
          linearGradient: LinearGradient(colors: [
            Colors.transparent,
            Theme.of(context).colorScheme.primary,
          ]),
          lineWidth: 20,
          // кончик дуги будет скругленным. Инересно, что дефолтный вариант "кончика" имеет тип butt.
          circularStrokeCap: CircularStrokeCap.round,
          // начальный угол динамически меняется благодаря коду в onAnimationEnd.
          startAngle: _angle.value,
          // простейший равномерный вариант анимации
          curve: Curves.linear,
          // не смотря на странный камент к этому атрибуту, на практике он определяет, что градиент дуги
          // распространяется не горизонтально, а вдоль самой дуги. То есть как в нашем макете (если true).
          rotateLinearGradient: true,
          onAnimationEnd: () {
            // главная хитрость прямо тут. Макет предполагает, что startAngle должен динамически смещаться
            // и не быть постоянным. При этом штатной поддержки такого функционала у CircularPercentIndicator`а
            // нет. Встроенная анимация работает только с percent, а если прикрутить внешнюю анимацию к startAngle,
            // то дуга прогресса вообще не отображается. Т.к. startAngle постоянно меняется, а каждый раз при его
            // изменении виджет рисуется заново, она просто не успевает отрисоваться до следующего изменения.
            // К тому же, если включен restartAnimation, callback onAnimationEnd вообще не вызвается (см. код виджета).
            // Поэтому сделаем финт ушами. Выключим повтор анимации и будем ловить onAnimationEnd. Каждый раз, как он
            // будет вызван, проинкрементим startAngle. Поскольку он изменился, это сразу приведет к отрисовке анимации
            // с нуля, но уже с нового startAngle. То что нам и надо.
            _angle.value = _angle.value + 15;
            // Помним, что максимальный угол сектора окружности -- 360 градусов. Неконтролируемый рост не допускаем.
            if (_angle.value > 360) {
              _angle.value = _angle.value - 360;
            }
          },
          center: Padding(
            padding: EdgeInsets.all(25),
            child: Image.asset(
              // внимательней, хотсвап не подцепляет изменения в asset, надо делать полную пересборку
              "images/logo_figaro.png",
              bundle: rootBundle,
            ),
          ),
        );
      }),
    );
  }
}

///*******************************************************************************
/// Отображает overlay с фирменным progress-индикатором на время выполнения
/// asyncFunction. В качестве результата возвращает результат этого asyncFunction.
///
/// Контент под индикатором будет блокирован, т.к. использование overlay предполагает
/// и использование ModalBarrier`а, блокирующего все, что под ним.
/// Примечателен тем, что за счет Get.showOverlay гарантируется, что на момент вызова
/// он будет на самом верху overlay-стека, то есть перекроет все диалоги, выпдающие
/// списки и все другое, что реализуется как ModalRoute.
/// Имеет ограничение: не стоит вызывать в onInit, initState и подобных местах, где
/// buildContext еще не создан. Хотя напрямую в параметры контекст не получает,
/// Get под капотом его использует и расстраивается, если его еще нет.
///*******************************************************************************
Future<T> asyncShowProgressIndicatorOverlay<T>(
    {required Future<T> Function() asyncFunction}) {
  return Get.showOverlay<T>(
      asyncFunction: asyncFunction,
      loadingWidget: CrazyProgressIndicator(),
      opacity: 0);
}

///*******************************************************************************
/// "Диалог" (на самом деле нет) с индикатором прогресса. Если приложение занято (см.
/// ApplicationState.isApplicationBusy), отобразит CrazyProgressIndicator поверх своего
/// child.
/// Имеет ограничение -- настоящие диалоги (которые используют под капотом Overlay) будут
/// перекрывать индикатор прогресса, для них лучше использовать императивный
/// asyncShowProgressIndicatorOverlay.
///*******************************************************************************
class CrazyProgressDialog extends StatelessWidget {
  /// Здесь, в отличие от остальных диалогов, в child надо класть не контент диалога.
  /// В  child нужно передать тот виджет, который будет спрятан за progress indicator`ом
  final Widget child;

  CrazyProgressDialog({required this.child});
  final ApplicationState applicationState = Get.find();

  @override
  Widget build(BuildContext context) {
    // наверное, правильнее было бы использовать Overlay вместо Stack, но есть проблема --
    // коллекция initialEntries у Overlay не перестраивается после изменения реактивных переменных,
    // даже если используется виджет Obx. Глубоко не копал, но можно это объяснить особенностями
    // реализации initialEntries (не случайно они именно initial, а не просто Entries).
    //
    // Поэтому используем Stack, а чтобы под индикатором прогресса ничего не нажималось -- ModalBarrier
    return Obx(() {
      return Stack(
        children: [
          this.child,
          if (applicationState.isApplicationBusy().value)
            ModalBarrier(
              dismissible: false,
              color: Colors.transparent.withOpacity(0.2),
            ),
          if (applicationState.isApplicationBusy().value)
            CrazyProgressIndicator(),
        ],
      );
    });
  }
}
