import 'anime_provider.dart';
import 'translation.dart';

Map<String, AnimeProvider> get animeProviders => {
      'DMHY 動漫花園 [所有類別]': AnimeProvider(
        name: 'DMHY 動漫花園 [$trAllCategories]',
        searchUrl:
            'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&order=date-desc',
        latestUrl: 'https://share.dmhy.org/topics/rss/rss.xml',
      ),
      'DMHY 動漫花園 [動漫]': AnimeProvider(
        name: 'DMHY 動漫花園 [$trAnime]',
        searchUrl:
            'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=2&order=date-desc',
        latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/2/rss.xml',
      ),
      'DMHY 動漫花園 [動漫音樂]': AnimeProvider(
        name: 'DMHY 動漫花園 [$trAnimeSongs]',
        searchUrl:
            'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=43&order=date-desc',
        latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/43/rss.xml',
      ),
      'DMHY 動漫花園 [遊戲]': AnimeProvider(
        name: 'DMHY 動漫花園 [$trGames]',
        searchUrl:
            'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=9&order=date-desc',
        latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/9/rss.xml',
      ),
      'DMHY 動漫花園 [漫畫]': AnimeProvider(
        name: 'DMHY 動漫花園 [$trComics]',
        searchUrl:
            'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=3&order=date-desc',
        latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/3/rss.xml',
      ),
      'DMHY 動漫花園 [日劇]': AnimeProvider(
        name: 'DMHY 動漫花園 [$trJpTvShows]',
        searchUrl:
            'https://share.dmhy.org/topics/rss/rss.xml?keyword=%q&sort_id=6&order=date-desc',
        latestUrl: 'https://share.dmhy.org/topics/rss/sort_id/6/rss.xml',
      ),
      'ACG.RIP [所有分類]': AnimeProvider(
        name: 'ACG.RIP [$trAllCategories]',
        searchUrl: 'https://acg.rip/.xml?term=%q',
        latestUrl: 'https://acg.rip/.xml',
      ),
      'ACG.RIP [動漫]': AnimeProvider(
        name: 'ACG.RIP [$trAnime]',
        searchUrl: 'https://acg.rip/1.xml?term=%q',
        latestUrl: 'https://acg.rip/1.xml',
      ),
      'Bangumi Moe': AnimeProvider(
          name: 'Bangumi Moe',
          searchUrl: 'https://bangumi.moe/rss/search/%q',
          latestUrl: 'https://bangumi.moe/rss/latest'),
      'KissSub [所有分類]': AnimeProvider(
          name: 'KissSub [$trAllCategories]',
          searchUrl: 'https://www.kisssub.org/rss-%q.xml',
          latestUrl: 'https://www.kisssub.org/rss.xml'),
      'KissSub [動漫]': AnimeProvider(
          name: 'KissSub [$trAnime]',
          searchUrl: 'https://kisssub.org/rss-%q+sort_id:1.xml',
          latestUrl: 'https://www.kisssub.org/rss-1.xml'),
      'KissSub [漫畫]': AnimeProvider(
          name: 'KissSub [$trComics]',
          searchUrl: 'https://kisssub.org/rss-%q+sort_id:2.xml',
          latestUrl: 'https://www.kisssub.org/rss-2.xml'),
      'KissSub [音樂]': AnimeProvider(
          name: 'KissSub [$trMusic]',
          searchUrl: 'https://kisssub.org/rss-%q+sort_id:3.xml',
          latestUrl: 'https://www.kisssub.org/rss-3.xml'),
      'KissSub [其他]': AnimeProvider(
          name: 'KissSub [$trOtherCategories]',
          searchUrl: 'https://kisssub.org/rss-%q+sort_id:5.xml',
          latestUrl: 'https://www.kisssub.org/rss-5.xml'),
      'Mikan': AnimeProvider(
        name: 'Mikan',
        searchUrl: 'http://mikanani.me/RSS/Search?searchstr=%q',
        latestUrl: 'http://mikanani.me/RSS/Classic',
      ),
      'Nyaa [所有分類]': AnimeProvider(
        name: 'Nyaa [$trAllCategories]',
        searchUrl: 'https://nyaa.si/?page=rss&q=%q',
        latestUrl: 'https://nyaa.si/?page=rss',
      ),
      'Nyaa [動漫]': AnimeProvider(
        name: 'Nyaa [$trAnime]',
        searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=1_0&f=0',
        latestUrl: 'https://nyaa.si/?page=rss&c=1_0&f=0',
      ),
      'Nyaa [音樂]': AnimeProvider(
        name: 'Nyaa [$trMusic]',
        searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=2_0&f=0',
        latestUrl: 'https://nyaa.si/?page=rss&c=2_0&f=0',
      ),
      'Nyaa [無損音樂]': AnimeProvider(
        name: 'Nyaa [$trLosslessMusic]',
        searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=2_1&f=0',
        latestUrl: 'https://nyaa.si/?page=rss&c=2_1&f=0',
      ),
      'Nyaa [小說]': AnimeProvider(
        name: 'Nyaa [$trLiterature]',
        searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=3_0&f=0',
        latestUrl: 'https://nyaa.si/?page=rss&c=3_0&f=0',
      ),
      'Nyaa [圖片]': AnimeProvider(
        name: 'Nyaa [$trPhotos]',
        searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=5_0&f=0',
        latestUrl: 'https://nyaa.si/?page=rss&c=5_0&f=0',
      ),
      'Nyaa [軟體]': AnimeProvider(
        name: 'Nyaa [$trSoftware]',
        searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=6_1&f=0',
        latestUrl: 'https://nyaa.si/?page=rss&c=6_1&f=0',
      ),
      'Nyaa [遊戲]': AnimeProvider(
        name: 'Nyaa [$trGames]',
        searchUrl: 'https://nyaa.si/?page=rss&q=%q&c=6_2&f=0',
        latestUrl: 'https://nyaa.si/?page=rss&c=6_2&f=0',
      ),
    };
