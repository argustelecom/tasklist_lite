import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';

///*******************************************************************************
/// Базовый предок для реактивного state, которое хочет сохраняться в локальное
/// secure-хранилище.
/// Обеспечивается чтение из хранилища при инициализации (если сохранения не было, state
/// просто останется пустым) и сохранение при изменении атрибутов. Ожидается, что
/// все атрибуты реактивные (то есть имеют тип-потомок RxInterface).
///*******************************************************************************
// наследуемся от GetxService, чтобы Get начал управлять жизненным циклом нашего state в
// singleton-стиле.
abstract class PersistentState extends GetxService {
  /// Вызывается при каждом сохранении.
  /// Потомок должен описать здесь логику сохранения в json,
  /// который и будет персиститься в хранилище.
  Map<String, dynamic> toJson();

  /// вызывается при чтении из хранилища. Потомок описывает здесь,
  /// как именно заполнять реактивные атрибуты из json.
  void copyFromJson(Map<String, dynamic> json);

  /// потомок указывает здесь название ключа, под которым будет храниться
  /// state в хранилище.
  String getKeyName();

  /// потомок должен описать все атрибуты, которые нуждаются в сохранении. Требование
  /// реактивности в целом обусловлено тем, что инициализироваться эти атрибуты будут
  /// асинхронно, и все потребители state`а должны быть к этому готовы. Ну а здесь
  /// реактивность (то есть наследование от RxInterface) позволяет сохранять state
  /// при каждом изменении  любого из перечисленных атрибутов.
  List<RxInterface> getPersistentReactiveAttrs();

  /// позволяет потомку выполнить предварительную асинхронную инициализацию. Здесь,
  /// например, можно прописать те дефолты, которые будут действовать, если в хранилище
  /// не окажется сохраненного состояния для потомка. Например, прочитать состояние из
  /// параметров запуска/переменных окружения/etc. Сразу после завершения этого
  /// future будет выполняться Инициализация по сохраненному в хранилище состоянию.
  /// Внимание! инициализация вне этого метода может привести к ненужным и несвоевременным
  /// сохранениям не полностью проинициализированного state.
  Future<void> doPriorAsyncInit() async {
    return Future<void>.value(null);
  }

  late final Future<bool> initCompletedFuture;

  /// обеспечивает чтение из хранилища при инициализации
  @override
  @mustCallSuper
  void onInit() {
    final Completer<bool> completer = Completer();
    initCompletedFuture = completer.future;
    incrementBusyCount();
    super.onInit();

    doPriorAsyncInit().whenComplete(() {
      _readIfKeyExists(getKeyName(), (value) {
        copyFromJson(jsonDecode(value!));
      }).whenComplete(() {
        completer.complete(true);
        // запускаем слушателей записи только после того, как проинициализировались.
        // Иначе получим кучку лишних пересохранений недоинициализированного state,
        // которые, к тому же, могут помешать и чтению state из хранилища.
        initLocalPersistence();
      }).whenComplete(() {
        Logger log = Logger(this.runtimeType.toString());
        log.info("restored");
        decrementBusyCount();
      });
    });
  }

  /// обеспечивает корректное освобождение ресурсов перед уничтожением state.
  /// На практике в вебе не вызывается, т.к. видимо не может отловить закрытия
  /// browser tab. Здесь обсуждается близкая проблема:
  ///  https://github.com/flutter/flutter/issues/40940
  @override
  void onClose() {
    _persistingWorker.dispose();
    super.onClose();
  }

  static final _storage = FlutterSecureStorage();

  // проверяет, есть ли ключ в хранилище. Если есть, читает содержимое
  // и передает на дальнейшую обработку.
  Future<bool> _readIfKeyExists(
      String key, FutureOr<void> onValue(String? value),
      {Function? onError}) async {
    return await _storage.containsKey(key: key).then((value) async {
      if (value) {
        await _storage.read(key: key).then((value) {
          onValue(value);
        });
      }
      return (value == true);
    });
  }

  /// подробнее про Worker`ов см.https://github.com/jonataslaw/getx/blob/master/documentation/en_US/state_management.md#workers
  late final Worker _persistingWorker;

  void initLocalPersistence() {
    // #TODO: такая реализация предполагает, что на любое изменение хотя бы одного
    // переданного сюда stream будет выполнен персист в хранилище. Это избыточно, т.к.
    // часто сразу несколько полей state`а меняются почти одновременно. Здесь бы хорошо
    // подошел debounceAll, то есть то же, что debounce (см. rx_workers.dart), но для пачки
    // Rx`ов. К сожалению, debounceAll не существует, есть только debounce. Нужно сделать
    // нечто подобное.
    _persistingWorker = everAll(
      getPersistentReactiveAttrs(),
      (value) async {
        await _storage.write(key: getKeyName(), value: jsonEncode(this));
      },
    );
  }

  /// счетчик запросов на "занятость" приложения. Доступ к нему только через экземпляр
  /// ApplicationState, а здесь нужен только чтобы единообразно помечать приложение занятым
  /// на время начального чтения state из хранилища. См. также камент у
  /// ApplicationState.applicationIsBusy
  @protected
  static Rx<int> busyClaimCount = 0.obs;

  @protected
  static void incrementBusyCount() {
    // #TODO: а не надо ли тут atomic или его dart-аналога?
    busyClaimCount.value++;
  }

  @protected
  static void decrementBusyCount() {
    busyClaimCount.value--;
    assert(busyClaimCount.value >= 0);
  }
}
