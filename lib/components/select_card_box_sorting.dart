import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_flame_lib/entity/content-entity.dart';
import 'package:game_thithu/utils/ui_ultis.dart';

import '../games/game_controller.dart';

class SelectCardBoxSorting extends PositionComponent with HasGameRef<GameCtrl> {
  Sprite backgroundCard;
  Sprite backgroundIdleCard;
  final double ratioCard;
  final List<CardBox> lstCardBoxSorting = [];
  final List<CardBox> lstCardBoxIdle = [];

  List<AnswerEntity> _dataSource = [];
  set dataSource(List<AnswerEntity> lstAnswerEntity) {
    _dataSource = lstAnswerEntity;
    _arrIndexed = List.generate(lstAnswerEntity.length, (_) => null);
    updateCardBox();
  }

  final String Function(AnswerEntity detailsCard) renderContents;

  final double gapX = 20, gapY = 20, spaceBoxCards = 30, _minCol = 5;
  double _widthCard = 0, _heightCard = 0, _heightBoxCards = 0;

  final int _columnsNumber = 5;
  List<int?> _arrIndexed = [];

  // get attributes value
  set columnsNumber(int number) {
    columnsNumber = _columnsNumber;
  }

  // get attributes value
  List<int?> get arrIndexed => _arrIndexed;
  String get answersSorted => _arrIndexed
      .map((index) => _dataSource[index!].content)
      .toList()
      .join(" ");

  SelectCardBoxSorting({
    super.anchor,
    super.position,
    super.size,
    required this.ratioCard,
    required this.backgroundCard,
    required this.renderContents,
    required this.backgroundIdleCard,
  }) {
    _widthCard = (width - ((_columnsNumber - 1) * gapX)) / _columnsNumber;
    _heightCard = _widthCard * (1 / ratioCard);
    _arrIndexed = List.generate(_dataSource.length, (_) => null);

    int countRows = (_minCol / _columnsNumber).ceil();
    _heightBoxCards = ((countRows * _heightCard) + ((countRows - 1) * gapY));

    height = spaceBoxCards + (_heightBoxCards * 2);

    for (int index = 0; index < _minCol; index++) {
      lstCardBoxIdle.add(CardBox(
          size: Vector2(_widthCard, _heightCard),
          background: backgroundIdleCard,
          onTapSelectedBoxCard: _onTapSelectedBoxCard));
      lstCardBoxSorting.add(CardBox(
          size: Vector2(_widthCard, _heightCard),
          background: backgroundCard,
          onTapSelectedBoxCard: _onTapSelectedBoxCard));
    }
  }

  updateCardBox() {
    removeWhere((component) => component is CardBox);
    for (int index = 0; index < _dataSource.length; index++) {
      Vector2 offsetBoxIdle = _getBoxCardPosition(index: index);
      Vector2 offsetBoxSorting = _getBoxCardPosition(
          index: index, startY: _heightBoxCards + spaceBoxCards);

      CardBox cardBoxIdle = lstCardBoxIdle[index];
      CardBox cardBoxSorting = lstCardBoxSorting[index];

      cardBoxIdle
        ..index = index
        ..priority = index
        ..position = offsetBoxIdle;
      cardBoxSorting
        ..index = index
        ..position = offsetBoxSorting
        ..priority = (index + _columnsNumber)
        ..content = renderContents(_dataSource[index]);
      addAll([cardBoxIdle, cardBoxSorting]);
    }
  }

  Vector2 _getBoxCardPosition({required int index, double startY = 0}) {
    int position = (index / _columnsNumber).floor();
    int rowColumnNumber =
        ((position + 1) * _columnsNumber) <= _dataSource.length
            ? _columnsNumber
            : _dataSource.length % _columnsNumber;
    double startX = (width -
            ((_widthCard * rowColumnNumber) + (gapX * (rowColumnNumber - 1)))) /
        2;
    double offsetX = startX +
        ((_widthCard + gapX) * (index % _columnsNumber)) +
        _widthCard / 2;
    double offsetY =
        _heightCard / 2 + ((_heightCard + gapY) * position) + startY;
    return Vector2(offsetX, offsetY);
  }

  void _onTapSelectedBoxCard(int index) {
    final moveIndex = _arrIndexed.indexOf(null);
    final selectedIndex = _arrIndexed.indexWhere((indexed) => indexed == index);

    print("moveIndex $moveIndex");

    List<Effect> effects = [
      ScaleEffect.to(
        Vector2.all(0.9),
        EffectController(duration: 0.08, curve: Curves.linear),
      ),
      ScaleEffect.to(
        Vector2.all(1.1),
        EffectController(
            duration: 0.08, startDelay: 0.08, curve: Curves.linear),
      ),
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(
            duration: 0.08, startDelay: 0.16, curve: Curves.linear),
      ),
    ];

    if (selectedIndex == -1) {
      _arrIndexed[moveIndex] = index;
      final movingPosition = _getBoxCardPosition(index: moveIndex);
      lstCardBoxSorting[index].addAll([
        ...effects,
        MoveToEffect(
          movingPosition,
          EffectController(duration: 0, curve: Curves.linear),
        ),
      ]);
    } else {
      _arrIndexed[selectedIndex] = null;
      final movingPosition = _getBoxCardPosition(
          index: index, startY: _heightBoxCards + spaceBoxCards);
      lstCardBoxSorting[index].addAll([
        ...effects,
        MoveToEffect(
            movingPosition, EffectController(duration: 0, curve: Curves.linear))
      ]);
    }
  }
}

class CardBox<T> extends PositionComponent with TapCallbacks {
  int? index;
  String? _content;
  set content(String contents) {
    _content = contents;
    textContents.text = contents;
  }

  TextBoxComponent textContents = TextBoxComponent();
  final Sprite background;
  final Function(int index) onTapSelectedBoxCard;

  CardBox({
    super.size,
    super.position,
    required this.background,
    required this.onTapSelectedBoxCard,
  }) {
    anchor = Anchor.center;
  }
  @override
  Future<void> onLoad() async {
    textContents = TextBoxComponent(
      text: _content,
      size: size,
      align: Anchor.center,
      textRenderer: TextPaint(
          style: const TextStyle(
              fontSize: 18, color: Colors.brown, fontWeight: FontWeight.bold)),
    );
    add(SpriteComponentRatio(sprite: background, size: Vector2(width, height)));
    add(textContents);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_content == null) return;
    onTapSelectedBoxCard(index!);
    super.onTapDown(event);
  }
}
