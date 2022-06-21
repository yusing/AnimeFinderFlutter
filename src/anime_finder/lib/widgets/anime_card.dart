import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/service/settings.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';

// TODO: move orientation builder to anime_list.dart
class AnimeCard extends GestureDetector {
  final Anime anime;
  AnimeCard({
    super.key,
    required super.onTap,
    required this.anime,
  }) : super(
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: const BorderRadius.all(
                        Radius.circular(kAnimeCardBorderRadius)),
                    boxShadow: [
                      BoxShadow(
                        color: kOnBackgroundColor.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 1,
                      ),
                    ]),
                alignment: Alignment.center,
                child: OrientationBuilder(builder: (context, orientation) {
                  orientation = MediaQuery.of(context).orientation;
                  if (Settings.layoutOrientation.value != "auto") {
                    orientation = Orientation.values.firstWhere((ori) =>
                        Settings.layoutOrientation.value == ori.toString());
                  }
                  return orientation == Orientation.portrait
                      ? verticalLayout(anime)
                      : horizontalLayout(anime, context);
                })));

  static Widget horizontalLayout(Anime anime, context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                    width: MediaQuery.of(context).size.width * 0.3),
                child: anime.image()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: textPart(anime),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget verticalLayout(Anime anime) {
    return ListTile(
      horizontalTitleGap: 0,
      minLeadingWidth: 0,
      minVerticalPadding: 0,
      contentPadding: const EdgeInsets.all(0),
      dense: true,
      title: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 400,
          ),
          child: anime.image()),
      subtitle: Padding(
        padding: const EdgeInsets.all(16),
        child: textPart(anime),
      ),
    );
  }

  static Widget textPart(Anime anime) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              anime.title ?? "(NULL)",
              style: kTitleSmall,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Visibility(
              visible: anime.provider != null,
              child: Text(
                '$trProvider: ${anime.provider ?? ''}',
                style: kBodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]);
}
