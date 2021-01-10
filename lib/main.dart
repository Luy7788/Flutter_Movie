import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:nmtv/modules/widget/launch.dart';
import 'package:nmtv/modules/footmark/footmark.dart';
import 'package:nmtv/common/utils/global.dart';

void main() {
  if(kIsWeb == false) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runZoned(() {
        //全局变量初始化;
        Global;
        //设置竖屏
        runApp(NMTV());
      }, onError: (Object obj, StackTrace stack) {
        print(obj);
        print(stack);
      });
    });
  } else {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
//    _disableDebugPrint();
    //全局变量初始化;
    Global;
    //设置竖屏
    runApp(NMTV());
  }
}

void _disableDebugPrint() {
  bool debug = false;
  assert(() {
    debug = true;
    return true;
  }());
  if (!debug) {
    debugPrint = (String message, {int wrapWidth}) {
      //disable log print when not in debug mode
    };
  }
}

class NMTV extends StatelessWidget {
  var _brightnessStatus = Brightness.light;

  //定义路由信息
  final Map<String, Function> routes = {
    '/page': (context, {arguments}) => FootmarkPage()
  };

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          brightness: _brightnessStatus,
          color: Colors.yellow.shade600,
        ),
      ),
      home: LaunchPage(),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        // 统一处理
        final String name = settings.name;
        final Function pageContentBuilder = this.routes[name];
        if (pageContentBuilder != null) {
          if (settings.arguments != null) {
            final Route route = MaterialPageRoute(
                builder: (context) =>
                    pageContentBuilder(context, arguments: settings.arguments));
            return route;
          } else {
            final Route route = MaterialPageRoute(
                builder: (context) => pageContentBuilder(context));
            return route;
          }
        } else {
          return null;
        }
      },
    );
  }
}
