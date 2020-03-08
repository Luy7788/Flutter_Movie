import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nmtv/common/net/api.dart';
import 'package:nmtv/common/utils/cache.dart';
import 'package:nmtv/common/utils/navigation.dart';
import 'package:nmtv/common/utils/toast.dart';

class minePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => minePageState();
}

class minePageState extends State<minePage> {
  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的'),
      ),
      body: _mimeList(),
    );
  }
}

class _mimeList extends StatefulWidget {
  _mimeList({Key key}) : super(key: key);

  @override
  __mimeListState createState() {
    return __mimeListState();
  }
}

class __mimeListState extends State<_mimeList> {
  final cache _cache = cache();
  String _cacheSize;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print('------- mine didChangeDependencies() ');
  }

  @override
  void deactivate() {
    print('------- mine deactivate() ');
    _cache.loadCache().then((value) {
      print('获取到当前缓存 $value');
      setState(() {
        _cacheSize = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
//        _listCard(
//          titleIcon: Icons.favorite,
//          title: '我的收藏',
//          tapAction: () {},
//        ),
        _listCard(
          titleIcon: Icons.edit,
          title: '留言反馈',
          tapAction: () {
            Navigation.pushFeedback(context);
          },
        ),
        _listCard(
          titleIcon: Icons.face,
          title: '关于我们',
          tapAction: () {
            Navigation.pushWebview(
                context, '关于我们', API.about);
          },
        ),
        _listCard(
          titleIcon: Icons.info,
          title: '当前版本',
          subTitle: "v1.0.1",
        ),
        _listCard(
          titleIcon: Icons.delete_outline,
          title: '清除缓存',
          subTitle: this._cacheSize ?? "",
          tapAction: () {
            alert.showCustom('是否清空缓存($_cacheSize)?', '取消', '确定', () {}, () {
              this._cache.clearCache();
            });
          },
        ),
      ],
    );
  }
}

class _listCard extends StatelessWidget {
  final IconData titleIcon;
  final String title;
  final tapAction;
  final subTitle;

  const _listCard({
    Key key,
    this.titleIcon,
    this.title,
    this.tapAction,
    this.subTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //水波纹
      onTap: () {
        this.tapAction(); // ?? this.tapAction();
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(width: 1, color: Color(0xfff1f1f1)),
            )),
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            //左侧图标
            Icon(
              this.titleIcon,
            ),
            Padding(padding: EdgeInsets.only(left: 15)),
            //右侧文本
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    this.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    this.subTitle ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
