import 'movieDetailModel.dart';
import 'movieListModel.dart';

class eventBusBannerAd {
  bool isShow;
}

class eventBusAlertAd {
  bool isShow;
}

class eventBusCache {
  List<String> searchTextList; //搜索历史列表
  List<movieDetailModel> footmarkList;
  List<movieListModel> homeList;
}