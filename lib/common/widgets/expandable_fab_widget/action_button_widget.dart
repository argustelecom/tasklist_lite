import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/// Дочерний виджет, через него задается исполняемый код и вид каждой дочерней кнопки
@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  /// исполняемый код, вешающийся на дочернюю кнопку
  final VoidCallback? onPressed;
  /// внешний вид дочерней кнопки (пока только иконка)
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      //color: theme.accentColor,
      color: Colors.yellow.shade700,
      elevation: 4.0,
      child: IconTheme.merge(
        data: theme.accentIconTheme,
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
        ),
      ),
    );
  }
}
