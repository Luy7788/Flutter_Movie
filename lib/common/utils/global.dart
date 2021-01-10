import 'package:flutter/foundation.dart';
import 'package:nmtv/common/model/eventBusModes.dart';
import 'package:nmtv/common/model/movieDetailModel.dart';
import 'package:nmtv/common/model/movieListModel.dart';
import 'package:nmtv/common/utils/toast.dart';

// import 'package:unique_ids/unique_ids.dart';
// import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:device_info/device_info.dart';
import 'package:encrypt/encrypt.dart' as PP;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_bus/event_bus.dart';
import 'package:nmtv/common/net/HttpManager.dart';
import 'package:nmtv/common/net/api.dart';
import 'package:nmtv/common/config/config.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

///模型
import 'package:nmtv/common/model/configModel.dart';

///全局单例
global Global = global();

class global {
  ///设备信息
  String udid; //首选
  String adid;
  String uuid;
  PackageInfo packageInfo;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosInfo;
  String newBaseUrl = ""; //获取到的最新url
  ///通用数据数据
  EventBus eventBus = new EventBus(); //建一个全局用的通知
  SharedPreferences prefs; //缓存
  ConfigModel config; //获取的配置信息
  Map<String, dynamic> js; //aes加密后的json
  List<String> searchListCache = List(); //搜索
  List<MovieDetailModel> footmarkListCache = List(); //足迹
  List<MovieListModel> homeListCache = List(); //首页数据缓存
  Map<String, dynamic> movieProgressCache = Map(); //观看进度缓存

  // 单例公开访问点
  factory global() => _sharedInstance();

  // 静态私有成员，没有初始化
  static global _instance = global._();

  // 私有构造函数
  global._() {
    // 具体初始化代码
    initConfig();
  }

  // 静态、同步、私有访问点
  static global _sharedInstance() {
    return _instance;
  }

