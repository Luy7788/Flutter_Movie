import 'dart:io';

import 'package:flutter/foundation.dart';

class Config {
  static final isRelease = (kIsWeb == true ? false : bool.fromEnvironment(
      'dart.vm.product'));

  static final isIOS = Platform.isIOS;

  static final isAndroid = Platform.isAndroid;

//  static const DEBUG = (isRelease == true ? true : false);

  static const PAGE_SIZE = 30; //列表页分页

  static const THEME_COLOR = 0xAAFFD328; //缓存

  static const APP_VERSION = "1.0.0"; //APP版本

  static const API_VERSION = "1.0.0"; //API 版本

  static const HISTORY_FOOTMARK_SIZE = 100; //历史列表长度

  static const HISTORY_SEARCH_SIZE = 10; //搜索记录长度

  static const ADMOB_InterstitialAd_Count = 60 * 40; //弹窗广告倒计时，单位秒

  //缓存
  static const PREFS_BASE_URL = "prefsBaseUrl"; //配置
  static const PREFS_CONFIG = "prefsConfig"; //配置
  static const PREFS_COLLECTION = "prefsCollection"; //收藏
  static const PREFS_FOOTMARK = "prefsFootmark"; //足迹
  static const PREFS_SEARCH = "prefsSearch"; //足迹
  static const PREFS_HOME_LIST = "prefsHomeList"; //首页列表
  static const PREFS_MOVIE_PORGRESS = "prefsMovieProgress"; //观看进度

  //AES
  static const AES_KEY = ""; //需要获取加密请私信
  static const AES_IV = "";

  //admob
  static const ADMOB_APP_ID_iOS = "";

  static const ADMOB_APP_ID_Android = "";

  static const ADMOB_Banner_UnitID_iOS = "";

  static const ADMOB_Banner_UnitID_Android = "";

  static const ADMOB_Interstitial_UnitID_iOS = "";

  static const ADMOB_Interstitial_UnitID_Android = "";
}
