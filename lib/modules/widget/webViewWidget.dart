import 'package:flutter/material.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class Browser extends StatefulWidget {
  String url;
  final String title;
  final String site; //线路标识，暂时不用
  Function playlinkCallback; //回调真实链接
  final FlutterWebviewPlugin _flutterWebviewPlugin = FlutterWebviewPlugin();

  Browser(
      {Key key, @required this.url, @required this.title, @required this.site})
      : super(key: key);

  loadAndCallback(String url, Function callback) {
    print("=========loadAndCallback 加载链接 ${url} this-> $this");
    this.url = url;
    this.playlinkCallback = callback;
    _flutterWebviewPlugin..stopLoading();
    _flutterWebviewPlugin..reloadUrl(url);
  }

  @override
  _BrowserState createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  String _javascript;
  double lineProgress = 0.0;

  void initState() {
    super.initState();
    print('-------Browser initState() this->$this ');
    //加载进度
    widget._flutterWebviewPlugin.onProgressChanged.listen((progress) {
      print("=========加载进度 $progress =========");
      setState(() {
        lineProgress = progress;
      });
    });

    //加载状态
    widget._flutterWebviewPlugin.onStateChanged
        .listen((WebViewStateChanged state) async {
      print("=========webview 状态变化 ${state.type}  this->$this");
      switch (state.type) {
        case WebViewState.shouldStart:
          //准备加载
          break;
        case WebViewState.startLoad:
          //开始加载
          break;
        case WebViewState.finishLoad:
          {
            //加载完成
//            print("==========Global.js-> ${Global.js}");
            _javascript = null;
            if (state.url.length > 4 && Global.js.keys.length > 0) {
              Global.js.keys.forEach((key) {
                if (state.url.contains(key) == true) {
                  _javascript = Global.js[key];
                  print(
                      "==========url: ${state.url} ==========匹配上Global.js.keys-> $key ====url: ${state.url}");
                } else {
                  print(
                      "==========url: ${state.url} ==========匹配不上Global.js.keys-> $key");
                }
              });

              if (_javascript != null) {
                //有需要加载的js
                widget._flutterWebviewPlugin
                    .evalJavascript(this._javascript)
                    .then((String response) {
                  print(
                      "==========当前需要加载的js -> $_javascript ==========response ->$response");
                });
                //获取到链接
                widget._flutterWebviewPlugin
                    .evalJavascript(";nm_url();")
                    .then((String response) {
                  print('==========获取到链接 nm_url(); ->$response');
                  if (widget.playlinkCallback != null) {
                    //获取链接后回调
                    if (response != null &&
                        response.contains('.m3u8') == true) {
                      String callbackString = response;
                      if (response.contains('https%') == true ||
                          response.contains('http%') == true) {
                        callbackString = Uri.decodeComponent(response); //url解码
                      }
                      if (callbackString.startsWith('"')) {
                        callbackString = callbackString.replaceAll('"', "");
                      }
                      widget.playlinkCallback(callbackString);
                    } else {
                      widget.playlinkCallback(null);
                    }
                  }
                });
              }
            }
          }
          break;
        case WebViewState.abortLoad:
          print("===== state.url===" + state.url);
          break;
      }
    });

    //url changed
    widget._flutterWebviewPlugin.onUrlChanged.listen((String url) {});

    //滚动
    widget._flutterWebviewPlugin.onScrollYChanged.listen((double offsetY) {
      // latest offset value in vertical scroll
      // compare vertical scroll changes here with old value
    });

    widget._flutterWebviewPlugin.onScrollXChanged.listen((double offsetX) {
      // latest offset value in horizontal scroll
      // compare horizontal scroll changes here with old value
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          child: _progressBar(lineProgress, context),
//          preferredSize: Size(200, 1.0),
          preferredSize: Size.fromHeight(1.0),
        ),
      ),
      url: widget.url,
      withZoom: true,
      //允许网页缩放
      withLocalStorage: true,
      //允许执行 js 代码
      withJavascript: true,
      hidden: false,
      supportMultipleWindows: true,
    );
  }

  @override
  void dispose() {
    widget._flutterWebviewPlugin.dispose();
    super.dispose();
  }
}

_progressBar(double progress, BuildContext context) {
  return LinearProgressIndicator(
    backgroundColor: Colors.white70.withOpacity(0),
    value: progress == 1.0 ? 0 : progress,
    valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
  );
}
