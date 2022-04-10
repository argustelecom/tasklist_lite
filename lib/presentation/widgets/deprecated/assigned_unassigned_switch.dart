import 'package:flutter/material.dart';

@Deprecated(
    "делался как переключатель режима назначенные/неназначенные в списке задач. "
    "Но оказалось, что это не нужно. Оставлен как заготовка для tab-подобных переключателей, "
    "которые переключаю не tab`ы, а что-то другое. Если будешь использовать, обобщи tab`ы, сделай параметром")
class AssignedUnassignedSwitch extends StatefulWidget {
  final ValueChanged<int>? onIndexChanged;

  AssignedUnassignedSwitch({this.onIndexChanged});

  @override
  State<StatefulWidget> createState() =>
      new AssignedUnassignedSwitchState(onIndexChanged: this.onIndexChanged);
}

class AssignedUnassignedSwitchState extends State<AssignedUnassignedSwitch>
    with SingleTickerProviderStateMixin {
  final ValueChanged<int>? onIndexChanged;

  // пришлось громоздить весь этот state with SingleTickerProviderMixin только ради
  // этого контроллера. А DefaultTabController не подходит, т.к. не позволит навесить
  // listener на событие изменения выбранного tab`а
  late final TabController _tabController;

  AssignedUnassignedSwitchState({this.onIndexChanged});

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        onIndexChanged?.call(_tabController.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 32),
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: Theme.of(context).dividerColor, width: 2.0),
              ),
            ),
          ),
          TabBar(
            // цвет у selected label должен быть такой же, как у индикатора
            labelColor: Theme.of(context).indicatorColor,
            labelStyle: TextStyle(fontSize: 18),
            // а здесь пытаемся сохранить оригинальный неизменный цвет label
            unselectedLabelColor: Theme.of(context).textTheme.headline1?.color,
            tabs: [
              Tab(
                child: Text(
                  "Назначенные",
                ),
              ),
              Tab(
                child: Text(
                  'Неназначенные',
                ),
              ),
            ],
            controller: _tabController,
          ),
        ],
      ),
    );
  }
}
