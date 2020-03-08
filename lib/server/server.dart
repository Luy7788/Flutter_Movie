import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';

//前端页面访问本地域名
const String LocalHost = 'localhost';

//前端页面访问本地端口号
const int LocalPort = 7878;

//目标域名，http://lemon.xjqxz.top
const String TargetUrl = 'http://lemon.xjqxz.top';

Future main() async {
  var server = await shelf_io.serve(
    proxyHandler(TargetUrl),
    LocalHost,
    LocalPort,
  );
  // 添加上跨域的这几个header
  server.defaultResponseHeaders.add('Access-Control-Allow-Origin', '*');
  server.defaultResponseHeaders.add('Access-Control-Allow-Credentials', true);
  server.defaultResponseHeaders.add('Access-Control-Allow-Headers', 'content-type,x-access-token,x-url-path');
  server.defaultResponseHeaders.add('Access-Control-Allow-Methods', 'PUT,POST,GET,DELETE,OPTIONS');
  print('Serving at http://${server.address.host}:${server.port}');
}