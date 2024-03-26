import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_lib/controllers/game_data_controller.dart';
import 'package:game_thithu/games/game_controller.dart';

import '../utils/ui_ultis.dart';

enum MenuSelectItemsStatus { idle, selected, disable }

class MenuSelectBar extends RectangleComponent {
  Function(int indexed) onChange;
  late MenuSelectTrack menuSelectTrack;
  late MenuSelectContainer menuSelectContainer;
  late Rect rect;
  late RRect rrect;

  final Paint borderPaint = Paint()
    ..strokeWidth = 6
    ..color = const Color(0xFF936241)
    ..style = PaintingStyle.stroke;

  MenuSelectBar({super.size, super.position, required this.onChange}) {
    anchor = Anchor.topCenter;
    rect = Rect.fromLTRB(0, 0, width, height);
    rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
  }

  void onTouchSelectItem(int indexed) {
    menuSelectTrack.onSelected(indexed);
    onChange(indexed);
  }

  void onGoToSelectItemIndex(int indexed) {
    menuSelectTrack.onGoToIndex(indexed);
  }

  @override
  Future<void> onLoad() async {
    menuSelectTrack = MenuSelectTrack(
        onTouchSelectItem: onTouchSelectItem,
        countItems: 200,
        size: Vector2(890, height - 10),
        position: size / 2);
    add(menuSelectTrack);
    add(ButtonAction(
        isFlip: true,
        anchor: Anchor.centerLeft,
        onTouch: menuSelectTrack.onPrevious,
        position: Vector2(10, height / 2)));
    add(ButtonAction(
        anchor: Anchor.centerLeft,
        onTouch: menuSelectTrack.onNext,
        position: Vector2(width - 45, height / 2)));
    menuSelectContainer = menuSelectTrack.menuSelectContainer;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // canvas.drawRRect(rrect, borderPaint);
    // canvas.clipRRect(rrect);
    super.render(canvas);
  }
}

class MenuSelectTrack extends PositionComponent {
  final double _gapX = 10, colNumber = 10;
  int _page = 1;
  late int _countPage;

  late Rect rect;
  late RRect rrect;
  late double widthMenutItems;
  late double widthMenuSelectContainer;
  late MenuSelectContainer menuSelectContainer;

  final int countItems;
  final Function(int indexed) onTouchSelectItem;

  MenuSelectTrack(
      {super.size,
      super.position,
      required this.onTouchSelectItem,
      required this.countItems}) {
    anchor = Anchor.center;
    final spaceX = (colNumber - 1) * _gapX;
    widthMenutItems = (width - spaceX) / colNumber;
    widthMenuSelectContainer = (width * colNumber) + spaceX;
    _countPage = (countItems / colNumber).ceil();
    rect = Rect.fromLTRB(0, 0, width, height);
    rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
  }

  void onSelected(int indexed) {
    menuSelectContainer.currentSelectItems = indexed;
    menuSelectContainer.updateMenuSelectItems();
  }

  void onNext({int step = 1}) {
    if (_page == _countPage) return;
    menuSelectContainer.add(MoveByEffect(
        Vector2(-(width + _gapX) * step, 0),
        EffectController(
            duration: 0.55, curve: Curves.fastEaseInToSlowEaseOut)));
    _page += step;
  }

  void onPrevious({int step = 1}) {
    if (_page == 1) return;
    menuSelectContainer.add(MoveByEffect(
        Vector2((width + _gapX) * step, 0),
        EffectController(
            duration: 0.55, curve: Curves.fastLinearToSlowEaseIn)));
    _page -= step;
  }

  void onGoToIndex(int indexed) {
    final newPage = ((indexed + 1) / colNumber).ceil();
    final rangePage = (newPage - _page).abs();

    if (newPage >= _page) {
      onNext(step: rangePage);
    } else {
      onPrevious(step: rangePage);
    }
    onSelected(indexed);
  }

  @override
  Future<void> onLoad() async {
    menuSelectContainer = MenuSelectContainer(
        gapX: _gapX,
        widthMenutItems: widthMenutItems,
        colNumber: colNumber,
        onTouchSelectItem: onTouchSelectItem,
        size: Vector2(widthMenuSelectContainer, height),
        countItems: countItems);
    add(menuSelectContainer);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // canvas.clipRRect(rrect);
    super.render(canvas);
  }
}

