import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:nmtv/modules/widget/launch.dart';
import 'package:nmtv/modules/footmark/footmark.dart';
import 'package:nmtv/common/utils/global.dart';

void main() {
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
}

class NMTV extends StatelessWidget {
  var _brightnessStatus = Brightness.light;

  //定义路由信息
  final Map<String, Function> routes = {
    '/page': (context, {arguments}) => footmarkPage()
  };

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      theme: ThemeData(
//        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          brightness: _brightnessStatus,
          color: Colors.yellow.shade600,
        ),
      ),
//      home: NMtabbbar(),
      home: launchPage(),
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
//      routes: <String, WidgetBuilder>{
//        '/':(BuildContext context) => NMtabbbar(),
//      },
    );
  }
}
