import 'package:flutter/material.dart';

class ChewieIcons {
  static const IconData iconPause = const _IconData(0xe901);
  static const IconData iconPlay = const _IconData(0xe902);
  static const IconData volumeOn = const _IconData(0xe903);
  static const IconData volumeOff = const _IconData(0xe900);
}

class _IconData extends IconData {
  const _IconData(int codePoint)
      : super(
          codePoint,
          fontFamily: 'chewie-icons',
          fontPackage: 'chewie',
        );
}
