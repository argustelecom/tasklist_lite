import 'package:flutter/material.dart';

/// https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1
class ApplicationState {
  const ApplicationState({this.themeMode});

  final ThemeMode? themeMode;

  @override
  bool operator ==(Object other) {
    return other is ApplicationState && this.themeMode == other.themeMode;
  }

  @override
  // #TODO: вообще для одного параметра достаточно взять его hashCode
  int get hashCode => hashValues(themeMode, themeMode);

  static ApplicationState of(BuildContext context) {
    // тут реализацию пришлось подглядеть в GalleryOptions, т.к. каноничная дает ошибки компиляции
    // каноничная -- это https://gist.github.com/HansMuller/29b03fc5e2285957ad7b0d6a58faac35
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();

    print("scope = " + scope.toString());
    // #TODO: в GalleryOptions без восклицательного знака
    return scope!.modelBindingState.currentModel;
  }

  static void update(BuildContext context, ApplicationState newModel) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ModelBindingScope>();
    scope!.modelBindingState.updateModel(newModel);
  }

  ApplicationState copyWith({ThemeMode? themeMode}) {
    return ApplicationState(themeMode: themeMode ?? this.themeMode);
  }
}

class _ModelBindingScope extends InheritedWidget {
  _ModelBindingScope({
    // #TODO: оригинальный пример делался еще без null safety. Праавильно ли просто добавить вопросик? надо получше разобраться с null safety
    Key? key,
    // #TODO: разобраться в разнице между @requred и required. Первое, похоже, теперь рудимент
    required this.modelBindingState,
    required Widget child,
  })  : assert(modelBindingState != null),
        super(key: key, child: child);

  final _ModelBindingState modelBindingState;

  // #TODO:
  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

// #TODO: вот роль ModelBinding во всем этом деле не ясна. Хочется уменьшить количество классов. Зачем этот публичный класс?
// upd: ващета он используется как корневой виджет дерева, чтобы потом через of всегда находился экземпляр. Но как он связан со Scope,
// по классу которого происходит поиск в of?
class ModelBinding extends StatefulWidget {
  ModelBinding({
    Key? key,
    this.initialModel = const ApplicationState(themeMode: ThemeMode.system),
    required this.child,
  })  : assert(initialModel != null),
        super(key: key);

  final ApplicationState initialModel;
  final Widget child;

  _ModelBindingState createState() => _ModelBindingState();
}

class _ModelBindingState extends State<ModelBinding> {
  ApplicationState currentModel = ApplicationState(themeMode: ThemeMode.system);

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
