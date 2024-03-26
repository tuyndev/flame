import 'dart:html';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_lib/common/resource.dart';
import 'package:game_thithu/observer/game_observer.dart';

import '../games/game_controller.dart';
import '../utils/ui_ultis.dart';
import 'button_sprite.dart';

enum ModalSpriteActionType { confirm, cancel }

class ModalSprite extends ValueRoute<ModalSpriteActionType>
    with TapCallbacks, HasGameRef<GameCtrl> {
  final String content;
  final SpriteComponent background;
  final String cancelText;
  final Sprite cancelSprite;
  String? okText;
  Sprite? okSprite;

  ModalSprite({
    required this.content,
    required this.background,
    required this.cancelSprite,
    required this.cancelText,
    this.okSprite,
    this.okText,
  }) : super(value: ModalSpriteActionType.cancel, transparent: true);

  @override
  Component build() => ModalBuilder(
      background: background,
      content: content,
      cancelSprite: cancelSprite,
      completeWith: completeWith,
      cancelText: cancelText,
      okSprite: okSprite,
      okText: okText);
}

class ModalBuilder extends RectangleComponent
    with HasGameRef<GameCtrl>, TapCallbacks {
  final String content;

  String? okText;
  final String cancelText;

  Sprite? okSprite;
  final Sprite cancelSprite;
  final SpriteComponent background;

  final Function(ModalSpriteActionType value) completeWith;

  ModalBuilder(
      {required this.content,
      required this.background,
      required this.cancelSprite,
      required this.cancelText,
      required this.completeWith,
      this.okSprite,
      this.okText});
  @override
  Future<void> onLoad() async {
    size = game.size;
    paint = Paint()..color = Colors.black87;
    final container = PositionComponent(
        size: background.size,
        anchor: Anchor.center,
        scale: Vector2.all(0),
        position: game.size / 2);
    container.addAll([
      background,
      TextBoxComponent(
          text: content,
          size: Vector2(background.width, background.height * 0.6),
          anchor: Anchor.center,
          align: Anchor.center,
          position: background.size / 2,
          textRenderer: TextPaint(
              style: const TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold)),
          boxConfig: TextBoxConfig(
            margins: const EdgeInsets.symmetric(horizontal: 25),
          )),
      ModalAction(
        okText: okText,
        okSprite: okSprite,
        cancelText: cancelText,
        cancelSprite: cancelSprite,
        completeWith: completeWith,
        size: Vector2(background.width, 40),
        position: Vector2(0, background.height - 50),
      ),
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.3, curve: Curves.fastLinearToSlowEaseIn),
      ),
    ]);
    add(container);
    return super.onLoad();
  }
}

class ModalAction extends PositionComponent with HasGameRef<GameCtrl> {
  String? okText;
  final String cancelText;

  Sprite? okSprite;
  final Sprite cancelSprite;

  final Function(ModalSpriteActionType value) completeWith;

  ModalAction(
      {super.size,
      required this.cancelSprite,
      required this.cancelText,
      required this.completeWith,
      this.okText,
      this.okSprite,
      super.position});
  @override
  Future<void> onLoad() async {
    double gapY = 25,
        offsetX =
            50 + (width - 100 - (okSprite == null ? 0 : (100 + gapY))) / 2;
    add(ButtonSprite(
        title: cancelText,
        size: Vector2(100, 40),
        background: cancelSprite,
        position: Vector2(offsetX, 0),
        onPressed: () {
          messagesObserver.post(MESSAGE_OBSERVER_TYPE.CLOSE_MODAL, null);
          completeWith(ModalSpriteActionType.cancel);
        }));
    offsetX += 100 + gapY;
    if (okSprite != null) {
      add(ButtonSprite(
          title: okText,
          background: okSprite!,
          size: Vector2(100, 40),
          position: Vector2(offsetX, 0),
          onPressed: () {
            messagesObserver.post(MESSAGE_OBSERVER_TYPE.CLOSE_MODAL, null);
            completeWith(ModalSpriteActionType.confirm);
          }));
    }

    return super.onLoad();
  }
}

class FinishModalSprite extends ValueRoute<ModalSpriteActionType>
    with TapCallbacks, HasGameRef<GameCtrl> {
  final double score;
  final int timer;

  FinishModalSprite({
    required this.score,
    required this.timer,
  }) : super(value: ModalSpriteActionType.cancel, transparent: true);

  @override
  Component build() => FinishModalBuilder(
        timer: timer,
        score: score,
        completeWith: completeWith,
      );
}

class FinishModalBuilder extends RectangleComponent
    with HasGameRef<GameCtrl>, TapCallbacks {
  final double score;
  final int timer;

  final Function(ModalSpriteActionType value) completeWith;

  FinishModalBuilder({
    required this.timer,
    required this.score,
    required this.completeWith,
  });
  @override
  Future<void> onLoad() async {
    size = game.size;
    paint = Paint()..color = Colors.black87;
    final background = SpriteComponent(
        sprite: Sprite(game.images.fromCache("bg_modal.png")),
        size: Vector2(400, 350));
    final cancelSprite = Sprite(game.images.fromCache("bg_button--red.png"));

    final container = PositionComponent(
        size: background.size,
        anchor: Anchor.center,
        scale: Vector2.all(0),
        position: game.size / 2);
    container.addAll([
      background,
      TextComponent(
          text: "RESULT",
          anchor: Anchor.topCenter,
          position: Vector2(background.width / 2, 30),
          textRenderer: TextPaint(
              style: const TextStyle(
                  fontSize: 35,
                  height: 1.5,
                  color: Colors.brown,
                  fontWeight: FontWeight.bold))),
      TextComponent(
          text: "Score",
          anchor: Anchor.topCenter,
          position: Vector2(background.width / 2, 90),
          textRenderer: TextPaint(
              style: const TextStyle(
                  fontSize: 28,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.orangeAccent))),
      TextComponent(
          text: "$score",
          anchor: Anchor.topCenter,
          position: Vector2(background.width / 2, 130),
          textRenderer: TextPaint(
              style: const TextStyle(
                  fontSize: 28,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.orangeAccent))),
      TextComponent(
          text: "Your Total Time",
          anchor: Anchor.topCenter,
          position: Vector2(background.width / 2, 180),
          textRenderer: TextPaint(
              style: const TextStyle(
                  fontSize: 28,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.lightBlue))),
      TextComponent(
          text: timer.formattedTime,
          anchor: Anchor.topCenter,
          position: Vector2(background.width / 2, 220),
          textRenderer: TextPaint(
              style: const TextStyle(
                  fontSize: 28,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.lightBlue))),
      ButtonSprite(
          title: "OK",
          size: Vector2(100, 40),
          background: cancelSprite,
          position: Vector2(background.width / 2, background.height - 50),
          onPressed: () {
            Map<String, dynamic> params =
                queryStringFromUrl(window.location.href);
            window.location.replace(params["redirectUrl"]);
          }),
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.3, curve: Curves.fastLinearToSlowEaseIn),
      ),
    ]);
    add(container);
    return super.onLoad();
  }
}
