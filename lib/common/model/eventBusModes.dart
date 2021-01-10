import 'movieDetailModel.dart';
import 'movieListModel.dart';

class EventBusBannerAd {
  bool isShow;
}

class EventBusAlertAd {
  bool isShow;
}

class EventBusCache {
  List<String> searchTextList; //搜索历史列表
  List<MovieDetailModel> footmarkList;
  List<MovieListModel> homeList;
}