import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:game_thithu/worlds/exam_test_world.dart';

import 'game_data.dart';

class GameCtrl extends FlameGame {
  @override
  void onLoad() async {
    world = ExamTestWorld();
    await images.loadAllImages();
    globalSprite.initialSprite(images);
    camera = CameraComponent.withFixedResolution(width: 1280, height: 720);
    camera.viewfinder.anchor = Anchor.topLeft;
    super.onLoad();
  }
}