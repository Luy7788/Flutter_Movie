import 'dart:async';
import 'package:flutter/services.dart';
import 'package:nmtv/common/config/adapt.dart';
import 'package:nmtv/common/utils/toast.dart';

import '../home/home.dart';
import '../footmark/footmark.dart';
import '../discover/discover.dart';
import '../mine/mine.dart';
import 'package:flutter/material.dart';
import 'package:nmtv/common/model/eventBusModes.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/common/utils/admob.dart';

class NMtabbbar extends StatefulWidget {
  @override
  _NMtabbbarState createState() => _NMtabbbarState();
}

class _NMtabbbarState extends State<NMtabbbar> {
  StreamSubscription _configSubscription; //信号
  final _selectItemColor = Colors.yellow.shade600; //Colors.yellowAccent; //选中颜色
  final _unSelectItemColor = Colors.black; //未选中的颜色
  final admob _admob = admob(); //广告ad
  int _currentSelectIndex = 0; //当前选择item
  List<Widget> pages = List<Widget>();

  @override
  void dispose() {
    _configSubscription.cancel();
    super.dispose();
    print("------- tabbbar dispose ");
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print('------- tabbbar didChangeDependencies() ');
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print('------- tabbbar deactivate() ');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("------- tabbbar initState");
    pages
      ..add(homePage())
      ..add(discoverPage())
      ..add(footmarkPage())
      ..add(minePage());

    //监听通知
    _configSubscription =
        Global.eventBus.on<eventBusBannerAd>().listen((event) {
      if (event.isShow == true) {
//        _admob.showAdBanner();
        _admob.showBanner(context, true);
        print("------- 接收到eventBus banner广告打开通知");
      } else {
//        _admob.hideAdBanner();
        _admob.showBanner(context, false);
//        _admob.showInterstitialAd();
        print("------- 接收到eventBus banner广告关闭通知");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AlertCTX = context;
    print("------- tabbbar build");
    return Scaffold(
      body: IndexedStack(
        index: this._currentSelectIndex,
        children: this.pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: [
            _bottomBarItem(
                0, '首页', Icons.home, _selectItemColor, _unSelectItemColor),
            _bottomBarItem(
                1, '搜索', Icons.search, _selectItemColor, _unSelectItemColor),
            _bottomBarItem(
                2, '足迹', Icons.pets, _selectItemColor, _unSelectItemColor),
            _bottomBarItem(
                3, '我的', Icons.person, _selectItemColor, _unSelectItemColor),
          ],
          type: BottomNavigationBarType.fixed,
          fixedColor: Colors.red,
          currentIndex: this._currentSelectIndex,
          onTap: (int index) {
            setState(() {
              _currentSelectIndex = index;
            });
          }),
    );
  }

  BottomNavigationBarItem _bottomBarItem(int index, String title,
      IconData tabIcon, Color selectColor, Color unSelectColor) {
    return BottomNavigationBarItem(
        icon: Icon(
          tabIcon,
          color:
              (this._currentSelectIndex == index ? selectColor : Colors.black),
        ),
        title: Text(
          title,
          style: TextStyle(
              color: (this._currentSelectIndex == index
                  ? selectColor
                  : Colors.black)),
        ));
  }
}
