import 'package:flutter/material.dart';
import 'package:flutter_flame_lib/common/observer.dart';
import 'package:game_thithu/games/game_data.dart';
import 'package:game_thithu/observer/game_observer.dart';
import '../utils/ui_ultis.dart';

class FillTextToTheBlank extends StatefulWidget {
  final String context;
  const FillTextToTheBlank({required this.context, super.key});

  @override
  State<FillTextToTheBlank> createState() => _FillTextToTheBlankState();
}

class _FillTextToTheBlankState extends State<FillTextToTheBlank>
    with GameListenerMessage {
  double opacityOverlay = 1;

  @override
  void initState() {
    messagesObserver.subscribe(this);
    super.initState();
  }

  @override
  void dispose() {
    messagesObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  onMessage(String messageType, Map<String, dynamic>? extraData) {
    if (MESSAGE_OBSERVER_TYPE.CLOSE_MODAL.toValue == messageType) {
      setState(() {
        opacityOverlay = 1;
      });
    }
    if (MESSAGE_OBSERVER_TYPE.OPEN_MODAL.toValue == messageType) {
      setState(() {
        opacityOverlay = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const aspectRatio = 1280 / 720;
    final getAspectRatio = getAspectRatioVector(
        width: context.getWidth,
        height: context.getHeight,
        aspectRatio: aspectRatio);
    final fontSize = ((getAspectRatio.x / 1280) * 26);

    final regexPattern = RegExp(r"(?<=[*])(?=[^*])|(?<=[^*])(?=[*])");
    final parts = widget.context.split(regexPattern);
    final List<Widget> wrapText = [];

    for (String textParts in parts) {
      final splitText = textParts.split(" ");
      if (textParts.contains("*")) {
        wrapText.add(TextFieldBlank(
            maxLength: textParts.trim().length, fontSize: fontSize));
      } else {
        wrapText.addAll(List.generate(
            splitText.length,
            (index) => Text(
                "${splitText[index]}${splitText.length - 1 == index ? "" : " "}",
                textScaler: const TextScaler.linear(1),
                style: TextStyle(
                    fontSize: fontSize,
                    height: 1.5,
                    letterSpacing: 2,
                    color: Colors.white,
                    fontFamily: "Menlo-Regular"))).toList());
      }
    }
    return Opacity(
      opacity: opacityOverlay,
      child: Wrap(
          spacing: 0,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.spaceBetween,
          children: wrapText),
    );
  }
}

class TextFieldBlank extends StatefulWidget {
  final int maxLength;
  final double fontSize;
  const TextFieldBlank(
      {required this.maxLength, required this.fontSize, super.key});

  @override
  State<TextFieldBlank> createState() => _TextFieldBlankState();
}

class _TextFieldBlankState extends State<TextFieldBlank>
    with GameListenerMessage {
  final myFocus = FocusNode();
  final _textEditingController = TextEditingController();

  _TextFieldBlankState() {
    messagesObserver.subscribe(this);
  }

  @override
  void initState() {
    globalDataGame.answerBlankLength = widget.maxLength;
    myFocus.requestFocus();
    super.initState();
  }

  // @override
  // void didUpdateWidget(covariant TextFieldBlank oldWidget) {
  //   myFocus.requestFocus();
  //   globalDataGame.answerBlankLength = widget.maxLength;
  // }

  @override
  onMessage(String messageType, Map<String, dynamic>? extraData) {
    if (messageType == MESSAGE_OBSERVER_TYPE.CHANGE_FILL_QUESTION.toValue) {
      globalDataGame.answerFillBlank = null;
      _textEditingController.clear();
    }
  }

  @override
  void dispose() {
    messagesObserver.unsubscribe(this);
    _textEditingController.dispose();
    myFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mqData = MediaQuery.of(context);
    final mqDataNew = mqData.copyWith(textScaler: const TextScaler.linear(1));

    final Size size = (TextPainter(
            text: TextSpan(
                text: "w",
                style: TextStyle(
                    fontSize: widget.fontSize,
                    height: 1.35,
                    letterSpacing: 2,
                    fontFamily: "Menlo-Regular")),
            maxLines: 1,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;

    return SizedBox(
      width: size.width * widget.maxLength + 3,
      child: MediaQuery(
        data: mqDataNew,
        child: TextField(
          maxLength: widget.maxLength,
          textAlign: TextAlign.left,
          focusNode: myFocus,
          controller: _textEditingController,
          onChanged: (text) {
            globalDataGame.answerFillBlank = text;
          },
          cursorWidth: 3,
          cursorColor: Colors.red,
          style: TextStyle(
              fontSize: widget.fontSize,
              height: 1.5,
              letterSpacing: 2,
              color: Colors.white,
              fontFamily: "Menlo-Regular"),
          decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              counterText: ""),
        ),
      ),
    );
  }
}

class DrawLine extends CustomPainter {
  final int maxLength;
  final double fontSize;
  const DrawLine({required this.maxLength, required this.fontSize});

  Future<void> PaintLineDash(
      {required Offset start,
      required Offset end,
      required Canvas canvas}) async {
    double dashSpace = 3,
        dashWidth = (end.dx - ((maxLength - 1) * dashSpace)) / maxLength,
        startX = start.dx;

    final paint1 = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    while (startX < end.dx) {
      canvas.drawLine(
          Offset(startX, start.dy), Offset(startX + dashWidth, end.dy), paint1);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    PaintLineDash(
        canvas: canvas,
        start: Offset(0, fontSize * 1.5),
        end: Offset(size.width, fontSize * 1.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
