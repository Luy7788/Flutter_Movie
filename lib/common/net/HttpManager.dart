import 'dart:convert';
import 'dart:io';

import 'package:nmtv/common/net/api.dart';
import 'package:nmtv/common/config/config.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';
import 'package:nmtv/common/utils/UrlEncode.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/common/utils/toast.dart';

HttpManager HTTP = new HttpManager();

///http请求
class HttpManager {
  static const CONTENT_TYPE_JSON = "application/json; charset=utf-8";
  static const CONTENT_TYPE_FORM = "application/x-www-form-urlencoded";
  var _header = {
    "Content-Type": CONTENT_TYPE_JSON,
    "Version": Config.API_VERSION
  };
  Dio _dio = new Dio();

  HttpManager() {
    //连接服务器超时时间
    _dio.options.connectTimeout = 60000;
//    this._dio.options.receiveTimeout = 60000;
//    this._dio.options.sendTimeout = 60000;
    _dio.options.headers = _header;

    //设置代理
//    (this._dio.httpClientAdapter as DefaultHttpClientAdapter)
//        .onHttpClientCreate = (client) {
//      // config the http client
//      client.findProxy = (uri) {
//        //proxy all request to localhost:8888
//        return "PROXY 192.168.1.15:8888";
//      };
//      // you can also create a HttpClient to dio
//      // return HttpClient();
//    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options) async {
        print("\n=========================我是分割线==========================");
        print(" 请求baseUrl：${options.baseUrl}");
        print(" 请求url：${options.path}");
        print(' 请求头: ' + options.headers.toString());
        if (options.data != null) {
          print(' 请求参数 - FormData: ' + options.data.toString());
        }
        if (options.queryParameters != null) {
          print(
              ' 请求参数 - queryParameters: ' + options.queryParameters.toString());
        }
        return options;
      },
      onResponse: (Response response) async {
        if (response != null) {
          var responseStr = response.toString();
          print(' 请求结果: ' + responseStr);
          _resultHandle(response.data);
        }
        return response; // continue
      },
      onError: (DioError err) async {
        print(' 请求异常: ' + err.toString());
        print(' 请求异常信息: ' + err.response?.toString() ?? "");
        toast.show('请求异常，请稍候再试');
        return err;
      },
    ));

  }

  Future dioGet(String url) async {
    var httpClient = new HttpClient();
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        var json = await response.transform(utf8.decoder).join();
        result = json;
        print('---------------------result $result');
        return result;
      } else {
        result =
        'Error getting IP address:\nHttp status ${response.statusCode}';
        print('---------------------result $result');
        return null;
      }
    } catch (exception) {
      result = 'Failed getting $url';
      print('---------------------result $result');
      return null;
    }
  }

  Future get(String url, {Map<String, dynamic> params, noTip = false}) async {
    String requestUrl = url;
    if (Global.newBaseUrl.length > 1 && requestUrl.contains(API.basetUrl)==true) {
      //如果有新的域名，则替换
      requestUrl.replaceAll(API.basetUrl, Global.newBaseUrl);
    }
    var allParams = baseParams().params();
    allParams.addAll(params ?? {});
//    print('\nurl: ' + url);
//    print('baseParams: ${allParams}');
    Response response;
    try {
      var mapParams = new Map<String, dynamic>.from(allParams);
      response = await this._dio.get(requestUrl, queryParameters: mapParams);
//      print('get请求成功!response.data：${response.data}');
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        print('get请求取消! ' + e.message);
      }
      print('get请求发生错误：$e');
      return null;
    }
    return response.data;
  }

  Future post(String url, {Map<String, dynamic> formParams, Map<String, dynamic> urlParams, noTip = false}) async {
    String requestUrl = url;
    if (Global.newBaseUrl.length > 4 && requestUrl.contains(API.basetUrl)==true) {
      //如果有新的域名，则替换
      requestUrl.replaceAll(API.basetUrl, Global.newBaseUrl);
    }
    var allParams = baseParams().params();
    allParams.addAll(urlParams ?? {});
//    print('\nurl: ' + url);
//    print('baseParams: ${allParams}');
    Response response;
    try {
      var mapParams = new Map<String, dynamic>.from(allParams);
//      FormData formData = formParams != null ? FormData.fromMap(formParams) : null;
      response = await this ._dio  .post(requestUrl, data: formParams ?? {}, queryParameters: mapParams);
//      print('post请求成功!response.data：${response.data}');
    } on DioError catch (e) {
      if (CancelToken.isCancel(e)) {
        print('post请求取消! ' + e.message);
      }
      print('post请求发生错误：$e');
      return null;
    }
    return response.data;
  }

  //处理结果
  void _resultHandle(Map<String, dynamic> result) {
    //请求结果判断
    if (result.containsKey("code") == true) {
      int code = result["code"];
      if (code == 0) {
        //请求成功
      } else {
        //请求失败
        int codeLevel = code ~/ 10000;
        String msg = result["msg"];
        switch (codeLevel) {
          case 1:
            print('======== 给开发者错误：$code ---- message: $msg');
            break;
          case 2:
            print('======== 弱提示错误：$code ---- message: $msg');
            toast.show(msg);
            break;
          case 3:
            print('======== 强提示错误：$code ---- message: $msg');
            alert.show(msg);
            break;
          case 4:
            print('======== 强制提示不能关闭错误：$code ---- message: $msg');
            alert.showWithoutDismiss(msg);
            break;
          default:
            print('======== 其他错误：$code ---- message: $msg');
            break;
        }
      }
    }
  }
}
