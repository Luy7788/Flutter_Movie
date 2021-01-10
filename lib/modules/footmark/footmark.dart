import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nmtv/common/utils/navigation.dart';
import 'package:nmtv/common/config/adapt.dart';
import 'package:nmtv/common/model/movie_detail_model.dart';
import 'package:nmtv/common/model/movie_list_model.dart';
import 'package:nmtv/common/utils/global.dart';

class FootmarkPage extends StatefulWidget {
  FootmarkPage() : super();

  @override
  State<StatefulWidget> createState() => FootmarkPageState();
}

class FootmarkPageState extends State<FootmarkPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List _footmark = Global.footmarkListCache;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: const Text('足迹'),
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: '清空足迹',
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext content) {
                  return AlertDialog(
                    title: Text('是否清空足迹'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('确定'),
                        onPressed: () {
                          print('清空');
                          Global.cleanAllFootmark();
                          setState(() {
                            _footmark = Global.footmarkListCache;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _footmarkList(
        footMarkList: _footmark,
      ),
    );
  }
}

class _footmarkList extends StatefulWidget {
  List<MovieDetailModel> footMarkList;

  _footmarkList({Key key, this.footMarkList}) : super(key: key);

  @override
  _footmarkListState createState() {
    return _footmarkListState();
  }
}

class _footmarkListState extends State<_footmarkList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemCount: widget.footMarkList != null ? (widget.footMarkList.length + 1) : 0,
      itemBuilder: (BuildContext context, int index) {
        if (index == widget.footMarkList.length) {
          return Container(
            height: 40,
          );
        } else {
          MovieDetailModel model = widget.footMarkList[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque, //包括其他区域的点击
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Color(0xfff1f1f1)),
                  )),
              child: Row(
                children: <Widget>[
                  Container(
                    //海报
                    padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                    child: Image.network(
                      model.cover,
                      width: 80,
                      height: 120,
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: Adapt.screenCurrentW(context) - 80 - 10,
                    ),
                    height: 140,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 14, 0, 0),
                                child: Text(
                                  model.title,
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 15, 0, 0),
                                child: Text(
                                  '国家：${model.region}',
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Text(
                                  '主演：${model.mainActors}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                                child: Text(
                                  '年份：${model.releaseTime}',
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          height: 30,
                          width: 80,
                          child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                '观看至第${model.lastEpisodeIndex + 1}集',
                                style: TextStyle(
                                    color: Color(0xFF666666), fontSize: 11),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade600,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15.0)),
                              )),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            onTap: () {
              print('点击了----- ${model.title}');
              Map json = model.toJson();
              MovieListModel modelItem = MovieListModel.fromJson(json);
              Navigation.pushMovieDetail(context, model.movieID, modelItem);
            },
          );
        }
      },
    );
  }
}
