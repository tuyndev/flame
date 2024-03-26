import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_lib/common/observer.dart';
import 'package:flutter_flame_lib/controllers/game_data_controller.dart';
import 'package:flutter_flame_lib/entity/content-entity.dart';
import 'package:flutter_flame_lib/entity/question-entity.dart';
import 'package:flutter_flame_lib/entity/user-answer-entity.dart';
import 'package:game_thithu/components/choose_the_correct_answer.dart';
import 'package:game_thithu/components/image_zoom_viewer.dart';
import 'package:game_thithu/games/game_controller.dart';
import 'package:game_thithu/utils/ui_ultis.dart';

import '../audio_player_preview.dart';
import '../text_html_component.dart';

class ChooseYourAnswer extends ComponentTab {
  // late final Component imageZoomViewer;
  // late final Component audioPlayerPreview;
  // late final Component textBoxHtml;

  Component? contents;
  Component? description;
  late final ChooseTheCorrectAnswer chooseTheCorrectAnswer;

  ChooseYourAnswer({super.size, super.position}) {
  }

  Component renderDescription(DescriptionEntity descriptionEntity) {
    final type = descriptionEntity.type;
    final content = descriptionEntity.content;
    switch (type) {
      case CONTENT_TYPE.IMAGE:
        return ImageZoomViewer(
            height: 180,
            position: Vector2(width / 2, 0),
            sprite: Sprite(game.images.fromCache(content.getFileName)));
      case CONTENT_TYPE.AUDIO:
        return AudioPlayerPreview(
            position: Vector2(width / 2, 90),
            size: Vector2.all(110),
            url: content);
      default:
        return Component();
    }
  }

  Component renderContent(ContentEntity contentEntity) {
    final type = contentEntity.type;
    final content = contentEntity.content;
    final desContent = gameDataCtl.currentQuestion?.Description.content;

    switch (type) {
      case CONTENT_TYPE.TEXT:
        return TextBoxHtml(
          anchor: (desContent == null || desContent.isEmpty)
              ? Anchor.center
              : Anchor.topCenter,
          align: (desContent == null || desContent.isEmpty)
              ? Anchor.center
              : Anchor.topCenter,
          position: Vector2(width / 2, 200),
          style: const TextStyle(
              fontSize: 25,
              height: 1.35,
              color: Colors.white,
              fontFamily: "Lato"),
          html: content,
          size: Vector2(width * 0.9, 200),
        );
      default:
        return Component();
    }
  }

  void onSelectedAnswer(String answers) {
    final currentQuestion = gameDataCtl.currentQuestion;
    gameDataCtl.answerQuestion(
        UserAnswerEntity(
            ans: answers,
            questId: currentQuestion!.id,
            point: currentQuestion!.Point,
            position: gameDataCtl.currentIndex + 1),
        (code, message) => {});
  }

  @override
  void onLoad() async {
    chooseTheCorrectAnswer = ChooseTheCorrectAnswer(
        anchor: Anchor.topCenter,
        size: Vector2(width * 0.95, 0),
        onSelectedAnswer: onSelectedAnswer,
        position: Vector2(width / 2, height - 160));

    add(chooseTheCorrectAnswer);

    return super.onLoad();
  }
  

}
