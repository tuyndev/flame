import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter_flame_lib/common/observer.dart';
import 'package:flutter_flame_lib/controllers/game_data_controller.dart';
import 'package:flutter_flame_lib/entity/question-entity.dart';
import 'package:game_thithu/components/button_sprite.dart';
import 'package:game_thithu/components/menu_select_bar.dart';
import 'package:game_thithu/components/task_info_bar.dart';
import 'package:game_thithu/components/type_of_exercise/fill_text_your_answers.dart';
import 'package:game_thithu/games/game_controller.dart';
import 'package:game_thithu/utils/ui_ultis.dart';
import 'package:game_thithu/worlds/exam_test_world.dart';

import '../components/count_down_timer.dart';
import '../components/modal_sprite.dart';
import '../components/type_of_exercise/choose_your_answers.dart';
import '../components/type_of_exercise/sort_your_answers.dart';
import '../games/game_data.dart';
import '../observer/game_observer.dart';


class MainScenes extends PositionComponent
    with
        TapCallbacks,
        HasWorldReference<ExamTestWorld>,
        HasGameRef<GameCtrl>,
        GameListenerMessage {

  late final MenuSelectBar menuSelectBar;
  late final Map<QUESTION_TYPE, ComponentTab> questionTab;
  ComponentTab? currentTab;

  MainScenes({super.size, super.position}) {
    gameDataCtl.gameObserver.subscribe(this);
    questionTab = {
      QUESTION_TYPE.CHOOSE_ONE_OF_FOUR: ChooseYourAnswer(
          size: Vector2(1000, 575), position: Vector2(26, 100)),

      QUESTION_TYPE.SENTENCE_ARRANGEMENT:
      SortYourAnswers(size: Vector2(1000, 575), position: Vector2(26, 100)),

      QUESTION_TYPE.WRITE_SPACE: FillTextYourAnswer(
          size: Vector2(1000, 575), position: Vector2(26, 100)),
    };
  }

  void onFinishGame() async {
    messagesObserver.post(MESSAGE_OBSERVER_TYPE.OPEN_MODAL, null);
    final modalSprite = ModalSprite(
      cancelText: "Nộp bài",
      okText: "Làm Tiếp",
      content: "Bạn chưa trả lời hết các câu hỏi. Bạn có chắc chắn muốn nộp"
          " bài không?",
      background: SpriteComponent(
          sprite: Sprite(game.images.fromCache("bg_modal.png")),
          size: Vector2(400, 350)),
      okSprite: Sprite(game.images.fromCache("bg_button.png")),
      cancelSprite: Sprite(game.images.fromCache("bg_button--red.png")),
    );

    final status = await world.router.pushAndWait(modalSprite);
    if (status == ModalSpriteActionType.cancel) {
      gameDataCtl.finishWithTimeout((success) async {
        messagesObserver.post(MESSAGE_OBSERVER_TYPE.OPEN_MODAL, null);
        final finishModalSprite = FinishModalSprite(
            score: success["data"]["point"], timer: success["data"]["time"]);
        await world.router.pushAndWait(finishModalSprite);
      }, (error) => {});
    }
  }


  void onQuestionSelected(int indexed) {
    gameDataCtl.goToQuestion(indexed);
  }

  void updateActiveQuestionTab() {
    final questionType = gameDataCtl.currentQuestion!.type;
    if (currentTab != null) {
      remove(currentTab!);
    }
    currentTab = questionTab[questionType];
    add(currentTab!);
  }

  @override
  onMessage(String messageType, Map<String, dynamic>? extraData) {
    if (messageType == MESSAGE_TYPE.CHANGE_QUESTION.toValue) {
      updateActiveQuestionTab();
    }
  }

  @override
  void onLoad() async {
    size = game.size;

    add(SpriteComponentRatio(
        size: size, sprite: Sprite(game.images.fromCache("bg_main.png"))));

    menuSelectBar = MenuSelectBar(
        size: Vector2(1000, 50),
        position: Vector2(528, 12),
        onChange: onQuestionSelected);

    updateActiveQuestionTab();

    add(ButtonSprite(
      title: "SUBMIT",
      size: Vector2(140, 58),
      onPressed: onFinishGame,
      position: Vector2(width - 114, 270),
      style: const TextStyle(fontWeight: FontWeight.bold),
      background: globalSprite.sprite("bg_button--red.png"),
    ));

    add(TaskInfoBar(
        size: Vector2(180, 200), position: Vector2(width - 200, 10)));

    return super.onLoad();
  }

  @override
  void onRemove() {
    gameDataCtl.gameObserver.unsubscribe(this);
    super.onRemove();
  }
}
