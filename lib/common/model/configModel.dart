class configModel {
  String startupBanner;
  String searchPh;
  String js;
  bool enableCache;
  bool enableReview;
  bool enableAdnet = false;
  StartupMsgBean startupMsg;
  List<String> category;
  List<String> search;
  List<String> tags;

  configModel({this.startupBanner, this.searchPh, this.js, this.enableCache, this.enableReview, this.startupMsg, this.category, this.search, this.tags});

  configModel.fromJson(Map<String, dynamic> json) {    
    this.startupBanner = json['startup_banner'];
    this.searchPh = json['search_ph'];
    this.js = json['js'];
    this.enableCache = json['enable_cache'];
    this.enableReview = json['enable_review'];
    this.enableAdnet = json['enable_adnet'];
    this.startupMsg = json['startup_msg'] != null ? StartupMsgBean.fromJson(json['startup_msg']) : null;

    List<dynamic> categoryList = json['category'];
    this.category = new List();
    this.category.addAll(categoryList.map((o) => o.toString()));

    List<dynamic> searchList = json['search'];
    this.search = new List();
    this.search.addAll(searchList.map((o) => o.toString()));

    List<dynamic> tagsList = json['tags'];
    this.tags = new List();
    this.tags.addAll(tagsList.map((o) => o.toString()));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startup_banner'] = this.startupBanner;
    data['search_ph'] = this.searchPh;
    data['js'] = this.js;
    data['enable_cache'] = this.enableCache;
    data['enable_review'] = this.enableReview;
    data['enable_adnet'] = this.enableAdnet;
    if (this.startupMsg != null) {
      data['startup_msg'] = this.startupMsg.toJson();
    }
    data['category'] = this.category;
    data['search'] = this.search;
    data['tags'] = this.tags;
    return data;
  }
}

class StartupMsgBean {
  String id;
  String msg;
  int level = 0;
  int code = 0;
  int showTimes = 0;

  StartupMsgBean({this.id, this.msg, this.level, this.code, this.showTimes});

  StartupMsgBean.fromJson(Map<String, dynamic> json) {    
    this.id = json['id'];
    this.msg = json['msg'];
    this.level = json['level'];
    this.code = json['code'];
    this.showTimes = json['show_times'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['msg'] = this.msg;
    data['level'] = this.level;
    data['code'] = this.code;
    data['show_times'] = this.showTimes;
    return data;
  }
}
