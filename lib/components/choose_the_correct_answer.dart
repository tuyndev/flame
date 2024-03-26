import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_lib/entity/content-entity.dart';
import 'package:just_audio/just_audio.dart';

final alphabets =
    List.generate(26, (index) => String.fromCharCode(index + 65)).toList();

final colors = [
  const Color(0xFFff4600),
  const Color(0xFFffc800),
  const Color(0xFF00a0ff),
  const Color(0xFF00b478)
];

class ChooseTheCorrectAnswer extends PositionComponent with TapCallbacks {
  double gap = 20, heightAnswer = 65;
  int colSpan = 2, countAnswer = 4;
  List<AnswerEntity> _answers = [];

  set answers(List<AnswerEntity> lstAnswerEntity) {
    _answers = lstAnswerEntity;
    updateSelectAnswer();
  }

  List<SelectAnswer> lstSelectAnswer = [];
  Function(String answers) onSelectedAnswer;

  ChooseTheCorrectAnswer({
    super.size,
    super.anchor,
    super.position,
    required this.onSelectedAnswer,
  }) {
    height = heightAnswer * 2 + gap;
    double widthAnswer = (width - ((colSpan - 1) * gap)) / colSpan,
        offsetX = widthAnswer / 2,
        offsetY = heightAnswer / 2;

    for (int index = 0; index < countAnswer; index++) {
      lstSelectAnswer.add(SelectAnswer(
          index: index,
          onSelectedAnswer: onSelectedAnswer,
          size: Vector2(widthAnswer, heightAnswer),
          position: Vector2(offsetX, offsetY)));
      double wrapX = offsetX + widthAnswer + gap;
      offsetX = wrapX > width ? (widthAnswer / 2) : wrapX;
      offsetY = wrapX > width ? (offsetY + heightAnswer + gap) : offsetY;
    }
  }

  void updateSelectAnswer() {
    for (int index = 0; index < _answers.length; index++) {
      lstSelectAnswer[index].answer = _answers[index];
    }
  }

  @override
  Future<void> onLoad() async {
    for (SelectAnswer selectAnswer in lstSelectAnswer) {
      add(selectAnswer);
    }
    return super.onLoad();
  }
}

class SelectAnswer extends PositionComponent with TapCallbacks {
  double radius = 12;
  final int index;
  AnswerEntity? _answer;
  Function(String answers) onSelectedAnswer;

  set answer(AnswerEntity answerEntity) {
    _answer = answerEntity;
    updateTextContent();
  }

  late Rect rect;
  late RRect rrect;
  late TextComponent textContents;

  SelectAnswer(
      {required super.size,
      required this.onSelectedAnswer,
      required this.index,
      required super.position}) {
    anchor = Anchor.center;
    rect = Rect.fromLTRB(0, 0, width, height);
    rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
  }

  @override
  void onTapDown(TapDownEvent event) async {
    addAll([
      ScaleEffect.to(
        Vector2.all(0.95),
        EffectController(duration: 0.1),
      ),
      ScaleEffect.to(
        Vector2.all(1.05),
        EffectController(duration: 0.1, startDelay: 0.1),
      ),
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.1, startDelay: 0.2),
      ),
    ]);
    onSelectedAnswer(_answer?.content as String);
    super.onTapDown(event);
  }

  void updateTextContent() {
    print("_answer?.content ${_answer?.content}");
    textContents.text = _answer?.content as String;
  }

  @override
  Future<void> onLoad() async {
    textContents = TextBoxComponent(
      anchor: Anchor.center,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 18)),
      position: Vector2(((width - height) / 2) + height + 20, height / 2),
      boxConfig: TextBoxConfig(
        maxWidth: width - height,
      ),
    );
    addAll([
      RectangleComponent.square(
          size: height, paint: Paint()..color = colors[index]),
      RectangleComponent(
          paint: Paint()..color = Colors.white,
          size: Vector2(width - height, height),
          position: Vector2(height, 0)),
      TextComponent(
          text: alphabets[index],
          position: Vector2(height / 2, height / 2),
          anchor: Anchor.center),
      textContents
    ]);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // canvas.clipRRect(rrect);
    super.render(canvas);
  }
}
