import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// #TODO: объединить с классом ниже. В идеале, должен быть единый виджет логотипа, поддерживающий
// и горизонтальную и вертикальную компоновки, текст и перед, и после логотипа, поддерживающий
// и анимацию (или ее отсутствие)
// #TODO: еще использовать этот виджет и на страничке AboutPage
class FigaroLogoHorizontal extends StatelessWidget {
  /// #TODO: для правильного отображения (в составе appBar -- посередине, в составе body -- в начале колонки)
  /// приходится управлять alignment внутри колонки. При обобщении вместе с AnimatedLogo, по аналогии с тем,
  /// как сделано например у FlutterLogo, управлять позиционированием надо будет как-то умнее.
  final MainAxisAlignment columnAlignment;

  FigaroLogoHorizontal({required this.columnAlignment});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: columnAlignment,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 75,
                child: Image.asset(
                  // внимательней, хотсвап не подцепляет изменения в asset, надо делать полную пересборку
                  "images/logo_figaro.png",
                  bundle: rootBundle,
                ),
              ),
            ),
            Text("Фигаро",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

// #TODO: объединить с классом выше. В идеале, должен быть единый виджет логотипа, поддерживающий
// и горизонтальную и вертикальную компоновки, текст и перед, и после логотипа, поддерживающий
// и анимацию (или ее отсутствие)
// #TODO: параметризовать размеры, кривую анимации, длительность
class AnimatedLogo extends StatefulWidget {
  final String assetName;

  AnimatedLogo({required this.assetName});
  @override
  State<StatefulWidget> createState() {
    return AnimatedLogoState(assetName: this.assetName);
  }
}

class AnimatedLogoState extends State<AnimatedLogo> {
  final String assetName;

  bool tapped = false;

  AnimatedLogoState({required this.assetName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          tapped = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.bounceOut,
        onEnd: () {
          setState(() {
            tapped = false;
          });
        },
        height: tapped ? 220 : 180,
        width: tapped ? 220 : 180,
        child: Image.asset(
          // внимательней, хотсвап не подцепляет изменения в asset, надо делать полную пересборку
          assetName,
          bundle: rootBundle,
        ),
      ),
    );
  }
}
