import 'package:flutter/material.dart';
import 'package:nmtv/common/config/config.dart';
import 'package:nmtv/common/model/event_bus.dart';
import 'package:nmtv/common/utils/navigation.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/common/model/config_model.dart';
import 'dart:async';

class DiscoverPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DiscoverPageState();
}

class DiscoverPageState extends State<DiscoverPage> {
  StreamSubscription _configSubscriptionConfig; //信号1
  StreamSubscription _configSubscriptionSearch; //信号2
  List<String> _hotTextList = []; //热门搜索
  List<String> _searchTextList = []; //搜索历史

  @override
  Widget build(BuildContext context) {
    return _home();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _configSubscriptionConfig.cancel();
    _configSubscriptionSearch.cancel();
    super.dispose();
  }

  @override
  void initState() {
    if (Global.config != null) {
      _hotTextList = Global.config.search;
      _searchTextList = Global.searchListCache;
    }
    //监听通知
    _configSubscriptionConfig =
        Global.eventBus.on<ConfigModel>().listen((event) {
      print("configSubscription 接收到eventBus 搜索关键词 通知");
      setState(() {
        _hotTextList = event.search;
      });
    });
    _configSubscriptionSearch =
        Global.eventBus.on<EventBusCache>().listen((event) {
      print("_configSubscriptionSearch 接收到eventBus 历史 通知");
      setState(() {
        _searchTextList = event.searchTextList;
      });
    });
  }

  //搜索事件
  void searchAction(String value) {
    if (value != null) {
      if (_searchTextList.contains(value) == false) {
        _searchTextList.insert(0, value);
        if (_searchTextList.length > Config.HISTORY_SEARCH_SIZE) {
          _searchTextList.removeLast();
        }
        Global.saveSearchHistory(_searchTextList);
      }
      //路由跳转
      Navigation.pushSearchResult(context, value);
    }
  }

  Scaffold _home() {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: TextFieldWidget((value) => searchAction(value)),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                height: 40.0,
                child: Text('热门搜索',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: Color(0xFF333333),
                    ))),
            _wrapWidget(
                titles: _hotTextList, callback: (value) => searchAction(value)),
            Padding(padding: EdgeInsets.only(top: 30)),
            Container(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                height: 40.0,
                child: Text('搜索记录',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: Color(0xFF333333),
                    ))),
            _wrapWidget(
                titles: _searchTextList,
                callback: (value) => searchAction(value)),
          ],
        ),
      ),
    );
  }
}

/*
* 搜索框*/
class TextFieldWidget extends StatelessWidget {
  final controller = TextEditingController();
  Function callback;

  TextFieldWidget(this.callback) : super();

  Widget buildTextField(BuildContext context) {
    // theme设置局部主题
    return Theme(
      data: new ThemeData(primaryColor: Colors.grey),
      child: new TextField(
        cursorColor: Colors.grey,
        // 光标颜色
        controller: controller,
        maxLines: 1,
        //监听文字改变
        onChanged: (val) {
          print(val);
        },
        //点击键盘的动作按钮时的回调，没有参数
        onEditingComplete: () {
          print("点击了键盘上的动作");
        },
        //点击确认
        onSubmitted: (val) {
          print("点击搜索 ：${val}");
          callback(val);
        },
        textInputAction: TextInputAction.search,
        // 默认设置
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            border: InputBorder.none,
            icon: Icon(Icons.search),
            hintText: "请输入电影、电视剧的名称",
            hintStyle: new TextStyle(
                fontSize: 14, color: Color.fromARGB(50, 0, 0, 0))),
        style: new TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 修饰搜索框, 白色背景与圆角
      decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
      ),
      alignment: Alignment.center,
      height: 36,
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: buildTextField(context),
          ),
          IconButton(
            icon: new Icon(Icons.cancel),
            color: Colors.grey,
            iconSize: 18.0,
            onPressed: () {
              this.controller.clear();
              // onSearchTextChanged('');
            },
          ),
        ],
      ),
    );
  }
}

/*
* 可以让子控件自动换行的控件
*
* */
class _wrapWidget extends StatefulWidget {
  List<String> titles = [];
  Function callback;

  _wrapWidget({this.titles, this.callback}) : super();

  @override
  _wrapWidgetState createState() => _wrapWidgetState();
}

class _wrapWidgetState extends State<_wrapWidget> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12, //主轴上子控件的间距
      runSpacing: 15, //交叉轴上子控件之间的间距
      children: _itemlist(), //要显示的子控件集合
    );
  }

  /*集合*/
  List<Widget> _itemlist() => List.generate(widget.titles!=null ? widget.titles.length : 0, (index) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            String title = widget.titles[index];
            print("点击了标题" + "$title");
            widget.callback(title);
          },
          child: Text(
            "${widget.titles[index]}",
            style: TextStyle(
//            backgroundColor: Colors.green,
              color: Color(0xFF333333),
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      });
}
