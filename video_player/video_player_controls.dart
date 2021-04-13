import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forus/configs/color_palette.dart';
import 'package:forus/controllers/video_player_controllers/video_controller.dart';
import 'package:forus/widgets/customIconButton.dart';
import 'package:forus/widgets/video_player/video_player.dart';
// import 'package:forus/widgets/video_player/video_player_base.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:forus/utils/video_duration_formater.dart';

class VideoPlayerControls extends StatefulWidget {
  final String source;
  final VideoPlayerController controller;
  const VideoPlayerControls({
    Key? key,
    required this.source,
    required this.controller,
  }) : super(key: key);

  @override
  _VideoPlayerControlsState createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  int _currentPosition = 0;
  bool isPlaying = true;
  bool isMute = true;
  var currentPlayBackPosition;

  @override
  void initState() {
    final VideoContoller ctl = Get.find(tag: widget.source);
    if (mounted) {
      setState(() {
        _currentPosition = widget.controller.value.position.inMilliseconds;
      });
    }
    _attachListenerToController(ctl);
    super.initState();
  }

  _attachListenerToController(ctl) {
    widget.controller.addListener(
      () {
        if (widget.controller.value.duration == null ||
            widget.controller.value.position == null) {
          return;
        }
        if (mounted) {
          setState(() {
            _currentPosition = widget.controller.value.position.inMilliseconds;
          });
        }
      },
    );
  }

  // @override
  // void dispose() {
  //   final VideoContoller ctl = Get.find();
  //   widget.controller.removeListener(_attachListenerToController);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final VideoContoller ctl = Get.find(tag: widget.source);
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          ctl.changeShowOverlay(show: !ctl.showOverlay);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox.shrink(),
            Column(
              children: [
                _buildVideoProgressBar(ctl),
                _buildBottomOverlay(ctl),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(ctl) {
    List<Color> _colors = [
      ColorPalette.primary.withOpacity(0.8),
      ColorPalette.primary.withOpacity(0.005)
    ];
    List<double> _stops = [0.0, 1.0];
    return Container(
      height: 35.0,
      decoration: ctl.showOverlay
          ? BoxDecoration(
              gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: _colors,
              stops: _stops,
            ))
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        child: _buildBottomControllers(ctl),
      ),
    );
  }

  Widget _buildBottomControllers(ctl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildPlayPauseButtonsAndDuration(ctl),
        _buildFullScreenOptions(ctl),
      ],
    );
  }

  Widget _buildVideoProgressBar(ctl) {
    return ctl.showOverlay
        ? SizedBox(
            height: 10.0,
            child: VideoProgressIndicator(
              widget.controller,
              allowScrubbing: true,
              colors: VideoProgressColors(
                bufferedColor: Colors.white70,
                backgroundColor: Colors.grey,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildPlayPauseButtonsAndDuration(ctl) {
    final duration =
        '${durationFormatter(_currentPosition)} / ${durationFormatter(widget.controller.value.duration.inMilliseconds)}';
    return ctl.showOverlay
        ? Row(
            children: [
              CustomIconButton(
                onTap: () {
                  ctl.playPause();
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
                icon: isPlaying
                    ? CupertinoIcons.pause_fill
                    : CupertinoIcons.play_fill,
                color: Colors.white70,
              ),
              const SizedBox(width: 8.0),
              CustomIconButton(
                onTap: () {
                  ctl.changeMute();
                  setState(() {
                    isMute = !isMute;
                  });
                },
                icon: isMute
                    ? CupertinoIcons.speaker_fill
                    : CupertinoIcons.speaker_2_fill,
                color: Colors.white70,
              ),
              const SizedBox(width: 5.0),
              Card(
                color: ColorPalette.primary.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 3.0, vertical: 1.0),
                  child: Text(
                    duration,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _buildFullScreenOptions(ctl) {
    return ctl.showOverlay
        ? CustomIconButton(
            onTap: () {
              // save the current position of the video to the controller
              setState(() {
                currentPlayBackPosition = widget.controller.value.position;
              });
              ctl.setCurrentVideoPosition(
                  currentPosition: currentPlayBackPosition);
              // if fullScreen then close it, if not open full screen
              ctl.isFullScreen
                  ? ctl.exitFullScreen()
                  : _openVideoInFullScreen(ctl);
            },
            icon: ctl.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Colors.white70,
          )
        : const SizedBox.shrink();
  }

  _openVideoInFullScreen(ctl) {
    widget.controller.pause();
    ctl.goToFullScreen();
    return Get.to(
      () => Material(
        child: Center(
          child: VideoPlayerUtil(
            source: widget.controller.dataSource,
          ),
        ),
      ),
      fullscreenDialog: true,
    );
  }
}
