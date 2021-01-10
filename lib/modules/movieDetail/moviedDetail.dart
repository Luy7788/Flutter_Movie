import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nmtv/common/utils/navigation.dart';
import 'package:nmtv/common/config/adapt.dart';
import 'package:nmtv/common/model/movieDetailModel.dart';
import 'package:nmtv/common/model/movieListModel.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/common/utils/toast.dart';
import 'package:nmtv/modules/movieDetail/movieDetailFirst.dart';
import 'package:nmtv/modules/movieDetail/movieDetailSecond.dart';
import 'package:nmtv/modules/widget/webViewWidget.dart';

final List _detailPageControl = [];

class MovieDetail extends StatefulWidget {
  int movieID; //视频id
  MovieListModel listModel;

  MovieDetail({Key key, this.movieID, this.listModel}) : super(key: key);

  @override
  _MovieDetailState createState() {
    return _MovieDetailState();
  }
}

class _MovieDetailState extends State<MovieDetail>
    with SingleTickerProviderStateMixin {
  final IjkMediaController ijkController = IjkMediaController();
  double _playLastProgrss; //最后播放器进度
  TabController _tabController;
  MovieDetailModel _detailModel = MovieDetailModel(); //详情模型
  String _keyWord = ""; //关键词
  List<MovieListModel> _recommendMovieItems = []; //推荐列表
  String _currentPlaySite = ""; //当前播放的线路 eg:"MJW"
  String _currentDisplaySite = ""; //当前用于显示的线路 ，和『_currentPlaySite』比较用于显示 选中第几集
  List<LinkItemModel> _currentLinks = List(); //当前采用的线路的 选集模型 数组
  List<String> _currentLinksStrings = List(); //当前采用的线路的 选集模型文字 数组
  int _currentLinkIndex; //当前采用的线路下的当前选集 模型的index
  LinkItemModel _currentLinkModel; //当前采用的线路的当前 选集模型
  String _webviewLoadUrl; //webview加载用
  Timer _countTimer; //计算加载时间
  final Browser _browser = Browser(
    url: "127.0.0.1",
    title: "",
    site: "",
  );

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
    _loadData();
    ijkController.pauseOtherController();
    _tabController = TabController(vsync: this, length: 2);
    print('-------movieDetail initState()------- $this ');
    _detailPageControl.add(this);
    Wakelock.enable(); //保持不锁屏
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print('------- movieDetail didChangeDependencies()------- ');
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    ijkController?.pause();
    _countTimer?.cancel();
    _cachePlayerProgress();
    print('------- movieDetail deactivate()------- ');
  }

  @override
  void dispose() {
    _detailPageControl.remove(this);
    if (_detailPageControl.length <= 0) {
      Wakelock.disable(); //可以锁屏
    }
    super.dispose();
    ijkController?.dispose();
    print('------- movieDetail页面销毁------- -> $this');
    _recommendMovieItems = [];
    _currentPlaySite = "";
    _currentLinks = [];
    _currentLinksStrings = [];
    _currentLinkIndex = 0;
    _currentLinkModel = null;
    _countTimer?.cancel();
    _countTimer = null;
  }

  //加载视频详情数据
  void _loadData() async {
    Global.movieDetail(widget.movieID).then((detail) {
      if (detail != null) {
        Map<String, dynamic> linksMap = detail.links;
        _currentPlaySite = detail.site;
        _currentDisplaySite = _currentPlaySite;
        List<LinkItemModel> linksArr = linksMap[_currentPlaySite];
        List<String> linkStringsArr = List();
        for (var linkItem in linksArr) {
          linkStringsArr.add(linkItem.episodeName);
        }
        //最后观看的
        detail.movieID = widget.movieID;
        detail.cover = widget.listModel.cover;
        int lastIndex = Global.getMovieLastIndex(detail.movieID);
        setState(() {
          _currentLinkIndex = lastIndex;
          _currentLinks = linksArr;
          _currentLinkModel = _currentLinks[_currentLinkIndex];
          _currentLinksStrings = linkStringsArr;
          _detailModel = detail;
          _keyWord = detail.tags;
        });
        //处理关键词，用于查找更多
        if (_detailModel.title.endsWith('季') == true &&
            _detailModel.title.contains('第') == true) {
          int lastIndex = _detailModel.title.lastIndexOf('第');
          var title = _detailModel.title.substring(0, lastIndex);
          _keyWord = title + ',' + detail.tags;
          print('=============处理关键词-> $_keyWord');
        }

        //加载更多相关视频
        _loadMoreMovie();
        //延时播放
        Future.delayed(const Duration(milliseconds: 400), () {
          //选中播放
          _onTapSelectLinkItemAction(lastIndex);
        });
      }
    });
  }

  //加载推荐视频
  Future _loadMoreMovie() async {
    await Global.movieList(
            category: "",
            keyword: this._keyWord ?? "美剧",
            pageNum: 1,
            pagesize: 6)
        .then((movieList) {
      setState(() {
        _recommendMovieItems = movieList;
      });
    });
  }

  void _playWithUrl(String url) async {
    await ijkController.setNetworkDataSource(url, autoPlay: true);
    print("set data source success $this");
    await ijkController.play();
    print("set ijkplayer play success");
    //获取缓存的播放进度
    int secondProgress =
        Global.getMovieProgress(this._detailModel.movieID, _currentLinkIndex);
    double progress = secondProgress * 1.0;
    Future.delayed(const Duration(milliseconds: 800), () {
      ijkController.seekTo(progress);
      print("set ijkplayer seek $progress");
    });
  }

  void _cachePlayerProgress() async {
    VideoInfo info = await ijkController.getVideoInfo();
    _playLastProgrss = info.currentPosition;
    if (_playLastProgrss != null && _playLastProgrss > 0) {
      print('=========存储视频进度 $_playLastProgrss');
      Global.saveMovieProgress(this._detailModel.movieID,
          this._currentLinkIndex, _playLastProgrss.toInt());
    }
  }

  //选集事件
  Future _onTapSelectLinkItemAction(int index) async {
    setState(() {
      _currentLinkIndex = index;
      _currentLinkModel = _currentLinks[_currentLinkIndex];
    });
    print(
        "--------选集：${_currentLinkModel.episodeName} realPlayLink:${_currentLinkModel.realPlayLink} link:${_currentLinkModel.link}");

    //保存足迹
    _detailModel.lastEpisodeIndex = _currentLinkIndex;
    _detailModel.lastEpisodeName = _currentLinkModel.episodeName;
    Global.saveMovieHistroy(_detailModel);

    if (_currentLinkModel.realPlayLink == null) {
      //没有播放链接
      ijkController.reset();
      _webviewLoadUrl = null;
      _browser.loadAndCallback(_currentLinkModel.link, (response) {
        if (_detailPageControl.last != this) {
          //多个播放页面时，此处会多次触发，最后一个不是当前页面则返回
          return;
        }
        print('============获取到真实播放链接 $response  this->$this');
        _countTimer?.cancel();
        _countTimer = null;
        if (response != null) {
          _webviewLoadUrl = response;
          _currentLinkModel.realPlayLink = response;
          _playWithUrl(response);
          //上报链接
          Global.uploadRealLink(
              _currentLinkModel.realPlayLink, _currentLinkModel.id);
        } else {
          _showAlertToWeb();
        }
      });
      //开始计时
      _countdown(30);
    } else {
      _webviewLoadUrl = null;
      _countTimer?.cancel();
      _countTimer = null;
      _playWithUrl(_currentLinkModel.realPlayLink);
    }
    //上传历史
    Global.uploadHistory(
        _detailModel.title, _currentLinkModel.episodeName, widget.movieID);
  }

  //加载倒计时
  void _countdown(int second) {
    if (_countTimer != null) {
      _countTimer?.cancel();
      _countTimer = null;
    }
    print('=========开始倒计时');
    _countTimer = new Timer.periodic(new Duration(seconds: 1), (timer) {
      print("======== countTimer.tick  ${_countTimer.tick}");
      if (_countTimer.tick == second) {
        // 只在倒计时结束时回调
        _countTimer?.cancel();
        _countTimer = null;
        _showAlertToWeb();
      }
    });
  }

  void _showAlertToWeb() {
    if (_webviewLoadUrl == null ||
        (ijkController.isPlaying == false && _webviewLoadUrl != null)) {
      Alert.showCustom("加载失败，是否打开原网站地址", '取消', '确定', () {}, () {
        print('=========倒计时结束');
        Navigation.pushMovieWebView(context, this._detailModel.title,
            _currentLinkModel.link, this._currentPlaySite);
      });
    }
  }

  //选线路事件
  void _onTapShowBottomSheetAction() {
    if (this._detailModel.links.keys.length == 0) {
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        //返回底部选项卡的标题
        List<Widget> _getBottomSheetTitles(List<String> titlesList) {
          List<Widget> widgets = List();
          int i = 0;
          for (var text in titlesList) {
            i++;
            Widget title = ListTile(
              title: Text(text),
              selected: text == this._currentDisplaySite,
              onTap: () {
                print('-------点击选择线路 $text');
                //隐藏弹窗
                Navigator.of(context).pop();
                if (text == this._currentDisplaySite) {
                  return;
                } else {
                  this._currentDisplaySite = text;
                  List<LinkItemModel> linksArr =
                      this._detailModel.links[_currentDisplaySite];
                  List<String> linkStringsArr = List();
                  for (var linkItem in linksArr) {
                    linkStringsArr.add(linkItem.episodeName);
                  }
                  setState(() {
                    _currentLinks = linksArr;
                    _currentLinksStrings = linkStringsArr;
                  });
                }
              },
            );
            Widget line = Container(
              height: 1,
              color: Colors.grey[200],
            );
            widgets.add(title);
            widgets.add(line);
          }
          return widgets;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: _getBottomSheetTitles(
            this._detailModel.links.keys.toList() ?? List(),
          ),
        );
      },
    );
  }

  Widget _buildFullScrrenCtl(IjkMediaController controller) {
    return DefaultIJKControllerWidget(
      controller: controller,
      doubleTapPlay: true,
      currentFullScreenState: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    print("------- movieDetail build ------- $this");
    // TODO: implement build
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarBrightness: Brightness.dark));

    return Scaffold(
      body: Container(
        height: Adapt.screenCurrentH(context),
        child: Column(
          children: <Widget>[
            Container(
              height: 20 + Adapt.padTopH(),
              color: Colors.black, //Colors.yellow.shade600,//Color(0xBB000000),
            ),
            Container(
              height: 200, // 这里随意
              child: IjkPlayer(
                mediaController: ijkController,
                controllerWidgetBuilder: (ctl) {
                  return DefaultIJKControllerWidget(
                    controller: ctl,
                    fullscreenControllerWidgetBuilder: _buildFullScrrenCtl,
                  );
                },
              ),
            ),
            Container(
              height: 40,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: TabBar(
                      controller: this._tabController,
                      labelColor: Colors.black,
                      indicatorColor: Colors.black54,
                      tabs: <Widget>[
                        Text(
                          '剧集',
                          style: TextStyle(height: 2),
                        ),
                        Text(
                          '详情',
                          style: TextStyle(height: 2),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 2,
                      height: 20,
                      color: Colors.grey[100],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height: Adapt.screenCurrentH(context) -
                  (20 + Adapt.padTopH()) -
                  200 -
                  40,
              child: TabBarView(
                controller: this._tabController,
                children: <Widget>[
                  MovieDetailFirst.custom(
                    this._detailModel,
                    this._currentLinksStrings,
                    this._recommendMovieItems,
                    this._currentLinkIndex ?? -1,
                    (this._currentPlaySite == this._currentDisplaySite) ?? true,
                    (index) => _onTapSelectLinkItemAction(index),
                    () => _onTapShowBottomSheetAction(),
                  ),
                  MovieDetailSecond.custom(
                      _detailModel.title ?? "",
                      _detailModel.director ?? "",
                      _detailModel.screenwriter ?? "",
                      _detailModel.mainActors ?? "",
                      _detailModel.region ?? "",
                      _detailModel.language ?? "",
                      _detailModel.summary ?? "",
                      _detailModel.releaseTime ?? ""),
                ],
              ),
            ),
            Offstage(
              //看不见的webview
              offstage: false,
              child: Container(
                height: 0,
                child: _browser,
              ),
            )
          ],
        ),
      ),
    );
  }
}
