class movieDetailModel {
  String director; //导演
  String screenwriter; //编剧
  int episodeTotal; //总集数(>0展示)
  String language; //语言
  Map<String, dynamic> links; //具体播放连接列表
  String mainActors; //主演
  String region; //地区
  String releaseTime; //年份
  String site; //详情页默认展示站点
  String summary; //"简介"
  String tags; //"剧情 战争"
  String title;

  int lastEpisodeIndex; //最后观看集数，本地缓存使用
  String lastEpisodeName;
  int movieID; //id
  String cover; //封面

  movieDetailModel({
    this.director,
    this.episodeTotal,
    this.language,
    this.links,
    this.mainActors,
    this.screenwriter,
    this.region,
    this.releaseTime,
    this.site,
    this.summary,
    this.tags,
    this.title,
    this.lastEpisodeIndex,
    this.lastEpisodeName,
    this.movieID,
    this.cover,
  });

  factory movieDetailModel.fromJson(Map<String, dynamic> json) {
    return movieDetailModel(
      director: json['director'],
      episodeTotal: json['episodeTotal'],
      screenwriter: json['screenwriter'],
      language: json['language'],
      links: json['links'] != null ? linksfromJson(json['links']) : null,
      mainActors: json['mainActors'],
      region: json['region'],
      releaseTime: json['releaseTime'],
      site: json['site'],
      summary: json['summary'],
      tags: json['tags'],
      title: json['title'],
      lastEpisodeIndex: json['lastEpisodeIndex'],
      lastEpisodeName: json['lastEpisodeName'],
      movieID: json['movieID'],
      cover: json['cover'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['director'] = this.director;
    data['episodeTotal'] = this.episodeTotal;
    data['language'] = this.language;
    data['mainActors'] = this.mainActors;
    data['region'] = this.region;
    data['releaseTime'] = this.releaseTime;
    data['site'] = this.site;
    data['summary'] = this.summary;
    data['tags'] = this.tags;
    data['title'] = this.title;
    if (this.links != null) {
      data['links'] = this.linkstoJson();
    }
    data['lastEpisodeName'] = this.lastEpisodeName;
    data['lastEpisodeIndex'] = this.lastEpisodeIndex;
    data['movieID'] = this.movieID;
    data['cover'] = this.cover;
    return data;
  }

  static Map<String, dynamic> linksfromJson(Map<String, dynamic> mapJson) {
    final Map<String, dynamic> mapJ = Map();
    for (String key in mapJson.keys) {
      List dataArray = mapJson[key];
      List modelList =
          dataArray.map((item) => LinkItemModel.fromJson(item)).toList();
      mapJ[key] = modelList;
    }
    return mapJ;
  }

  Map<String, dynamic> linkstoJson() {
    final Map<String, dynamic> mapString = new Map<String, dynamic>();
    if (this.links != null) {
      for (String key in this.links.keys) {
        List<LinkItemModel> listDataArray = this.links[key];
        List listJson = listDataArray.map((item) => item.toJson()).toList();
        mapString[key] = listJson;
      }
    }
    return mapString;
  }
}

class LinkItemModel {
  String episodeName;
  String realPlayLink;
  String site;
  int id;
  String link;

  LinkItemModel(
      {this.episodeName, this.realPlayLink, this.site, this.id, this.link});

  factory LinkItemModel.fromJson(Map<String, dynamic> json) {
    return LinkItemModel(
      episodeName: json['episodeName'],
      realPlayLink: json['realPlayLink'],
      site: json['site'],
      id: json['id'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['episodeName'] = this.episodeName;
    data['realPlayLink'] = this.realPlayLink;
    data['site'] = this.site;
    data['id'] = this.id;
    data['link'] = this.link;
    return data;
  }
}
