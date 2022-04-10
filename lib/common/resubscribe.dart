import 'dart:async';

import 'package:get/get.dart';

import '../presentation/state/application_state.dart';

///***********************************************************************
/// отменяет существующую подписку и создает новую на переданный stream.
/// В качестве onData вешает переданный обработчик. Если showProgress,
/// отображает progress-индикатор с момента начала подписки и до первого
/// event`а. Отображает, взводя соотв. флажок в ApplicationState, поэтому,
/// в отличие от asyncShowProgressIndicatorOverlay, безопасен, может быть
/// вызван в initState.
///************************************************************************
StreamSubscription resubscribe<T>(StreamSubscription? streamSubscription,
    Stream<T> stream, void onData(T event),
    {bool showProgress = false}) {
  streamSubscription?.cancel();

  ApplicationState applicationState = Get.find();

  if (showProgress) {
    // на время, пока не вернется первая пачка данных, покажем progress-
    // индикатор. Потом (в последующих пачках) не надо, т.к. state уже будет
    // непустой, пользователь сможет работать с данными в state.
    // Здесь можно было бы вызвать asyncShowProgressIndicatorOverlay, но т.к.
    // нас вызывают в onInit, когда build-контекста еще нет, будут ошибки.
    applicationState.claimApplicationIsBusy();
    Stream<T> broadcastStream =
        stream.isBroadcast ? stream : stream.asBroadcastStream();
    broadcastStream.first.whenComplete(
      () {
        applicationState.unClaimApplicationIsBusy();
        return null;
      },
    );
    return broadcastStream.listen(onData);
  } else {
    return stream.listen(onData);
  }
}
