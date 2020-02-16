import 'dart:math';
import 'dart:io';
import 'package:nmtv/common/config/config.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/common/config/adapt.dart';
import 'package:device_info/device_info.dart';
import 'package:nmtv/common/utils/UrlEncode.dart';

class API {
  //API
  static const basetUrl = "http://lemon.xjqxz.top";

  static const getBaseUrl = "https://gitee.com/yzcai/static/raw/master/domain";

  //获取ip
  static const getIP = "http://ip.taobao.com/service/getIpInfo.php?ip=myip";

  //上线
  static const online = basetUrl + "/api/device/online";

  //获取配置
  static const config = basetUrl + "/api/config";

  //影视列表
  static const movieList = basetUrl + "/api/movie/list";

  //影视详情
  static const movieDetail = basetUrl + "/api/movie/detail";

  //上传历史
  static const history = basetUrl + "/api/movie/history";

  //上传真实链接
  static const realLink = basetUrl + '/api/movie/reallink';

  //评论
  static const commentCommit = basetUrl + "/api/movie/review/simple";

  //评论列表
  static const commentList = basetUrl + "/api/movie/review/simple/list";

  //反馈
  static const feedback = basetUrl + "/api/movie/feedback";
}

class baseParams {
  Map params() {
    var map = new Map();
    map["ve"] = Global.packageInfo.version ?? Config.APP_VERSION; //Config.AppVersion;//

    String adid =
        Global.udid ?? (Global.adid.length > 0 ? Global.adid : Global.uuid);
    if (adid.length == 0) {
      adid = "0000-0000-0000-0000-0000-0000-0000-0000";
    }
    if (adid.length == 16) {
      adid = "$adid$adid";
    }
    var now = DateTime.now();
    adid = adid.replaceAll("-", "") +
        '`' +
        now.millisecondsSinceEpoch.toString() +
        '`' +
        (Random().nextInt(9999 - 1000) + 1000).toString();
//    map["did"] = urlEncode.encode(Global.AES_Encrypt(adid));
    map["did"] = Global.AES_Encrypt(adid);
    if (Platform.isIOS == true) {
      //ios相关代码
      map["ct"] = "iphone";
      map["os"] = Global.iosInfo.systemVersion;
    } else if (Platform.isAndroid) {
      //android相关代码
      map["ct"] = "android";
      map["os"] = Global.androidInfo.version.release ?? "0";
    }
    int width = Adapt.screenPixelW().toInt();
    int height = Adapt.screenPixelH().toInt();
    map["ss"] = width.toString() + "x" + height.toString();
//    print("map-> ${map}");
    return map;
  }
}