  Future<String> _getId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Config.isIOS == true) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Config.isAndroid == true) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    } else {
      return "";
    }
  }

  //初始化配置
  Future<void> initConfig() async {
    print("=======global初始化 initConfig");

    String deviceId = await _getId();
    print('=======deviceId : $deviceId');
    this.udid = deviceId;

    if (this.udid == null) {
      this.udid = "0000";
      //   // generate uuid
      //   try {
      //     this.uuid = await UniqueIds.uuid;
      //     print('=======uuid : $uuid');
      //   } on PlatformException {
      //     this.uuid = 'Failed to get uuid.';
      //   }
      //
      //   // get adid(idfa)
      //   try {
      //     this.adid = await UniqueIds.adId;
      //     print('=======adId : $adid');
      //   } on PlatformException {
      //     this.adid = 'Failed to get adId.';
      //   }
      // } else {
      //   print('=======udid : $udid');
    }

    //获取设备
    this.packageInfo = await PackageInfo.fromPlatform();
    if (Config.isIOS == true) {
      //ios相关代码
      this.iosInfo = await deviceInfo.iosInfo;
      print('=======Running on iosInfo: ${iosInfo.utsname.machine}');
    } else if (Platform.isAndroid) {
      //android相关代码
      this.androidInfo = await deviceInfo.androidInfo;
      print('Running on androidInfo: ${androidInfo.model}');
      print(
          'Running on androidInfo version: ${this.androidInfo.version.release} ');
      print('Running on androidInfo: id:${this.androidInfo.androidId}');
    } else {
      print("不是安卓和iOS");
    }

    //获取缓存配置
    this.prefs = await SharedPreferences.getInstance();
    _getCache();

    // HTTP.dioGet(API.getBaseUrl).then((result) {
    //   if (result != null &&
    //       result.length > 1 &&
    //       result.contains("#") == false) {
    //     print('---------------------使用这个地址');
    //     this.newBaseUrl = result;
    //     this.prefs.setString(result, Config.PREFS_BASE_URL);
    //   } else {
    //     print('---------------------暂不使用这个地址');
    //   }
    // });

    //延时请求配置信息
    getAppConfig();
    //上线
    _online();
//    Future.delayed(Duration(milliseconds: 500), () {
//    });
  }

  //获取缓存
  void _getCache() {
    EventBusCache eventCache = EventBusCache();

    //获取缓存配置
    var configModelString = this.prefs.getString(Config.PREFS_CONFIG);
    if (configModelString != null) {
      print('=======初始化配置 获取缓存配置: ${getTypeName(configModelString)}');
      Map<String, dynamic> configModelJson = json.decode(configModelString);
      print('=======初始化配置 转 json: ${configModelJson}');
      this.config = ConfigModel.fromJson(configModelJson);
      //获取js
      getModelJS();
      //通知-刷新
      this.eventBus.fire(this.config);
    }

    //获取搜索历史
    List<String> _searchList = this.prefs.getStringList(Config.PREFS_SEARCH);
    if (_searchList != null) {
      this.searchListCache = _searchList;
      eventCache.searchTextList = _searchList;
      print("=======获取搜索历史");
    }

    //获取观看历史
    List<String> _movieStringHistory =
        this.prefs.getStringList(Config.PREFS_FOOTMARK);
    if (_movieStringHistory != null) {
      List<MovieDetailModel> _movieHistory = List();
      for (String item in _movieStringHistory) {
        Map<String, dynamic> jsonModel = json.decode(item);
        MovieDetailModel model = MovieDetailModel.fromJson(jsonModel);
        _movieHistory.add(model);
      }
      this.footmarkListCache = _movieHistory;
      eventCache.footmarkList = _movieHistory;
      print("=======获取观看历");
    }

    //获取首页缓存
    List<String> _homeMovies = this.prefs.getStringList(Config.PREFS_HOME_LIST);
    if (_homeMovies != null) {
      List<MovieListModel> _homeHistory = List();
      for (String item in _homeMovies) {
        Map<String, dynamic> jsonModel = json.decode(item);
        MovieListModel model = MovieListModel.fromJson(jsonModel);
        _homeHistory.add(model);
      }
      this.homeListCache = _homeHistory;
      eventCache.homeList = _homeHistory;
      print("=======获取首页缓存");
    }

    //获取缓存进度
    String _progress = this.prefs.getString(Config.PREFS_MOVIE_PORGRESS);
    if (_progress != null) {
      Map jsonMap = json.decode(_progress);
      this.movieProgressCache = jsonMap;
      print("=======获取缓存进度: $_progress");
    } else {
      print("=======当前没有缓存进度: $_progress");
    }

    //获取缓存链接
    String _baseUrl = this.prefs.getString(Config.PREFS_BASE_URL);
    if (_baseUrl != null) {
      this.newBaseUrl = _baseUrl;
    }

    //通知刷新
    Future.delayed(Duration(milliseconds: 300)).then((_) {
      this.eventBus.fire(eventCache);
    });
  }

  //保存首页列表
  void saveHomeList(List<MovieListModel> homeList) {
    if (kIsWeb == true) {
      return;
    }
    List<String> itemList = List();
    for (MovieListModel item in homeList) {
      //转字符串保存
      String itemString = jsonEncode(item.toJson());
//      itemList.insert(0, itemString);
      itemList.add(itemString);
    }
    this.prefs.setStringList(Config.PREFS_HOME_LIST, itemList).then((isSave) {
      print("=======saveHomeList isSave : " + isSave.toString());
    });
  }

  //保存搜索历史
  void saveSearchHistory(List<String> history) {
    if (kIsWeb == true) {
      return;
    }
    this.prefs.setStringList(Config.PREFS_SEARCH, history).then((isSave) {
      print("=======saveSearchHistory isSave : " + isSave.toString());
    });
  }

  //保存观看历史
  void saveMovieHistroy(MovieDetailModel model) {
    if (kIsWeb == true) {
      return;
    }
    for (MovieDetailModel item in this.footmarkListCache) {
      if (item.movieID == model.movieID) {
        this.footmarkListCache.remove(item);
        break;
      }
    }
    this.footmarkListCache.insert(0, model);
    if (this.footmarkListCache.length > Config.HISTORY_FOOTMARK_SIZE) {
      this.footmarkListCache.removeLast();
    }
    List<String> movieList = List();
    for (MovieDetailModel item in this.footmarkListCache) {
      //转字符串保存
      String itemString = jsonEncode(item.toJson());
      movieList.add(itemString);
    }
    this.prefs.setStringList(Config.PREFS_FOOTMARK, movieList).then((isSave) {
      print("=======saveMovieHistroy isSave : " + isSave.toString());
    });
  }

  //清除足迹
  void cleanAllFootmark() {
    if (kIsWeb == true) {
      return;
    }
    this.footmarkListCache.clear();
    this.prefs.setStringList(Config.PREFS_FOOTMARK, List()).then((isSave) {
      print("=======cleanAllFootmark isSave : " + isSave.toString());
    });
  }

  //获取最后观看集数
  int getMovieLastIndex(int movieID) {
//    if (this.movieProgressCache.containsKey(movieID) == true) {
//      int current =
//    }
    for (MovieDetailModel item in this.footmarkListCache) {
      if (item.movieID == movieID) {
        return item.lastEpisodeIndex;
      }
    }
    return 0;
  }

  //获取对应观看进度
  int getMovieProgress(int MovieID, int episodeIndex) {
    int id = MovieID * 10000 + episodeIndex;
    if (this.movieProgressCache.containsKey('$id')) {
      String porgress = this.movieProgressCache['$id'];
      return int.parse(porgress);
    }
    return 0;
  }

  //保存观看进度
  void saveMovieProgress(int MovieID, int episodeIndex, int progressSecond) {
    int id = MovieID * 10000 + episodeIndex;
    this.movieProgressCache['$id'] = '$progressSecond';
//    String tostring = this.movieProgressCache.toString();
    String progressString = json.encode(this.movieProgressCache);
    this.prefs.setString(Config.PREFS_MOVIE_PORGRESS, progressString);
  }

  //设备上线
  void _online() async {
    HTTP.post(API.online, urlParams: {"app": "MOVIE"}).then((response) {
      print('=======API.online response - ${response}');
    });
  }

  //获取基础参数
  void getAppConfig() {
    //请求
    HTTP.get(API.config).then((response) {
      //FIXME:TEST
      if (response == null) {
        response = {
          "code": 0,
          "msg": "请求成功",
          "data": {
            "startup_banner": "",
            "search": [
              "神盾局特工",
              "行尸走肉",
              "越狱",
              "硅谷",
              "生活大爆炸",
              "老友记",
              "绿箭侠",
              "闪电侠"
            ],
            "search_ph": "",
            "enable_cache": true,
            "enable_review": true,
            "startup_msg": null,
            "js":
                "99OTxgZdap44ZyM/riJ5GihZ8uvNV1wADCvTzvz44zHD947MuggbOFDBx+3+4HB7VTABp6hkayMaDbS1DJRFPhv0L2ndw9I6dRrWdbta95m8Lhl5T11XG6YykTFCoxDWEgO5po1AEVGRseM6z7kyUp9FP1fFQfyiXDLoOukbOKT6wEejtt/w/WrWE82Cc8njO4HjmSD3CT60hk3sUuQcRtCmDerk5S03VZQN6rhvG/V6vshzWUWmEsZoZ2Kl2kHYV6n6k2yLlHWgqU0lMZ0JqGiG3OIxC8qvASgLt8ptamdw0/Id3y/oeTbBJNMyx3jOjl4O7JXIv9G8blxWXFXNbl+iBFC5zr9v65jXLoXEiR0j7iDViB/IeJP7Js82XXJFJyjjzvCGO1YuPoaBjtq0cLhLyBSGrXqIPFd+0wHUji0=",
            "category": ["美剧", "英剧", "韩剧", "日剧"],
            "tags": ["剧情", "动作", "科幻", "喜剧", "悬疑", "爱情", "惊悚", "犯罪", "战争", "冒险"]
          }
        };
      }
      if (response != null) {
        var data = new Map<String, dynamic>.from(response["data"]);
        ConfigModel model = ConfigModel.fromJson(data);
        this.config = model;
        print('=======API.config response - success');
        //通知刷新
        this.eventBus.fire(model);
        //缓存
        var responseJsonString = json.encode(response["data"]).toString();
        this
            .prefs
            .setString(Config.PREFS_CONFIG, responseJsonString)
            .then((isSave) {
          print("=======API.config respons isSave : " + isSave.toString());
        });

        //获取js
        getModelJS();

        //版本判断
        if (model.startupMsg.level != null && model.startupMsg.level > 0) {
          switch (model.startupMsg.level) {
            case 1:
              break;
            case 2:
              Toast.show(model.startupMsg.msg);
              break;
            case 3:
              Alert.show(model.startupMsg.msg);
              break;
            case 4:
              Alert.showWithoutDismiss(model.startupMsg.msg);
              break;
            default:
              break;
          }
        }
      } else {
        print('=======API.config response - fail');
      }
    });
  }

  void getModelJS() {
    //解析aes加密，获取动态js
    String jsString = AES_Decrypt(this.config.js);
    Map<String, dynamic> jsJson = jsonDecode(jsString);
    this.js = jsJson;
    print('=======API.config js - $jsJson');
  }

  //获取影视列表
  Future movieList(
      {String category,
      String keyword,
      int pageNum = 1,
      int pagesize = Config.PAGE_SIZE}) async {
    //FIXME:TEST
    await Future.delayed(Duration(seconds: 2));
    List<MovieListModel> _list = List<MovieListModel>();
    for (int i = 0; i < pagesize; i++) {
      var _temp = MovieListModel()
        ..id = i
        ..title = "葫芦娃大战变形金刚$i"
        ..cover =
            "https://img1.doubanio.com/view/photo/s_ratio_poster/public/p2621219978.webp"
        ..episodeNewest = 12
        ..episodeTotal = 24
        ..score = (50 + i) / 10;
      _list.add(_temp);
    }
    return _list;

    var mapData = Map();
    if (category.length > 0 && category != '全部') mapData['category'] = category;
    if (keyword.length > 0 && keyword != '全部') mapData['keyword'] = keyword;
    mapData['pageNum'] = pageNum;
    mapData['pagesize'] = pagesize;
    var mapParams = new Map<String, dynamic>.from(mapData);
    var response = await HTTP.get(API.movieList, params: mapParams);
    if (response != null) {
      List jsonList = response["data"];
      List modelList =
          jsonList.map((item) => MovieListModel.fromJson(item)).toList();
      return modelList;
    } else {
      return List();
    }
  }

  //获取影视详情
  Future movieDetail(int movieId) async {
    //FIXME:TEST
    await Future.delayed(Duration(seconds: 2));
    MovieDetailModel temp = MovieDetailModel()
      ..movieID = movieId
      ..episodeTotal = 21
      ..title = "葫芦娃大战变形金刚"
      ..director = "孙悟空"
      ..screenwriter = "唐三藏"
      ..mainActors = "大娃、二娃、三娃、四娃、五娃、六娃"
      ..region = "中国"
      ..language = "中文、英文"
      ..releaseTime = "2021年1月"
      ..tags = "喜剧"
      ..summary =
          "穿山甲在误打误撞之中打穿了葫芦山，放跑了被镇压在山下的蝎子精和蛇精。焦急之中，穿山甲找到了爷爷，拜托爷爷种下七色葫芦，很快，七个颜色各异的大葫芦便结了出来"
      ..site = "MJW"
      ..cover =
          "https://img9.doubanio.com/view/photo/s_ratio_poster/public/p2624607255.webp"
      ..links = MovieDetailModel.linksfromJson(Map<String, dynamic>.from({
        //具体播放连接列表
        "MJW": [
          {
            "site": "MJW", //站点
            "lineIndex": 1, //线路
            "episodeName": "第一集", // 第几集 或 电影清晰度(高清、蓝光)
            "link": "https://91mjw.com/vplay/MjUxNi0xLTA=.html", //站点对应的播放连接
            "realPlayLink": null //视频真实播放地址(AES加密, 暂无)
          },
          {
            "site": "MJW", //站点
            "lineIndex": 1, //线路
            "episodeName": "第二集", // 第几集 或 电影清晰度(高清、蓝光)
            "link": "https://91mjw.com/vplay/MjUxNi0xLTE=.html", //站点对应的播放连接
            "realPlayLink": null //视频真实播放地址(AES加密, 暂无)
          },
          {
            "site": "MJW", //站点
            "lineIndex": 1, //线路
            "episodeName": "第三集", // 第几集 或 电影清晰度(高清、蓝光)
            "link": "https://91mjw.com/vplay/MjUxNi0xLTI=.html", //站点对应的播放连接
            "realPlayLink": null //视频真实播放地址(AES加密, 暂无)
          },
        ]
      }))
      ..lastEpisodeIndex = 5
      ..lastEpisodeName = "第五集";
    return temp;

    var response = await HTTP.get(API.movieDetail + '/${movieId}');
    if (response != null) {
      var jsonData = response["data"];
      if (jsonData != null) {}
      MovieDetailModel model = MovieDetailModel.fromJson(jsonData);
      return model;
    } else {
      return null;
    }
  }

  //上传历史
  void uploadHistory(String title, String episodeName, int movieID) async {
    return;
    Map<String, dynamic> params = {
      "title": title,
      "episodeName": episodeName,
      "movieId": movieID
    };
    HTTP.post(API.history, formParams: params).then((response) {
      print('=======API.uploadHistory response - ${response}');
    });
  }

  void uploadRealLink(String realLink, int linkId) async {
    return;
    Map<String, dynamic> params = {
      "linkId": linkId,
      "link": realLink,
    };
    HTTP.post(API.realLink, formParams: params).then((response) {
      print('=======API.uploadRealLink response - ${response}');
    });
  }

  //上传建议
  Future uploadFeedback(String content, String contact) async {
    Map<String, dynamic> params = {
      "clientVersion": Config.APP_VERSION,
      "content": content,
      "contactInfo": contact
    };
    var response = await HTTP.post(API.feedback, formParams: params);
    if (response != null) {
      int code = response["code"];
      if (code == 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  //AES 加密
  String AES_Encrypt(String plainText) {
    final key = PP.Key.fromUtf8(Config.AES_KEY);
    final iv = PP.IV.fromUtf8(Config.AES_IV);
    final encrypter = PP.Encrypter(PP.AES(key, mode: PP.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    print('=======加密之前：' + plainText + "\n加密之后：" + encrypted.base64);
    return encrypted.base64;
  }

  //AES 解密
  String AES_Decrypt(plainText) {
    final key = PP.Key.fromUtf8(Config.AES_KEY);
    final iv = PP.IV.fromUtf8(Config.AES_IV);
    final encrypter = PP.Encrypter(PP.AES(key, mode: PP.AESMode.cbc));
    print('=======解密之前：' + plainText);
    final encrypted = PP.Encrypted.fromBase64(plainText);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    print("\n=======解密之后：" + decrypted);
    return decrypted;
  }
}

String getTypeName(dynamic obj) {
  return obj.runtimeType.toString();
}
