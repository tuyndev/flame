import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_lib/common/observer.dart';
import 'package:flutter_flame_lib/controllers/game_data_controller.dart';
import 'package:flutter_flame_lib/entity/question-entity.dart';
import 'package:flutter_flame_lib/entity/user-answer-entity.dart';
import 'package:game_thithu/games/game_controller.dart';
import 'package:game_thithu/games/game_data.dart';
import 'package:game_thithu/utils/ui_ultis.dart';
import 'package:game_thithu/worlds/exam_test_world.dart';

import '../button_sprite.dart';
import '../modal_sprite.dart';
import '../select_card_box_sorting.dart';

class SortYourAnswers extends ComponentTab {
  late final SelectCardBoxSorting selectCardBoxSorting;
  String? name;
  SortYourAnswers({super.size, super.position, this.name}) {}

  void onSendAnswers() async {
    bool answersNotEmpty =
        selectCardBoxSorting.arrIndexed.every((answer) => answer != null);
    if (!answersNotEmpty) {
      ModalSprite modalSprite = ModalSprite(
        cancelText: "OK",
        content: "Bạn cần sắp xếp hết các câu trả lời !",
        background: SpriteComponent(
            sprite: Sprite(game.images.fromCache("bg_modal.png")),
            size: Vector2(300, 350)),
        cancelSprite: Sprite(
          game.images.fromCache("bg_button--red.png"),
        ),
      );
      world.router.pushAndWait(modalSprite);
    } else {
      final currentQuestion = gameDataCtl.currentQuestion;
      gameDataCtl.answerQuestion(
          UserAnswerEntity(
              ans: selectCardBoxSorting.answersSorted,
              questId: currentQuestion!.id,
              point: currentQuestion!.Point,
              position: gameDataCtl.currentIndex + 1),
          (code, message) => {});
    }
  }

  @override
  Future<void> onLoad() async {
    selectCardBoxSorting = SelectCardBoxSorting(
        ratioCard: 150 / 200,
        anchor: Anchor.center,
        size: Vector2(width * 0.8, 0),
        position: Vector2(width / 2, (height - 40) / 2),
        backgroundCard: globalSprite.sprite("select_card.png"),
        backgroundIdleCard: globalSprite.sprite("idle_select_card.png"),
        renderContents: (details) => details.content);
    //
    // add(selectCardBoxSorting);

    add(ButtonSprite(
      title: "ANSWER",
      size: Vector2(110, 45),
      onPressed: onSendAnswers,
      position: Vector2(width - 105, height - 50),
      background: globalSprite.sprite("bg_button.png"),
    ));

    return super.onLoad();
  }

}
