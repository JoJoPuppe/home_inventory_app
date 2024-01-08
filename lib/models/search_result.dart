class SearchResult {
  final String? name;
  final String? comment;
  final double? rank;

  SearchResult({
    this.name,
    this.comment,
    this.rank,
  });

  SearchResult.fromJson(Map<String, dynamic> json)
        : name = json['name'] as String?,
          comment = json['comment'] as String?,
          rank = json['rank'] as double?;
}
