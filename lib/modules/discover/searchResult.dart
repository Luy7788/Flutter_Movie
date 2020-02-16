import 'package:flutter/material.dart';
import 'package:nmtv/common/model/movieListModel.dart';
import 'package:nmtv/common/utils/global.dart';
import 'package:nmtv/modules/widget/moviesList.dart';

class searchResult extends StatefulWidget {
  String keyword;

//  searchResult({this.searchId}) : super();
  searchResult({Key key, this.keyword}) : super(key: key);

  @override
  _searchResultState createState() {
    return _searchResultState();
  }
}

class _searchResultState extends State<searchResult> {
  List<movieListModel> _recommendMovieItems = []; //推荐列表

  @override
  void initState() {
    super.initState();
    _loadMovie();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //加载视频
  Future _loadMovie() async {
    await Global.movieList(
      category: "",
      keyword: widget.keyword ?? "美剧",
      pageNum: 1,
    ).then((movieList) {
      setState(() {
        _recommendMovieItems = movieList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('搜索结果'),
      ),
      body: MoviesList.custom(
        movieItems: _recommendMovieItems,
        isCanScroll: true,
      ),
    );
  }
}