class MenuSelectContainer extends PositionComponent {
  final double gapX;
  final int countItems;
  final double widthMenutItems, colNumber;
  final Function(int indexed) onTouchSelectItem;
  int currentSelectItems = 0;

  MenuSelectContainer(
      {super.size,
      required this.gapX,
      required this.colNumber,
      required this.countItems,
      required this.onTouchSelectItem,
      required this.widthMenutItems});

  @override
  Future<void> onLoad() async {
    for (int index = 0; index < colNumber; index++) {
      final offsetX = ((widthMenutItems + gapX) * index) + widthMenutItems / 2;
      add(MenuSelectItems(
        index: index,
        onTouchSelectItem: onTouchSelectItem,
        position: Vector2(offsetX, height / 2),
        size: Vector2(widthMenutItems, height),
        status: index == currentSelectItems
            ? MenuSelectItemsStatus.selected
            : MenuSelectItemsStatus.idle,
      ));
    }
    return super.onLoad();
  }

  void updateMenuSelectItems() {
    final selectItems = children.query<MenuSelectItems>().toList();
    for (int index = 0; index < selectItems.length; index++) {
      selectItems[index].status = index == currentSelectItems
          ? MenuSelectItemsStatus.selected
          : MenuSelectItemsStatus.idle;
    }
  }
}

class MenuSelectItems extends PositionComponent
    with HasGameRef<GameCtrl>, TapCallbacks {
  final int index;
  late SpriteComponent _background;
  MenuSelectItemsStatus status;
  final Function(int indexed) onTouchSelectItem;
  late Sprite _bgIdle;
  late Sprite _bgSelected;

  bool get _isSelected => gameDataCtl.lstQuestion![index].userAnswer != null;

  MenuSelectItems(
      {super.size,
      required this.status,
      required this.onTouchSelectItem,
      super.position,
      required this.index}) {
    anchor = Anchor.center;
  }

  Sprite get _getSpriteBackground {
    switch (status) {
      case MenuSelectItemsStatus.selected:
        return _bgSelected;
      default:
        return _bgIdle;
    }
  }

  _getColorBackground() {
    _background.paint.color = _isSelected ? Colors.white38 : Colors.white;
  }

  @override
  Future<void> onLoad() async {
    _bgIdle = Sprite(game.images.fromCache("bg_button.png"));
    _bgSelected = Sprite(game.images.fromCache("bg_button--red.png"));

    _background =
        SpriteComponentRatio(sprite: _getSpriteBackground, size: size);
    _getColorBackground();
    add(_background);
    add(TextComponent(
        textRenderer: TextPaint(
            style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                height: 1,
                fontWeight: FontWeight.bold)),
        text: "${index + 1}",
        anchor: Anchor.center,
        position: size / 2));
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isSelected) return;
    addAll([
      ScaleEffect.to(
        Vector2(0.95, 1.05),
        EffectController(duration: 0.06, curve: Curves.linear),
      ),
      ScaleEffect.to(
        Vector2(1.05, 0.95),
        EffectController(
            duration: 0.06, startDelay: 0.06, curve: Curves.linear),
      ),
      ScaleEffect.to(
        Vector2(0.95, 1.05),
        EffectController(
            duration: 0.06, startDelay: 0.12, curve: Curves.linear),
      ),
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(
            duration: 0.06, startDelay: 0.24, curve: Curves.linear),
      ),
    ]);
    onTouchSelectItem(index);
  }

}

class ButtonAction extends PositionComponent
    with TapCallbacks, HasGameRef<GameCtrl> {
  final void Function() onTouch;
  bool isFlip;
  ButtonAction(
      {required this.onTouch,
      this.isFlip = false,
      super.anchor,
      super.position}) {
    size = Vector2(36, 42);
  }
  @override
  Future<void> onLoad() async {
    final background = SpriteComponentRatio(
        sprite: Sprite(game.images.fromCache("btn_menu.png")), size: size);
    if (isFlip == true) {
      background.flipHorizontallyAroundCenter();
    }
    add(background);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTouch();
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
    super.onTapDown(event);
  }
}
