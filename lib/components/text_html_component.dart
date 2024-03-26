import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

enum TextLineHtmlType { normal, empty }

enum TextHtmlType { underline, normal, color }

mixin TextHtmlRender {
  late final TextStyle _style;
  TextPainter getLineMetrics(String text) =>
      TextPaint(textDirection: TextDirection.ltr, style: _style)
          .toTextPainter(text);
}

class TexElementHtml extends PositionComponent {
  String text;
  final TextHtmlType type;
  final TextStyle style;
  TexElementHtml(
      {required this.text, required this.type, required this.style}) {
    final underRegex = RegExp(r'(<u>|</u>)');
    text = text.replaceAll(underRegex, "");
  }
  @override
  Future<void> onLoad() async {
    add(TextComponent(
        text: text,
        textRenderer: TextPaint(
            style: style.merge(TextStyle(
                decoration: type == TextHtmlType.underline
                    ? TextDecoration.underline
                    : TextDecoration.none)))));
    return super.onLoad();
  }
}

class TextLineHtml extends PositionComponent with TextHtmlRender {
  final TextLineHtmlType type;
  final int line;
  final List<TexElementHtml> _lstText = [];
  String get lstTextString => _lstText.map((e) => e.text).toList().join("");

  TextLineHtml({
    super.size,
    required this.line,
    required TextStyle style,
    this.type = TextLineHtmlType.normal,
  }) {
    _style = style;
  }

  void updateBounds() {
    double startX = (width - getLineMetrics(lstTextString).width) / 2;
    for (TexElementHtml textElement in _lstText) {
      textElement.position = Vector2(startX, 0);
      startX += getLineMetrics(textElement.text).width;
      add(textElement);
    }
  }

  void put(TexElementHtml text) {
    _lstText.add(text);
    updateBounds();
  }
}

class ContainerTextBoxHtml extends PositionComponent with TextHtmlRender {
  final String html;
  final Anchor align;
  late double _heightBox;
  late final double _lineHeight;
  final List<TexElementHtml> _lstRaw = [];
  final List<TextLineHtml> _textLine = [];
  List<TextLineHtml> get textLine => _textLine;
  int get totalsLine => _textLine.length;

  final TextStyle _defaultStyle =
      const TextStyle(fontSize: 16, height: 1.5, color: Colors.white);

  ContainerTextBoxHtml(
      {super.size,
      super.anchor,
      super.position,
      required this.align,
      required this.html,
      TextStyle? style}) {
    _heightBox = height;
    _style = _defaultStyle.merge(style);
    _lineHeight = _style.fontSize! * _style.height!;

    bool isUnderline = false;
    final startUnderRegex = RegExp(r'^<u>');
    final endUnderRegex = RegExp(r'<\/u>$');

    html.split(" ").forEach((text) {
      if (text.contains(startUnderRegex)) isUnderline = true;
      _lstRaw.add(TexElementHtml(
          text: text,
          style: _style,
          type: isUnderline ? TextHtmlType.underline : TextHtmlType.normal));
      if (text.contains(endUnderRegex)) isUnderline = false;
    });

    updateTextBox();
    height = _calculateHeight;
    position = Vector2(0, _alignOffsetY);
  }

  void updateTextBox() {
    for (TexElementHtml textHtml in _lstRaw) {
      final wordLines = textHtml.text.split("\n");
      String possibleLine = _textLine.isEmpty
          ? wordLines.last
          : '${_textLine.last.lstTextString} ${wordLines.last}';
      bool canPutLine = getLineMetrics(possibleLine).width <= width;

      for (String word in wordLines) {
        if (word.isEmpty && textHtml.text.isNotEmpty) {
          _textLine.add(TextLineHtml(
            style: _style,
            line: _textLine.length,
            type: TextLineHtmlType.empty,
            size: Vector2(width, _lineHeight),
          ));
        } else {
          if (_textLine.isEmpty ||
              canPutLine == false ||
              _textLine.last.type == TextLineHtmlType.empty) {
            _textLine.add(TextLineHtml(
              style: _style,
              line: _textLine.length,
              size: Vector2(width, _lineHeight),
            ));
          }
          textHtml.text = " $word";
          _textLine.last.put(textHtml);
        }
      }
    }
  }

  double get _calculateHeight => totalsLine * _lineHeight;

  double get _alignOffsetY {
    switch (align) {
      case Anchor.center:
        return _calculateHeight > _heightBox
            ? 0
            : (_heightBox - _calculateHeight) / 2;
      default:
        return 0;
    }
  }

  @override
  Future<void> onLoad() async {
    for (TextLineHtml textLine in _textLine) {
      textLine.position = Vector2(0, _lineHeight * textLine.line);
      add(textLine);
    }
    return super.onLoad();
  }
}

class TextBoxHtml extends PositionComponent {
  final String html;
  final Anchor align;
  TextStyle? style;
  late final Rect rect;
  TextBoxHtml(
      {this.style,
      super.size,
      super.anchor,
      required this.html,
      this.align = Anchor.topCenter,
      super.position});
  @override
  Future<void> onLoad() async {
    rect = Rect.fromLTRB(0, 0, width, height);
    add(ContainerTextBoxHtml(
      html: html,
      align: align,
      style: style,
      size: Vector2(width, height),
    ));
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    canvas.clipRect(rect);
    super.render(canvas);
  }
}
