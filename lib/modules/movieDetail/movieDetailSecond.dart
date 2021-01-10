import 'package:flutter/material.dart';

/*第二页 详情页面*/
class MovieDetailSecond extends StatelessWidget {
  final String _director; //"导演"
  final String _screenwriter; //"编剧",
  final String _mainActors; //"主演"
  final String _region; //地区
  final String _language; //语言
  final String _summary; //"简介"
  final String _releaseTime; //年份
  final String _title;

  MovieDetailSecond.custom(
      this._title,
      this._director,
      this._screenwriter,
      this._mainActors,
      this._region,
      this._language,
      this._summary,
      this._releaseTime)
      : super();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 12, 10, 2),
      child: ListView(
        padding: EdgeInsets.only(top: 10.0),
        children: <Widget>[
          Text(
            this._title,
            textAlign: TextAlign.left,
            softWrap: true,
            style: TextStyle(
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10.0)),
          textLabel('导演：${this._director}'),
          Padding(padding: EdgeInsets.only(top: 4.0)),
          textLabel('编剧：${this._screenwriter}'),
          Padding(padding: EdgeInsets.only(top: 4.0)),
          textLabel('主演：${this._mainActors}'),
          Padding(padding: EdgeInsets.only(top: 4.0)),
          textLabel('地区：${this._region}'),
          Padding(padding: EdgeInsets.only(top: 4.0)),
          textLabel('语言：${this._language}'),
          Padding(padding: EdgeInsets.only(top: 4.0)),
          textLabel('年份：${this._releaseTime}'),
          Padding(padding: EdgeInsets.only(top: 4.0)),
          textLabel('简介：${this._summary}'),
          Padding(padding: EdgeInsets.only(top: 10.0)),
        ],
      ),
    );
  }

  Text textLabel(String text) {
    return Text(
      text,
      softWrap: true, //换行
      style: TextStyle(
        fontSize: 15,
        height: 1.4,
        wordSpacing: 4.0,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
