import 'package:flutter/material.dart';
import 'package:nmtv/common/utils/navigation.dart';
import 'package:nmtv/common/config/config.dart';
import 'package:nmtv/common/model/movieListModel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MoviesList extends StatelessWidget {
  List<MovieListModel> movieItems = List();
  bool isCanScroll = true;
  double inset = 10;
  ScrollController scrollController = ScrollController();

  MoviesList() : super();

  MoviesList.custom(
      {this.movieItems,
      this.isCanScroll = true,
      this.inset = 10,
      this.scrollController})
      : super();

  @override
  Widget build(BuildContext context) {
    return this.renderBody();
  }

  Widget renderBody() {
    return GridView.builder(
      controller: this.scrollController,
      shrinkWrap: true,
      itemCount: this.movieItems != null ? this.movieItems.length : 0,
      physics: this.isCanScroll
          ? AlwaysScrollableScrollPhysics()
          : NeverScrollableScrollPhysics(),
      padding:
          EdgeInsets.fromLTRB(this.inset, this.inset, this.inset, this.inset),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(0),
          elevation: 2.0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, //包括其他区域的点击
            onTap: () {
              MovieListModel model = this.movieItems[index];
              print(model.title);
              Navigation.pushMovieDetail(context, model.id, model);
            },
            child: Programme(data: this.movieItems[index]),
          ),
        );
      },
    );
  }
}

class Programme extends StatelessWidget {
  final MovieListModel data;

  const Programme({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double coverSize = 110;
    return Column(
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                CachedNetworkImage(
                  fit: BoxFit.cover,
                  placeholder: (context, url) => new Container(
                    child: new Center(
                      child: new CircularProgressIndicator(),
                    ),
                    width: 160.0,
                    height: 90.0,
                  ),
                  imageUrl: this.data.cover,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    height: 20,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Color(0xA0000000),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ' ${this.data.score} 分',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  //阴影层
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: coverSize / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        //渐变色
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color.fromARGB(100, 0, 0, 0)
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  //阴影层中的文字
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 13,
                        ),
                        Padding(padding: EdgeInsets.only(left: 5)),
                        Text(
                          '更新至${this.data.episodeNewest}集',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ].where((item) => item != null).toList(),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 5)),
        SizedBox(
          width: 300,
          height: 40,
          child: Text(
            this.data.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            //文字超出屏幕之后的处理方式  TextOverflow.clip剪裁   TextOverflow.fade 渐隐  TextOverflow.ellipsis省略号
            textAlign: TextAlign.left,
            //文本对齐方式
            textDirection: TextDirection.rtl,
            //文本方向
            style: TextStyle(
              fontSize: 13.7,
              fontWeight: FontWeight.w400,
              height: 1.1,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}
