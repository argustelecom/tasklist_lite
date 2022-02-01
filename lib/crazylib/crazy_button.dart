import 'package:flutter/material.dart';

class CrazyButton extends StatelessWidget {
  CrazyButton(
      {Key? key,
      this.padding =
          const EdgeInsets.only(bottom: 8, top: 8, left: 32, right: 8),
      required this.title,
      required this.onPressed})
      : super(key: key);
  final EdgeInsetsGeometry padding;
  final String title;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: this.padding,
        child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32))),
              elevation: MaterialStateProperty.all<double>(5),
              // minimumSize: MaterialStateProperty.all<Size>(Size.fromWidth(200)),
              backgroundColor:
                  // #TODO: зачем это: https://stackoverflow.com/questions/66476548/flutter-textbutton-padding  ??
                  MaterialStateProperty.all<Color>(Colors.yellow.shade700),
              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(2)),
            ),
            child: Text(
              this.title,
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            onPressed: onPressed),
      ),
    );
  }
}
