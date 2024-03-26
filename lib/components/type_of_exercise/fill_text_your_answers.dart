import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_lib/common/observer.dart';
import 'package:flutter_flame_lib/controllers/game_data_controller.dart';
import 'package:flutter_flame_lib/entity/content-entity.dart';
import 'package:flutter_flame_lib/entity/question-entity.dart';
import 'package:flutter_flame_lib/entity/user-answer-entity.dart';
import 'package:game_thithu/games/game_controller.dart';
import 'package:game_thithu/games/game_data.dart';
import 'package:game_thithu/utils/ui_ultis.dart';
import 'package:game_thithu/worlds/exam_test_world.dart';

import '../../observer/game_observer.dart';
import '../audio_player_preview.dart';
import '../button_sprite.dart';
import '../image_zoom_viewer.dart';
import '../modal_sprite.dart';

class FillTextYourAnswer extends ComponentTab {
  FillTextYourAnswer({super.size, super.position}) {
  }

  Component renderDescription(DescriptionEntity descriptionEntity) {
    final type = descriptionEntity.type;
    final content = descriptionEntity.content;
    switch (type) {
      case CONTENT_TYPE.IMAGE:
        return ImageZoomViewer(
            height: 170,
            position: Vector2(width / 2, 30),
            sprite: Sprite(game.images.fromCache(content.getFileName)));
      case CONTENT_TYPE.AUDIO:
        return AudioPlayerPreview(
            position: Vector2(width / 2, 140),
            size: Vector2.all(115),
            url: content);
      default:
        return Component();
    }
  }

  void onSendAnswers() async {
    final answerFillBlank = globalDataGame.answerFillBlank;
    if (globalDataGame.answerFillBlank == null ||
        answerFillBlank!.length < globalDataGame.answerBlankLength) {
      ModalSprite modalSprite = ModalSprite(
        cancelText: "OK",
        content: "Bạn cần điền hết các chỗ trống !",
        background: SpriteComponent(
            sprite: Sprite(game.images.fromCache("bg_modal.png")),
            size: Vector2(400, 350)),
        cancelSprite: Sprite(
          game.images.fromCache("bg_button--red.png"),
        ),
      );
      messagesObserver.post(MESSAGE_OBSERVER_TYPE.OPEN_MODAL, null);
      world.router.pushAndWait(modalSprite);
    } else {
      final currentQuestion = gameDataCtl.currentQuestion;
      gameDataCtl.answerQuestion(
          UserAnswerEntity(
              ans: answerFillBlank,
              questId: currentQuestion!.id,
              point: currentQuestion!.Point,
              position: gameDataCtl.currentIndex + 1),
          (code, message) => {});
    }
  }

  @override
  void onLoad() async {
    add(ButtonSprite(
      title: "ANSWER",
      size: Vector2(110, 45),
      onPressed: onSendAnswers,
      position: Vector2(width - 105, height - 80),
      background: Sprite(game.images.fromCache("bg_button.png")),
    ));
    return super.onLoad();
  }

}
