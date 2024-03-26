import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_lib/controllers/game_data_controller.dart';
import 'package:game_thithu/components/count_down_timer.dart';
import 'package:game_thithu/games/game_controller.dart';
import 'package:game_thithu/games/game_data.dart';
import 'package:game_thithu/worlds/exam_test_world.dart';

import '../observer/game_observer.dart';
import '../utils/ui_ultis.dart';
import 'modal_sprite.dart';

class TaskInfoBar extends RectangleComponent {
  late final Rect rect;
  late final RRect rrect;

  TaskInfoBar({super.size, super.position}) {
    paint = Paint()..color = const Color(0xFFc8bbb7);
    rect = Rect.fromLTRB(0, 0, width, height);
    rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
  }

  @override
  Future<void> onLoad() async {
    add(TimerGame(size: Vector2(148, 50), position: Vector2(width / 2, 10)));
    add(TextComponent(
        text: gameDataCtl.examInfo!.user.AccountName,
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
            style: const TextStyle(
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        position: Vector2(width / 2, 76)));
    add(TextComponent(
        text: "ID: ${gameDataCtl.examInfo!.user.AccountId}",
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
            style: const TextStyle(
                fontSize: 16,
                height: 1,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        position: Vector2(width / 2, 106)));
    add(RectangleComponent(
        size: Vector2(width * 0.8, 2),
        position: Vector2(width / 2, 132),
        anchor: Anchor.topCenter));
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // canvas.clipRRect(rrect);
    super.render(canvas);
  }
}

class TimerGame extends RectangleComponent
    with HasGameRef<GameCtrl>, HasWorldReference<ExamTestWorld> {
  final Paint _borderPaint = Paint()
    ..strokeWidth = 4
    ..style = PaintingStyle.stroke
    ..color = Colors.white;
  late final Rect rect;
  late final RRect rrect;

  TimerGame({super.size, super.position}) {
    anchor = Anchor.topCenter;
    rect = Rect.fromLTRB(0, 0, width, height);
    paint = Paint()..color = const Color(0xFFa27c7c);
    rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
  }
  @override
  Future<void> onLoad() async {
    add(SpriteComponentRatio(
        sprite: Sprite(game.images.fromCache("timer_icon.png")),
        size: Vector2.all(36),
        anchor: Anchor.centerLeft,
        position: Vector2(10, height / 2)));
    add(CountdownTimer(
        onFinish: () {
          gameDataCtl.finishWithTimeout((success) async {
            messagesObserver.post(MESSAGE_OBSERVER_TYPE.OPEN_MODAL, null);
            globalDataGame.isDoneTimer = true;
            final finishModalSprite = FinishModalSprite(
                score: success["data"]["point"],
                timer: success["data"]["time"]);
            final statusFinish =
                await world.router.pushAndWait(finishModalSprite);
          }, (error) => {});
        },
        limit: gameDataCtl.examInfo!.examTime,
        anchor: Anchor.centerLeft,
        position: Vector2(56, (height / 2) + 4)));
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // canvas.drawRRect(rrect, _borderPaint);
    // canvas.clipRRect(rrect);
    super.render(canvas);
  }
}
