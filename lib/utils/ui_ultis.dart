import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_lib/common/observer.dart';
import 'package:game_thithu/games/game_controller.dart';
import '../generated/assets.dart';
import '../worlds/exam_test_world.dart';

extension GetContext on BuildContext {
  // get Height of Scaffold
  double get getHeight => MediaQuery.of(this).size.height;

  // get Width of Scaffold
  double get getWidth => MediaQuery.of(this).size.width;

  // get Padding of SafeArea
  EdgeInsets get getPadding => MediaQuery.of(this).padding;
}

extension Utils on int {
  String get formattedTime {
    int sec = this % 60;
    int min = (this / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute:$second";
  }
}

extension UtilsString on String {
  String get getFileName {
    final splitPath = split("/");
    return splitPath[splitPath.length - 1];
  }
}

extension UtilsSprite on Sprite {
  double get aspectRatio {
    return image.width / image.height;
  }
}

Vector2 getAspectRatioVector(
    {required double width, required double height, required aspectRatio}) {
  double heightArea =
      (width / aspectRatio) > height ? height : width / aspectRatio;
  double widthArea =
      (width / aspectRatio) > height ? height * aspectRatio : width;

  return Vector2(widthArea, heightArea);
}


void showNotification(
    {required BuildContext context,
    required String messages,
    required void Function() onOk}) {
  showDialog(
    barrierDismissible: false,
    barrierColor: Colors.black54,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        content: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Assets.imagesBgModal), fit: BoxFit.fill)),
            child: AspectRatio(
                aspectRatio: 0.85,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Text(
                        messages,
                        style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      GestureDetector(
                        onTap: onOk,
                        child: Container(
                          width: 132,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange,
                                Colors.orange.shade300,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(5, 5),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'OK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      );
    },
  );
}

class SpriteComponentRatio extends SpriteComponent {
  SpriteComponentRatio(
      {super.anchor,
        super.angle,
        super.autoResize,
        super.children,
        super.key,
        super.nativeAngle,
        super.scale,
        super.paint,
        super.position,
        super.priority,
        super.size,
        super.sprite}) {
    paint.filterQuality = FilterQuality.medium;
  }
}

abstract class ComponentTab extends PositionComponent with HasGameRef<GameCtrl>, HasWorldReference<ExamTestWorld>,  HasVisibility {
  ComponentTab({super.size, super.position, super.scale});
}
