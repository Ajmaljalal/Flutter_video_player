import 'dart:math';
import 'package:flutter/material.dart';
import 'package:forus/configs/color_palette.dart';
import 'package:forus/controllers/video_player_controllers/video_controller.dart';
import 'package:forus/widgets/video_player/video_player_controls.dart';
import 'package:forus/widgets/responsive.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerBase extends StatelessWidget {
  final String source;
  final VideoPlayerController controller;
  const VideoPlayerBase({
    Key? key,
    required this.source,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VideoContoller ctl = Get.find(tag: source);
    return FutureBuilder(
      future: ctl.initializeController(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (ctl.videoPosition != null) {
            ctl.controller.seekTo(ctl.videoPosition);
          }
          return Stack(
            children: [
              VisibilityDetector(
                key: Key(Random().nextDouble().toString()),
                onVisibilityChanged: (visibilityInfo) {
                  var visiblePercentage = visibilityInfo.visibleFraction * 100;
                  if (visiblePercentage > 60.0) {
                    controller.play();
                    // ctl.play();
                  }
                  // if (visibilityInfo.visibleFraction == 0) {
                  //   ctl.controller.pause();
                  // }
                },
                child: AspectRatio(
                  aspectRatio: Responsive.isMobile(context)
                      ? controller.value.aspectRatio
                      : 16 / 9,
                  child: Container(
                    color: ColorPalette.primary,
                    child: VideoPlayer(ctl.controller),
                  ),
                ),
              ),
              VideoPlayerControls(
                source: source,
                controller: controller,
              ),
            ],
          );
        } else {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
