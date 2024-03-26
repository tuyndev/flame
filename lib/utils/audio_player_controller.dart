import 'package:game_thithu/utils/ui_ultis.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerPreview {
  Map<String, AudioPlayer> lstPlayer = {};
  Future<void> setUrl(String url) async {
    final AudioPlayer player = AudioPlayer();
    await player.setUrl(url);
    await player.dispose();
    lstPlayer[url.getFileName] = player;
  }
}

final audioPlayerPreview = AudioPlayerPreview();
