enum FeedType {
  rss, atom
}

class AnimeProvider {
  final String name;
  final String latestUrl;
  final String searchUrl;
  final FeedType feedType;

  AnimeProvider({
    required this.name,
    required this.latestUrl,
    required this.searchUrl,
    this.feedType = FeedType.rss,
  });

  String searchUrlKeyword(String keyword) => searchUrl.replaceAll('%q', keyword); 
}
