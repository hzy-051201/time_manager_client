class WebCrawlerWeb {
  final int id;
  final String name;
  final String summary;
  final DateTime lastCrawl;

  const WebCrawlerWeb({
    required this.id,
    required this.name,
    required this.summary,
    required this.lastCrawl,
  });

  WebCrawlerWeb.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"],
        summary = map["summary"],
        lastCrawl = DateTime.parse(map["lastCrawl"]).toLocal();
}
