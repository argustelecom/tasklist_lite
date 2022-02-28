import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// shared state приложения, реализовано в соответствии с концепцией inherited widget
/// https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1
///
/// kostd, 16.02.2022: в чем разница применения этого и контроллеров, держащих весь остальной state?
/// Пока (условно) считаем, что это разделяемый state приложения, к которому имеют доступ не только слой
/// представления, но и слой поведения (domain в терминах clean architecture), то есть может инжектиться
/// и вызываться сервисами и репозиториями.
///
/// Это тянет за собой неприятный костыль, требующий перед каждым вызовом слоя представления помещать в контекст (Get.put).
/// Пока живем с этим. Живем и терпим.
///
/// #TODO: уже щас ясно, что слоистая архитектура в чистом виде у нас не получается, не применима. Нужно
/// дальше курить clean architecture, разбираться, чем отличается от layered и переходить на нее.
/// #TODO: для этого начинать например с https://devmuaz.medium.com/flutter-clean-architecture-series-part-1-d2d4c2e75c47
class ApplicationState {
  //для проверки из-под эмулятора используй этот адрес, если не работает дефолт
  //static const defaultServerAddress = "http://10.0.2.2:8080";

  static const defaultServerAddress = "http://localhost:8080";
  static const Map<String, String> defaultPossibleServers = const {
    "localhost": defaultServerAddress,
    "jboss12": "http://jboss12:8080"
  };

  const ApplicationState(
      {required this.themeMode,
      required this.serverAddress,
      required this.inDemonstrationMode,
      required this.possibleServers});

  final ThemeMode themeMode;

  final String serverAddress;
  final bool inDemonstrationMode;

  // здесь Map не получается проинициализировать, т.к. тогда придется отказаться от
  // модификатора final и const-конструктора, или же допустить null в конструкторе
  final Map<String, String> possibleServers;
  //TODO: научиться прокидывать значение в настройки в const-конструктор.
  // final Map<String, String> possibleServers = Map<String, String>.from(jsonDecode(dotenv.get('URL_SERVERS', fallback:
  // "{\"localhost\": \"$defaultServerAddress\", \"jboss12\": \"http://jboss12:8080\"}")));

  @override
  bool operator ==(Object other) {
    return other is ApplicationState &&
        this.themeMode == other.themeMode &&
        this.serverAddress == other.serverAddress &&
        this.inDemonstrationMode == other.inDemonstrationMode &&
        this.possibleServers == other.possibleServers;
  }

  @override
  int get hashCode => hashValues(
      themeMode, serverAddress, inDemonstrationMode, possibleServers);

  static ApplicationState of(BuildContext context) {
    // тут реализацию пришлось подглядеть в GalleryOptions, т.к. каноничная дает ошибки компиляции
    // каноничная -- это https://gist.github.com/HansMuller/29b03fc5e2285957ad7b0d6a58faac35
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();

    // #TODO: в GalleryOptions без восклицательного знака
    return scope!.modelBindingState.currentModel;
  }

  static void update(BuildContext context, ApplicationState newModel) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();
    scope!.modelBindingState.updateModel(newModel);
  }

  ApplicationState copyWith(
      {ThemeMode? themeMode,
      String? serverAddress,
      bool? inDemonstrationMode}) {
    return ApplicationState(
        themeMode: themeMode ?? this.themeMode,
        serverAddress: serverAddress ?? this.serverAddress,
        inDemonstrationMode: inDemonstrationMode ?? this.inDemonstrationMode,
        possibleServers: possibleServers);
  }
}

class _ModelBindingScope extends InheritedWidget {
  _ModelBindingScope({
    // #TODO: оригинальный пример делался еще без null safety. Праавильно ли просто добавить вопросик? надо получше разобраться с null safety
    Key? key,
    // #TODO: разобраться в разнице между @requred и required. Первое, похоже, теперь рудимент
    required this.modelBindingState,
    required Widget child,
  }) : super(key: key, child: child);

  final _ModelBindingState modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

// #TODO: вот роль ModelBinding во всем этом деле не ясна. Хочется уменьшить количество классов. Зачем этот публичный класс?
// upd: ващета он используется как корневой виджет дерева, чтобы потом через of всегда находился экземпляр. Но как он связан со Scope,
// по классу которого происходит поиск в of?
class ModelBinding extends StatefulWidget {
  ModelBinding({
    Key? key,
    this.initialModel = const ApplicationState(
      themeMode: ThemeMode.system,
      serverAddress: ApplicationState.defaultServerAddress,
      inDemonstrationMode: false,
      possibleServers: ApplicationState.defaultPossibleServers,
    ),
    required this.child,
  }) : super(key: key);

  final ApplicationState initialModel;
  final Widget child;

  _ModelBindingState createState() => _ModelBindingState();
}

class _ModelBindingState extends State<ModelBinding> {
  ApplicationState currentModel = ApplicationState(
    themeMode: ThemeMode.system,
    serverAddress: ApplicationState.defaultServerAddress,
    inDemonstrationMode: false,
    possibleServers: ApplicationState.defaultPossibleServers,
  );

  @override
  void initState() {
    super.initState();
    currentModel = widget.initialModel;
  }

  void updateModel(ApplicationState newModel) {
    if (newModel != currentModel) {
      setState(() {
        currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope(
      modelBindingState: this,
      child: widget.child,
    );
  }
}
