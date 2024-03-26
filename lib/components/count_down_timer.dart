import 'dart:async';

import 'package:flame/components.dart' hide Timer;
import 'package:flutter/material.dart';
import 'package:game_thithu/games/game_data.dart';
import 'package:game_thithu/utils/ui_ultis.dart';

import '../games/game_controller.dart';

class CountdownTimer extends PositionComponent with HasGameRef<GameCtrl> {
  late int _limit;
  void Function() onFinish;
  late TextComponent timerText;
  final Vector2 offset = Vector2.zero();

  final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      height: 1,
      color: Colors.white,
    ),
  );

  CountdownTimer(
      {required this.onFinish,
      super.anchor,
      required int limit,
      super.position}) {
    _limit = limit;
    size = Vector2(100, 28);
  }

  @override
  Future<void> onLoad() async {
    return super.onLoad();
  }

  @override
  void onMount() {
    if (_limit != null && _limit > 0) {
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (globalDataGame.isDoneTimer == true) {
          timer.cancel();
        } else if (_limit == 1) {
          _limit = 0;
          onFinish();
          timer.cancel();
        } else {
          _limit--;
        }
      });
    }
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    textPaint.render(canvas, _limit.formattedTime, offset);
    super.render(canvas);

  }
}
