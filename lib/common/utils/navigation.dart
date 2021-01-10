import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:nmtv/common/model/eventBusModes.dart';
import 'package:nmtv/common/model/movieListModel.dart';
import 'package:nmtv/modules/discover/searchResult.dart';
import 'package:nmtv/modules/mine/feedback.dart';
import 'package:nmtv/modules/movieDetail/moviedDetail.dart';
import 'package:nmtv/modules/widget/tabbar.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/modules/widget/webViewWidget.dart';

int _currentPageCount = 0; //当前打开的页数量

class Navigation {
  ///替换
  static pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///跳转首页
  static Future pushHomePage(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => NMtabbbar(),
          fullscreenDialog: true,
        ),
        (route) => route == null);
  }

  ///跳转搜索结果
  static Future pushSearchResult(BuildContext context, String keyword) {
    _recordPageAdd();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResult(keyword: keyword),
        )).then((value) {
      print('---------pushSearchResult 搜索结果返回');
      _recordPageSubtract();
    });
  }

  ///详情页面
  static pushMovieDetail(BuildContext context, int movieId, MovieListModel model) {
    _recordPageAdd();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetail(movieID: movieId,listModel: model,),
      ),
    ).then((value) {
      print('---------pushMovieDetail 详情页面返回');
      _recordPageSubtract();
    });
  }

  ///跳转去留言反馈
  static pushFeedback(BuildContext context) {
    _recordPageAdd();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return MyFeedback();
    })).then((value) {
      print('---------pushFeedback 详情页面返回');
      _recordPageSubtract();
    });
  }

  ///跳转webview
  static pushMovieWebView(
      BuildContext context, String title, String URL, String site) {
    _recordPageAdd();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Browser(url: URL, title: title, site: site,);
    })).then((value) {
      print('---------pushMovieWebView 页面返回');
      _recordPageSubtract();
    });
  }

  ///跳转webview
  static pushWebview(BuildContext context, String title, String URL) {
    _recordPageAdd();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Browser(url: URL, title: title, site: "",);
//      return new Browser(
//        url: URL,
//        title: title,
//      );
    })).then((value) {
      print('---------pushWebview 页面返回');
      _recordPageSubtract();
    });
  }

  static void _recordPageAdd() {
    //记录页面数量 +1
    _currentPageCount++;
    //通知-关闭banner
    Global.eventBus.fire(EventBusBannerAd()..isShow = false);
  }

  static void _recordPageSubtract() {
    //记录页面数量 -1
    _currentPageCount--;
    //通知-打开banner
    if (_currentPageCount <= 0) {
      Global.eventBus.fire(EventBusBannerAd()..isShow = true);
    }
  }
}

class CustomRoute extends PageRouteBuilder {
  final Widget widget;

  CustomRoute(this.widget)
      : super(
            // 设置过度时间
            transitionDuration: Duration(milliseconds: 600),
            // 构造器
            pageBuilder: (
              // 上下文和动画
              BuildContext context,
              Animation<double> animaton1,
              Animation<double> animaton2,
            ) {
              return widget;
            },
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animaton1,
              Animation<double> animaton2,
              Widget child,
            ) {
              // 需要什么效果把注释打开就行了
              // 渐变效果
//        return FadeTransition(
//          // 从0开始到1
//          opacity: Tween(begin: 0.0,end: 1.0)
//              .animate(CurvedAnimation(
//            // 传入设置的动画
//            parent: animaton1,
//            // 设置效果，快进漫出   这里有很多内置的效果
//            curve: Curves.fastOutSlowIn,
//          )),
//          child: child,
//        );

              // 左右滑动动画效果
              return SlideTransition(
                position: Tween<Offset>(
                        // 设置滑动的 X , Y 轴
                        begin: Offset(1.2, 0.0),
                        end: Offset(0.0, 0.0))
                    .animate(CurvedAnimation(
                        parent: animaton1, curve: Curves.fastOutSlowIn)),
                child: child,
              );
            });
}
