import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:game_thithu/games/game_controller.dart';
import 'package:game_thithu/utils/ui_ultis.dart';
import 'package:game_thithu/worlds/exam_test_world.dart';

import '../observer/game_observer.dart';

class ImageZoomViewer extends PositionComponent {
  final double height;
  final Sprite sprite;
  ImageZoomViewer(
      {required this.height, required this.sprite, super.position}) {
    anchor = Anchor.topCenter;
    final ratioSprite = sprite.aspectRatio;
    size = Vector2(height * ratioSprite, height);
  }
  @override
  Future<void> onLoad() async {
    add(SpriteComponentRatio(sprite: sprite, size: size));
    add(ZoomIcon(position: Vector2(width - 22, height - 22), image: sprite));
    return super.onLoad();
  }
}

class ZoomIcon extends RectangleComponent
    with HasGameRef<GameCtrl>, HasWorldReference<ExamTestWorld>, TapCallbacks {
  final Sprite image;
  late Sprite _sprite;
  late Rect rect;
  late RRect rrect;

  ZoomIcon({super.position, required this.image}) {
    anchor = Anchor.center;
    paint = Paint()..color = Colors.black54;

  }
  @override
  Future<void> onLoad() async {
    _sprite = Sprite(game.images.fromCache("icon_kinhlup.png"));
    final ratioSprite = _sprite.aspectRatio;

    size = Vector2(35, 35 / ratioSprite);

    rect = Rect.fromLTRB(0, 0, width, height);
    rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    add(SpriteComponentRatio(
        sprite: _sprite,
        position: Vector2.all(4),
        size: Vector2(width - 8, height - 8)));
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // canvas.clipRRect(rrect);
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    addAll([
      ScaleEffect.to(
        Vector2.all(1.1),
        EffectController(duration: 0.08),
      ),
      ScaleEffect.to(
        Vector2.all(0.9),
        EffectController(duration: 0.08, startDelay: 0.08),
      ),
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.08, startDelay: 0.16),
      ),
    ]);
    messagesObserver.post(MESSAGE_OBSERVER_TYPE.OPEN_MODAL, null);
    world.router.pushAndWait(PreviewImageModal(image: image));
    super.onTapDown(event);
  }
}

class PreviewImageModal extends ValueRoute<dynamic>
    with TapCallbacks, HasGameRef<GameCtrl>, TapCallbacks {
  final Sprite image;

  PreviewImageModal({required this.image})
      : super(value: null, transparent: true);

  @override
  Component build() {
    return PreviewImageBuilder(image: image, complete: complete);
  }
}

class PreviewImageBuilder extends RectangleComponent
    with HasGameRef<GameCtrl>, TapCallbacks {
  final Sprite image;
  final Function() complete;
  PreviewImageBuilder({required this.image, required this.complete});
  @override
  void onClosePreviewImage() {
    messagesObserver.post(MESSAGE_OBSERVER_TYPE.CLOSE_MODAL, null);
    add(RemoveEffect(delay: 0.2));
    complete();
  }

  @override
  Future<void> onLoad() async {
    size = game.size;
    paint = Paint()..color = const Color.fromRGBO(0, 0, 0, 0.8);
    add(SpriteComponentRatio(
        scale: Vector2.all(0),
        sprite: image,
        children: [
          ScaleEffect.to(
            Vector2.all(1),
            EffectController(
                duration: 0.3, curve: Curves.fastLinearToSlowEaseIn),
          )
        ],
        size: getAspectRatioVector(
            width: width * 0.6,
            height: height * 0.6,
            aspectRatio: image.aspectRatio),
        anchor: Anchor.center,
        position: size / 2));
    add(SpriteClose(
        onTouch: onClosePreviewImage,
        size: Vector2.all(40),
        position: Vector2(width - 60, 20)));
    return super.onLoad();
  }
}

class SpriteClose extends PositionComponent
    with HasGameRef<GameCtrl>, TapCallbacks {
  final Function() onTouch;
  SpriteClose({super.size, super.position, required this.onTouch});
  @override
  Future<void> onLoad() async {
    final sprite = Sprite(game.images.fromCache("close_icon.png"));
    final spriteComponents = SpriteComponentRatio(sprite: sprite, size: size);
    add(spriteComponents);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTouch();
    super.onTapDown(event);
  }
}
