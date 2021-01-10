class MovieListModel {
    String cover;
    int episodeNewest;
    int episodeTotal;
    int id;
    double score;
    String title;

    MovieListModel({this.cover, this.episodeNewest, this.episodeTotal, this.id, this.score, this.title});

    factory MovieListModel.fromJson(Map<String, dynamic> json) {
        return MovieListModel(
            cover: json['cover'],
            episodeNewest: json['episodeNewest'],
            episodeTotal: json['episodeTotal'],
            id: json['id'],
            score: json['score'],
            title: json['title'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['cover'] = this.cover;
        data['episodeNewest'] = this.episodeNewest;
        data['episodeTotal'] = this.episodeTotal;
        data['id'] = this.id;
        data['score'] = this.score;
        data['title'] = this.title;
        return data;
    }
}