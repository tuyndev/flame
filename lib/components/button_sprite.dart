import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:game_thithu/utils/ui_ultis.dart';

class ButtonSprite extends PositionComponent with TapCallbacks {
  final Sprite background;
  final String? title;
  final Function() onPressed;
  late final TextStyle _style;
  final TextStyle _defaultStyle =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1);

  ButtonSprite(
      {required this.background,
      required this.onPressed,
      TextStyle? style,
      super.size,
      super.position,
      this.title}) {
    _style = _defaultStyle.merge(style);

    anchor = Anchor.center;
  }
  @override
  Future<void> onLoad() async {
    add(SpriteComponentRatio(sprite: background, size: size));
    if (title != null) {
      add(TextComponent(
          textRenderer: TextPaint(style: _style),
          text: title,
          anchor: Anchor.center,
          position: size / 2));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    addAll([
      ScaleEffect.to(
        Vector2(0.8, 1.05),
        EffectController(duration: 0.07),
      ),
      ScaleEffect.to(
        Vector2(1.05, 0.95),
        EffectController(duration: 0.07, startDelay: 0.14),
      ),
      ScaleEffect.to(
        Vector2(0.95, 1.05),
        EffectController(duration: 0.07, startDelay: 0.21),
      ),
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.07, startDelay: 0.28),
      ),
    ]);
    onPressed.call();
  }
}
