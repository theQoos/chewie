import 'dart:async';
import 'dart:ui' as ui;
import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/cupertino_progress_bar.dart';
import 'package:chewie/src/chewie_icons.dart';
import 'package:chewie/src/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CupertinoControls extends StatefulWidget {
  const CupertinoControls({
    @required this.backgroundColor,
    @required this.iconColor,
  });

  final Color backgroundColor;
  final Color iconColor;

  @override
  State<StatefulWidget> createState() {
    return _CupertinoControlsState();
  }
}

class _CupertinoControlsState extends State<CupertinoControls> {
  VideoPlayerValue _latestValue;
  double _latestVolume;
  bool _hideStuff = true;
  Timer _hideTimer;
  final marginSize = 5.0;
  Timer _expandCollapseTimer;
  Timer _initTimer;
  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    chewieController = ChewieController.of(context);
    final backgroundColor = widget.backgroundColor;
    //final iconColor = widget.iconColor;
    final iconColor = Colors.white;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;
    final orientation = MediaQuery.of(context).orientation;
    final barHeight = orientation == Orientation.portrait ? 30.0 : 47.0;
    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () {
          _cancelAndRestartTimer();
        },
        child: AbsorbPointer(
          absorbing: _hideStuff,
          child: Column(
            children: <Widget>[
              _buildHitArea(),
              _buildBottomBar(backgroundColor, iconColor, barHeight),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _expandCollapseTimer?.cancel();
    _initTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;
    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }
    super.didChangeDependencies();
  }

  AnimatedOpacity _buildBottomBar(
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return AnimatedOpacity(
      opacity: _hideStuff ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _cancelAndRestartTimer();
          if (_latestValue.volume == 0) {
            controller.setVolume(_latestVolume ?? 0.5);
          } else {
            _latestVolume = controller.value.volume;
            controller.setVolume(0.0);
          }
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 5.0, bottom: 5.0),
              color: Colors.transparent,
              alignment: Alignment.bottomLeft,
              margin: EdgeInsets.only(left: marginSize, right: marginSize, bottom: 1, top: marginSize),
              child: _buildMute(controller, backgroundColor, iconColor, barHeight),
            ),
            Container(
              padding: EdgeInsets.only(left: 43.3, right: 10),
              color: Colors.transparent,
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.all(marginSize),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 10.0,
                    sigmaY: 10.0,
                  ),
                  child: Container(
                    height: barHeight,
                    color: backgroundColor,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.3,
                        ),
                        _buildPlayPause(controller, iconColor, barHeight),
                        _buildPosition(iconColor),
                        _buildProgressBar(),
                        _buildRemaining(iconColor)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded _buildHitArea() {
    return Expanded(
      child: GestureDetector(
        onTap: _latestValue != null && _latestValue.isPlaying
            ? _cancelAndRestartTimer
            : () {
                _hideTimer?.cancel();
                setState(() {
                  _hideStuff = false;
                });
              },
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  GestureDetector _buildMute(
    VideoPlayerController controller,
    Color backgroundColor,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _cancelAndRestartTimer();
        if (_latestValue.volume == 0) {
          controller.setVolume(_latestVolume ?? 0.5);
        } else {
          _latestVolume = controller.value.volume;
          controller.setVolume(0.0);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10.0),
          child: Container(
            color: backgroundColor,
            child: Container(
              height: barHeight,
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Icon(
                (_latestValue != null && _latestValue.volume > 0) ? ChewieIcons.volumeOn : ChewieIcons.volumeOff,
                color: iconColor,
                size: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _buildPlayPause(
    VideoPlayerController controller,
    Color iconColor,
    double barHeight,
  ) {
    return GestureDetector(
      onTap: _playPause,
      child: Container(
        height: barHeight,
        color: Colors.transparent,
        padding: EdgeInsets.only(
          left: 3.0,
          right: 6.0,
        ),
        child: Icon(
          controller.value.isPlaying ? ChewieIcons.iconPause : ChewieIcons.iconPlay,
          color: iconColor,
          size: 16.0,
        ),
      ),
    );
  }

  Widget _buildPosition(Color iconColor) {
    final position = _latestValue != null ? _latestValue.position : Duration(seconds: 0);
    return Padding(
      padding: EdgeInsets.only(right: 12.0),
      child: Text(
        formatDuration(position),
        style: TextStyle(
          color: iconColor,
          fontSize: 12.0,
        ),
      ),
    );
  }

  Widget _buildRemaining(Color iconColor) {
    final position = _latestValue != null && _latestValue.duration != null ? _latestValue.duration : Duration(seconds: 0);
    return Padding(
      padding: EdgeInsets.only(right: 12.0),
      child: Text(
        '${formatDuration(position)}',
        style: TextStyle(color: iconColor, fontSize: 12.0),
      ),
    );
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    setState(() {
      _hideStuff = false;
      _startHideTimer();
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);
    _updateState();
    if ((controller.value != null && controller.value.isPlaying) || chewieController.autoPlay) {
      _startHideTimer();
    }
    //if (chewieController.showControlsOnInitialize) {
    //  _initTimer = Timer(Duration(milliseconds: 200), () {
    //    setState(() {
    //      _hideStuff = false;
    //    });
    //  });
    //}
  }

  Widget _buildProgressBar() {
    return Container(
      child: Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: CupertinoVideoProgressBar(
            controller,
            onDragStart: () {
              _hideTimer?.cancel();
            },
            onDragEnd: () {
              _startHideTimer();
            },
            colors: chewieController.cupertinoProgressColors ??
                ChewieProgressColors(
                  playedColor: Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ),
                  handleColor: Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ),
                  bufferedColor: Color.fromARGB(
                    60,
                    255,
                    255,
                    255,
                  ),
                  backgroundColor: Color.fromARGB(
                    20,
                    255,
                    255,
                    255,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;
    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();
        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() {
    setState(() {
      _latestValue = controller.value;
    });
  }
}
