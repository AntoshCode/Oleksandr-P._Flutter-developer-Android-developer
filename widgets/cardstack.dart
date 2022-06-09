import 'package:adviser/adviser/fca/app/components/app_image/app_image.dart';
import 'package:adviser/adviser/fca/app/styles/ui_style/base_style.dart';
import 'package:adviser/adviser/fca/app/styles/ui_style/card/card_style.dart';
import 'package:adviser/adviser/fca/data/enums/app_enums.dart';
import 'package:adviser/adviser/fca/data/helpers/debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardItemData {
  final String title;
  final String description;
  final AccountType type;
  late final CardStyle style;

  CardItemData({
    required this.type,
    this.title = '',
    this.description = '',
  }) {
    switch (type) {
      case AccountType.personal:
        style = CardStyle();
        break;
      case AccountType.business:
        style = GoldCardStyle();
        break;
    }
  }

  @override
  String toString() {
    return "CardItemData($title)";
  }
}

class CardStack extends StatefulWidget {
  final Function(AccountType)? onChange;
  final List<CardItemData> cards;

  CardStack({required this.cards, this.onChange});

  @override
  State<StatefulWidget> createState() => _State(cards);
}

class _State extends State<CardStack> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<CardItemData> cardsList;
  final Debounce slideTimeGap = TimeGap();
  final Debounce helperAnimationDebounce = Debounce();
  AccountType type = AccountType.personal;
  bool helperAnimatedShowed = false;
  bool helperAnimatedRunning = false;

  _State(this.cardsList);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    helperAnimationDebounce.cancel();
    slideTimeGap.cancel();
    _controller.dispose();
    super.dispose();
  }

  stateUpdate() {
    final CardItemData firstItem = cardsList.last;
    this.setState(() {
      cardsList.removeLast();
      cardsList.insert(0, firstItem);
    });
    if (widget.onChange != null) widget.onChange!(cardsList.last.type);
  }

  helperAnimation() async {
    helperAnimationDebounce.run(
      action: () async {
        if (helperAnimatedShowed || helperAnimatedRunning) return;
        helperAnimatedRunning = true;
        await _controller
            .animateTo(0.1,
                duration: Duration(milliseconds: 300), curve: Curves.easeIn)
            .orCancel;
        await _controller
            .animateTo(0.0,
                duration: Duration(milliseconds: 200), curve: Curves.easeOut)
            .orCancel;
        await _controller
            .animateTo(0.15,
                duration: Duration(milliseconds: 450), curve: Curves.easeIn)
            .orCancel;
        await _controller
            .animateTo(0.0,
                duration: Duration(milliseconds: 400), curve: Curves.easeOut)
            .orCancel;
        _controller.reset();
        helperAnimatedRunning = false;
      },
      milliseconds: 3000,
    );
  }

  slide(DragUpdateDetails details) async {
    if (helperAnimatedRunning) return;
    helperAnimatedShowed = true;
    int sensitivity = 3;
    if (details.delta.dy > sensitivity) {
      return;
    } else if (details.delta.dy < -sensitivity) {
      slideTimeGap.run(
          action: () async {
            await _controller
                .animateTo(1,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOutCirc)
                .orCancel;
            stateUpdate();
            _controller.reset();
          },
          milliseconds: 500);
    }
  }

  AnimatedWidget animatedCard({
    required String title,
    required String description,
    required CardStyle style,
    bool first = false,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final percent = Curves.easeInOutCirc.transform(_controller.value);
        if (first) {
          final slideDistance = percent < 0.5
              ? Tween<double>(begin: 0, end: -200).animate(_controller).value
              : Tween<double>(begin: -400, end: 0).animate(_controller).value;
          final horizontalPadding =
              Tween<double>(begin: 0, end: 18).animate(_controller).value;
          final opacity = percent < 0.5
              ? Tween<double>(begin: 1, end: 1).animate(_controller).value
              : Tween<double>(begin: 3, end: 0).animate(_controller).value;
          return Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Opacity(
                opacity: opacity > 1 ? 1 : opacity,
                child: Transform.translate(
                  offset: Offset(0, slideDistance),
                  child: child,
                ),
              ));
        } else {
          final horizontalPadding = percent < 0.5
              ? Tween<double>(begin: 18, end: 0).animate(_controller).value
              : Tween<double>(begin: 18, end: 0).animate(_controller).value;
          final topPadding = percent < 0.5
              ? Tween<double>(begin: 15, end: 60).animate(_controller).value
              : Tween<double>(begin: 60, end: 0).animate(_controller).value;
          return Container(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
            ),
            child: AnimatedPadding(
              padding: EdgeInsets.only(top: topPadding),
              duration: Duration(milliseconds: 120),
              child: ShaderMask(
                blendMode: percent < 0.1 ? BlendMode.srcIn : BlendMode.dst,
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: style.gradient.colors
                        .map((color) => color.withOpacity(0.75))
                        .toList(),
                    tileMode: TileMode.repeated,
                  ).createShader(bounds);
                },
                child: Transform.translate(
                  offset: Offset(0, 0),
                  child: child,
                ),
              ),
            ),
          );
        }
      },
      child: card(title: title, description: description, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    helperAnimation();
    return body(
      cards: [
        for (int i = 0; i < cardsList.length; i++)
          animatedCard(
            title: cardsList[i].title,
            description: cardsList[i].description,
            style: cardsList[i].style,
            first: i == (cardsList.length - 1),
          )
      ],
    );
  }

  Widget body({required List<Widget> cards}) {
    return Container(
      height: 312,
      child: GestureDetector(
        onVerticalDragUpdate: slide,
        child: Stack(
          alignment: Alignment.topCenter,
          children: cards,
        ),
      ),
    );
  }

  Widget card({required String title, required CardStyle style, description}) {
    return Container(
      height: style.height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: style.gradient,
        borderRadius: BorderRadius.circular(BaseStyle.defaultRadiusLargeCard),
      ),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: AppImage(
              height: style.imageHeight,
              width: style.imageWidth,
              fit: BoxFit.none,
              alignment: Alignment.bottomRight,
              path: style.imagePath,
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  title,
                  style: style.titleTextStyle,
                )),
            Container(
                width: style.descriptionWidth,
                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                  description,
                  style: style.descriptionTextStyle,
                )),
          ])
        ],
      ),
    );
  }
}
