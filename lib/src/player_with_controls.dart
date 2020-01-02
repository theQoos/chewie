import 'dart:ui';
import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/cupertino_controls.dart';

// Cupertino 스타일만 사용하기 위해
// import 'package:chewie/src/material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerWithControls extends StatelessWidget {
  PlayerWithControls({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChewieController chewieController = ChewieController.of(context);
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: chewieController.aspectRatio ?? _calculateAspectRatio(context),
          child: _buildPlayerWithControls(chewieController, context),
        ),
      ),
    );
  }

  Container _buildPlayerWithControls(ChewieController chewieController, BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          chewieController.placeholder ?? Container(),
          Center(
            child: AspectRatio(
              aspectRatio: chewieController.aspectRatio ?? _calculateAspectRatio(context),
              child: VideoPlayer(chewieController.videoPlayerController),
            ),
          ),
          chewieController.overlay ?? Container(),
          _buildControls(context, chewieController),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    ChewieController chewieController,
  ) {
    // Cupertino 스타일만 사용하기 위해
    //return chewieController.showControls
    //    ? chewieController.customControls != null
    //        ? chewieController.customControls
    //        : Theme.of(context).platform == TargetPlatform.android
    //            ? MaterialControls()
    //            : CupertinoControls(
    //                backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
    //                iconColor: Color.fromARGB(255, 200, 200, 200),
    //              )
    //    : Container();
    return chewieController.showControls
        ? chewieController.customControls != null
            ? chewieController.customControls
            : CupertinoControls(
                // backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
                backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
                // iconColor: Color.fromARGB(255, 200, 200, 200),
                iconColor: Color.fromARGB(255, 255, 255, 200),
              )
        : Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    return width > height ? width / height : height / width;
  }
}
