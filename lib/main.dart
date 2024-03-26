import 'dart:html';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter/rendering.dart';
import 'package:flutter_flame_lib/common/config.dart';
import 'package:flutter_flame_lib/common/observer.dart';
import 'package:flutter_flame_lib/common/resource.dart';
import 'package:flutter_flame_lib/controllers/game_data_controller.dart';
import 'package:flutter_flame_lib/entity/content-entity.dart';
import 'package:game_thithu/generated/assets.dart';
import 'package:game_thithu/utils/audio_player_controller.dart';
import 'package:game_thithu/utils/ui_ultis.dart';
import 'package:game_thithu/widgets/fill_text_to_the_blank.dart';
import 'package:http/http.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'games/game_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    try {
      await SharedPreferences.getInstance();
    } catch (e) {
      SharedPreferences.setMockInitialValues({});
    }
    Map<String, dynamic> params = queryStringFromUrl(window.location.href);
    loadConfigs(
        apiConfig: API_CONFIG(
          API_DOMAIN: "",
          SIGN: "",
          DEVICE_ID: params["deviceid"],
          KEY: "gameclient",
          TOKEN_MD5: params["token"],
        ),
        gameConfig: GAME_CONFIG(
            level: int.parse(params["level"]),
            round: int.parse(params["round"])));
  }
  debugProfilePaintsEnabled = true;
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with GameListenerMessage {
  bool isReady = false;
  double percent = 0;
  double opacity = 0;
  _MyAppState() {
    gameDataCtl.gameObserver.subscribe(this);
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchGetResourceLst() async {
    for (int index = 0; index < gameDataCtl.lstMedia.length; index++) {
      final resource = gameDataCtl.lstMedia[index];
      final type = resource["type"];
      String url = resource["url"] ?? "";
      await AudioPlayer.clearAssetCache();
      try {
        switch (type) {
          case CONTENT_TYPE.AUDIO:
            await audioPlayerPreview.setUrl(url);
          case CONTENT_TYPE.IMAGE:
            final response = await get(Uri.parse(url));
            final image = await decodeImageFromList(response.bodyBytes);
            Flame.images.add(url.getFileName, image);
        }
      } catch (e) {
        logger.e("fetchGetResourceLst $e");
      }
    }
  }

  @override
  onMessage(String messageType, Map<String, dynamic>? extraData) async {
    Map<String, dynamic> params = queryStringFromUrl(window.location.href);

    if (extraData?["percent"] != null) {
      setState(() {
        percent = extraData?["percent"];
      });
    }

    if (messageType == MESSAGE_TYPE.START_GAME.toValue) {
      //get resources before start game
      await fetchGetResourceLst();

      setState(() {
        isReady = true;
      });
      await Future.delayed(const Duration(milliseconds: 20));
      setState(() {
        opacity = 1;
      });
    }
    if (messageType == MESSAGE_TYPE.ERROR_GET_EXAM_INFO.toValue ||
        messageType == MESSAGE_TYPE.ERROR_START_GAME.toValue) {
      showNotification(
          context: context,
          messages: "${extraData?["message"]}",
          onOk: () => window.location.replace(params["redirectUrl"] ?? "/"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            isReady
                ? AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeIn,
                    child: GameWidget.controlled(
                      gameFactory: GameCtrl.new,
                      overlayBuilderMap: {
                        "fill-text": (context, game) {
                          const aspectRatio = 1280 / 720;
                          final getAspectRatio = getAspectRatioVector(
                              width: context.getWidth,
                              height: context.getHeight,
                              aspectRatio: aspectRatio);
                          return Container(
                            alignment: Alignment.center,
                            child: AspectRatio(
                              aspectRatio: 1280 / 720,
                              child: Stack(
                                children: [
                                  Positioned(
                                      top: getAspectRatio.y * 0.5,
                                      left: getAspectRatio.x * 0.032,
                                      child: SizedBox(
                                        width: getAspectRatio.x * 0.76,
                                        child: FillTextToTheBlank(
                                            context: gameDataCtl
                                                .currentQuestion!
                                                .content
                                                .content),
                                      ))
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  )
                : Stack(
                    children: [
                      SizedBox(
                        width: context.getWidth,
                        height: context.getHeight,
                        child: Image.asset(
                          Assets.imagesBgProgress,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding:
                              EdgeInsets.only(bottom: context.getHeight * 0.1),
                          child: Container(
                              height: 20,
                              width: context.getWidth * 0.6,
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(6)),
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                color: Colors.lightBlueAccent,
                                curve: Curves.linear,
                                width: percent * (context.getWidth * 0.6),
                                height: 22,
                              )),
                        ),
                      )
                    ],
                  )
          ],
        ));
  }
}
