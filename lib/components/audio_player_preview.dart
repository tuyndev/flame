import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:game_thithu/games/game_controller.dart';
import 'package:game_thithu/utils/audio_player_controller.dart';
import 'package:game_thithu/utils/ui_ultis.dart';
import 'package:just_audio/just_audio.dart';

import '../games/game_data.dart';

class AudioPlayerPreview extends PositionComponent
    with HasGameRef<GameCtrl>, TapCallbacks {
  bool playing = true;
  final String url;
  late AudioPlayer player;
  late Sprite bgPlaying;
  late Sprite bgRepeat;
  late SpriteComponent background;

  AudioPlayerPreview({super.position, required this.url, super.size}) {
    player = audioPlayerPreview.lstPlayer[url.getFileName]!;
    anchor = Anchor.center;
  }

  Future<void> pauseAudio() async {
    await player.pause();
    await player.seek(Duration.zero);
  }

  @override
  void onTapDown(TapDownEvent event) async {
    addAll([
      ScaleEffect.to(
        Vector2(0.9, 1.10),
        EffectController(duration: 0.08),
      ),
      ScaleEffect.to(
        Vector2(1.10, 0.9),
        EffectController(duration: 0.08, startDelay: 0.08),
      ),
      ScaleEffect.to(
        Vector2(0.9, 1.10),
        EffectController(duration: 0.08, startDelay: 0.16),
      ),
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: 0.08, startDelay: 0.24),
      ),
    ]);
    if (playing == true) {
      await pauseAudio();
    }
    await player.play();
    super.onTapDown(event);
  }

  Sprite get _getSriteBackground {
    return playing == true ? bgPlaying : bgRepeat;
  }

  @override
  Future<void> onLoad() async {
    bgPlaying = globalSprite.sprite("icon_speaker.png");
    bgRepeat = globalSprite.sprite("icon_repeat.png");

    background = SpriteComponent(sprite: _getSriteBackground, size: size);
    add(background);
    return super.onLoad();
  }

  @override
  void onMount() async {
    player.playerStateStream.listen((event) async {
      playing = event.playing;
      if (event.processingState == ProcessingState.completed) {
        await pauseAudio();
      }
    });
    try {
      await player.play();
    } catch (e) {
      await pauseAudio();
    }
    ;
    super.onMount();
  }

  @override
  void update(double dt) {
    background.sprite = _getSriteBackground;
    super.update(dt);
  }

  @override
  void onRemove() async {
    await pauseAudio();
    super.onRemove();
  }
}
