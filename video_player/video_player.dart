import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forus/controllers/video_player_controllers/video_controller.dart';
import 'package:forus/widgets/responsive.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:forus/widgets/video_player/video_player_base.dart';

class VideoPlayerUtil extends StatefulWidget {
  final String source;
  VideoPlayerUtil({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  _VideoPlayerUtilState createState() => _VideoPlayerUtilState();
}

class _VideoPlayerUtilState extends State<VideoPlayerUtil> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    if (mounted) {
      Get.put(VideoContoller(), tag: widget.source);
      final VideoContoller ctl = Get.find(tag: widget.source);
      _controller = VideoPlayerController.network(widget.source);
      ctl.setVideoController(videoCtl: _controller);
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    print('disposed called');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoContoller ctl = Get.find(tag: widget.source);
    return Responsive.isDesktop(context)
        ? MouseRegion(
            onHover: (_) {
              ctl.changeShowOverlay(show: true);
            },
            onExit: (_) {
              ctl.changeShowOverlay(show: false);
            },
            child:
                VideoPlayerBase(source: widget.source, controller: _controller),
          )
        : VideoPlayerBase(source: widget.source, controller: _controller);
  }
}
