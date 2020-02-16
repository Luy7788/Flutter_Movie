import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nmtv/common/model/eventBusModes.dart';
import 'package:nmtv/common/model/movieListModel.dart';
import 'package:nmtv/common/utils/toast.dart';
import 'package:nmtv/modules/widget/moviesList.dart';
import 'package:event_bus/event_bus.dart';
import 'dart:async';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/common/model/configModel.dart';

class homePage extends StatefulWidget {
  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  List<movieListModel> _movieItems = Global.homeListCache;
  var listCountrys = ["全部"]; //美剧", "韩剧", "电影"
  var listCategory = ["全部"]; //剧情", "动作", "科幻", "喜剧",
  int _currentPageNum = 1; //分页
  int _currentCountryIndex = 0; //当前国家
  int _currentCategoryIndex = 0; //当前类型
  StreamSubscription _configSubscriptionConfig; //配置信号
  StreamSubscription _configSubscriptionCache; //缓存信号
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false; // 是否有请求正在进行

  @override
  void initState() {
    print(' =========================首页初始化=========================');
    super.initState();
    if (Global.config != null) {
      listCountrys.addAll(Global.config.category ?? []);
      listCategory.addAll(Global.config.tags ?? []);
    }
    _controller = AnimationController(vsync: this);
    _refresh();
    //监听通知
    _configSubscriptionConfig =
        Global.eventBus.on<configModel>().listen((event) {
      print("configSubscription 接收到eventBus 通知");
      setState(() {
        this._currentCountryIndex = 0;
        this._currentCategoryIndex = 0;
        List country = event.category;
        country.insert(0, '全部');
        this.listCountrys = country;
        List category = event.tags;
        category.insert(0, '全部');
        this.listCategory = category;
      });
    });
    //加载更多
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _configSubscriptionConfig.cancel();
    _configSubscriptionCache.cancel();
  }

  //刷新
  Future<Null> _refresh() async {
    if (Global.config == null) {
      Global.getAppConfig();
    }
    this._currentPageNum = 1;
    String country = this.listCountrys[_currentCountryIndex];
    String tag = this.listCategory[_currentCategoryIndex];
    List movieList = await Global.movieList(
        pageNum: this._currentPageNum, category: country, keyword: tag);
    setState(() {
      this._movieItems = movieList;
    });
    if (movieList.length > 0) {
      Global.saveHomeList(movieList);
    } else if (this._currentPageNum == 1) {
      toast.show('暂无数据');
    }
  }

  void _getMoreData() async {
    if (this.isPerformingRequest == true) {
      return;
    }
    this.isPerformingRequest = true;
    this._currentPageNum++;
    String country = this.listCountrys[_currentCountryIndex];
    String tag = this.listCategory[_currentCategoryIndex];
    var movieList = await Global.movieList(
        pageNum: this._currentPageNum, category: country, keyword: tag);
    this.isPerformingRequest = false;
    if (movieList != null) {
      setState(() {
        this._movieItems.addAll(movieList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          bottom: new PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: _topbar(),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: MoviesList.custom(
          movieItems: this._movieItems,
          isCanScroll: true,
          scrollController: this._scrollController,
        ),
      ),
//      body: ListView(
//        children: <Widget>[
//        ],
//      ),
    );
  }

  /*顶部选项卡*/
  Column _topbar() {
    return Column(
      children: <Widget>[
        _topbarSubContainer(30, this.listCountrys),
        _topbarSubContainer(30, this.listCategory)
      ],
    );
  }

  Container _topbarSubContainer(double h, List listTitle) {
    List<Widget> buildGridTileList() {
      List<Widget> widgetList = new List();
      for (int i = 0; i < listTitle.length; i++) {
        if (listTitle == this.listCountrys) {
          //地区
          widgetList.add(_titleViewItem(0, i, listTitle[i]));
        } else {
          //分类
          widgetList.add(_titleViewItem(1, i, listTitle[i]));
        }
      }
      return widgetList;
    }

    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 0.0),
      height: h,
      child: ListView(
//        physics: AlwaysScrollableScrollPhysics(),
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: buildGridTileList(),
      ),
    );
  }

  GestureDetector _titleViewItem(int type, int index, String text) {
    int _index = index;
    int _type = type;
    return GestureDetector(
//     key: ValueKey(index),
      behavior: HitTestBehavior.opaque, //包括其他区域的点击
      onTap: () {
        if (type == 0) {
          //地区
          setState(() {
            _currentCountryIndex = _index;
          });
        } else {
          //分类
          setState(() {
            _currentCategoryIndex = _index;
          });
        }
        print('点击了$text');
        this._refresh();
      },
      child: Container(
        constraints: BoxConstraints(
          minWidth: 54.0,
        ),
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Text(
          text,
          style: TextStyle(
              fontSize: (this._currentCountryIndex == _index && _type == 0) ||
                      (this._currentCategoryIndex == _index && _type == 1)
                  ? 14.0
                  : 13.0,
              fontWeight: (this._currentCountryIndex == _index && _type == 0) ||
                      (this._currentCategoryIndex == _index && _type == 1)
                  ? FontWeight.w600
                  : FontWeight.w400),
        ),
      ),
    );
  }
}
