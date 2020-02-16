import 'package:flutter/material.dart';
import 'dart:ui';

class IconsCustom {
  static const String ICON_APP_512 = "res/image/ic_app_512.png";
  static const String ICON_APP_128 = "res/image/ic_app_128.png";
  static const String ICON_PLACE_HOLDER = "res/image/placeholder.png";
  static const String ICON_APP = "res/image/ic_nm_256.png";
}

class Adapt {
  static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
  static double _width = mediaQuery.size.width;
  static double _height = mediaQuery.size.height;
  static double _topbarH = mediaQuery.padding.top;
  static double _botbarH = mediaQuery.padding.bottom;
  static double _pixelRatio = mediaQuery.devicePixelRatio;
  static var _ratio;
  /// 安全内容高度(包含 AppBar 和 BottomNavigationBar 高度)
  double get safeContentHeight => _height - _topbarH - _botbarH;
  /// 实际的安全高度
  double get safeHeight => safeContentHeight - kToolbarHeight - kBottomNavigationBarHeight;

  static init(int number) {
    int uiwidth = number is int ? number : 750;
    _ratio = _width / uiwidth;
  }

  static px(number) {
    if (!(_ratio is double || _ratio is int)) {
      Adapt.init(750);
    }
    return number * _ratio;
  }

  static onepx() {
    return 1 / _pixelRatio;
  }

  //获取上边距和下边距的值。(主要用于刘海屏)
  static padTopH() {
    return _topbarH;
  }

  static padBotH() {
    return _botbarH;
  }

  //宽高
  static screenW() {
    return _width;
  }

  static screenH() {
    return _height;
  }

  //计算横竖屏
  static screenCurrentH(context) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? _height
        : _width;
  }

  static screenCurrentW(context) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? _width
        : _height;
  }

  //像素宽高
  static screenPixelW() {
    return window.physicalSize.width;
  }

  static screenPixelH() {
    return window.physicalSize.height;
  }
}
