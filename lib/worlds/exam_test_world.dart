import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:game_thithu/games/game_controller.dart';
import 'package:game_thithu/scenes/main_scenes.dart';

enum ExamTestRouter { main }

extension ExamTestRouterValue on ExamTestRouter {
  get value {
    switch (this) {
      case ExamTestRouter.main:
        return "main";
    }
  }
}

class ExamTestWorld extends World with HasGameRef<GameCtrl> {
  late final RouterComponent router;
  @override
  Future<void> onLoad() async {
    router = RouterComponent(
      initialRoute: ExamTestRouter.main.value,
      routes: {
        ExamTestRouter.main.value: Route(MainScenes.new),
      },
    );
    add(router);
    return super.onLoad();
  }
}
