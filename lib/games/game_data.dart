import 'package:flame/cache.dart';
import 'package:flame/components.dart';

class GlobalDataGame {
  String? answerFillBlank;
  int answerBlankLength = 0;
  bool isDoneTimer = false;
}

class GlobalSprite {
  late final Images _images;
  late final Map<String, Sprite> _lstSprite;
  initialSprite(Images images) {
    _images = images;
    _lstSprite = {
      "bg_modal.png": Sprite(_images.fromCache("bg_modal.png")),
      "bg_button.png": Sprite(_images.fromCache("bg_button.png")),
      "icon_speaker.png": Sprite(_images.fromCache("icon_speaker.png")),
      "icon_repeat.png": Sprite(_images.fromCache("icon_repeat.png")),
      "select_card.png": Sprite(_images.fromCache("select_card.png")),
      "bg_button--red.png": Sprite(_images.fromCache("bg_button--red.png")),
      "idle_select_card.png": Sprite(_images.fromCache("idle_select_card.png")),
    };
  }

  Sprite sprite(String source) => _lstSprite[source]!;
}

GlobalSprite globalSprite = GlobalSprite();

final globalDataGame = GlobalDataGame();
