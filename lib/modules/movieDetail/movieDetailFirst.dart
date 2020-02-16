import 'package:flutter/material.dart';
import 'package:nmtv/common/model/movieDetailModel.dart';
import 'package:nmtv/common/model/movieListModel.dart';
import 'package:nmtv/modules/widget/moviesList.dart';
import 'package:nmtv/common/config/adapt.dart';

/*第一页 剧集和推荐*/
class movieDetailFirst extends StatefulWidget {
  movieDetailModel _detailModel; //详情模型
  List<String> _indexTitles = []; //[第一集、第二集]
  List<movieListModel> _recommendMovieItems = []; //推荐列表
  int _curentLinkIndex; //当前采用的线路下的当前选集 模型的index
  var _selectLinkItemAction; //选集事件
  var _selectShowBottomSheetAction; //选线路事件
  bool _isCurrentSelectSite = true;

  movieDetailFirst({Key key}) : super(key: key);

  movieDetailFirst.custom(
    this._detailModel,
    this._indexTitles,
    this._recommendMovieItems,
    this._curentLinkIndex,
    this._isCurrentSelectSite,
    this._selectLinkItemAction,
    this._selectShowBottomSheetAction,
  ) : super();

  @override
  _movieDetailFirstState createState() {
    return _movieDetailFirstState();
  }
}

class _movieDetailFirstState extends State<movieDetailFirst> {
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
    return ListView(
      padding: EdgeInsets.fromLTRB(8, 10, 8, 2),
      children: <Widget>[
        Container(
          height: 40.0,
          alignment: Alignment.centerLeft,
          constraints: BoxConstraints(
            maxHeight: 70,
          ),
          child: Text(
            widget._detailModel.title ?? "",
            textAlign: TextAlign.left,
            softWrap: true,
            style: TextStyle(
              fontSize: 22,
              height: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
//        Padding(
//          padding: EdgeInsets.only(top: 10.0),
//        ),
        Container(
          height: 44.0,
          child: _selectILinkTitleWidget(),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
        ),
        _selectLinkWidget(
          widget._indexTitles,
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0),
        ),
        _titleTextWidget('相关推荐'),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
        ),
        Container(
          child: MoviesList.custom(
            movieItems: widget._recommendMovieItems,
            isCanScroll: false,
            inset: 0.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
        ),
      ],
    );
  }

  Text _titleTextWidget(String text) {
    return Text(
      text,
      textAlign: TextAlign.left,
      softWrap: true,
      style: TextStyle(
        fontSize: 16,
        height: 1.2,
        color: Color(0xFF666666),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  //选集栏
  Stack _selectILinkTitleWidget() {
    return Stack(
      fit: StackFit.loose,
      alignment: AlignmentDirectional.centerStart,
      children: <Widget>[
        Positioned(
          child: _titleTextWidget('选集'),
          left: 0,
        ),
        Positioned(
          right: 0,
          height: 30,
//          width: 80,
          child: MaterialButton(
            child: Text(
              '切换线路: ▽',
              style: TextStyle(fontSize: 13.0),
            ),
            onPressed: () {
              widget._selectShowBottomSheetAction();
            },
          ),
        )
      ],
    );
  }

  //选集
  Wrap _selectLinkWidget(List<String> titles) {
    return Wrap(
      spacing: 18, //主轴上子控件的间距
      runSpacing: 15, //交叉轴上子控件之间的间距
      children: List.generate(titles.length, (index) {
        return InkWell(
          //水波纹
          onTap: () {
            print("-------点击了标题" + "${titles[index]}");
            widget._selectLinkItemAction(index);
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(7, 1, 7, 1),
            decoration: BoxDecoration(
//              color: Color(0xFF333333),
              borderRadius: BorderRadius.all(Radius.circular(4)),
              border: new Border.all(
                width: 0.8,
                color: index == widget._curentLinkIndex && widget._isCurrentSelectSite == true
                    ? Color(0xFF333333)
                    : Color(0xFF999999),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: Adapt.screenCurrentW(context),
              maxHeight: 30,
            ),
            child: Text(
              "${titles[index]}",
              style: TextStyle(
                color: index == widget._curentLinkIndex && widget._isCurrentSelectSite == true
                    ? Color(0xFF333333)
                    : Color(0xFF999999),
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }), //要显示的子控件集合
    );
  }
}
