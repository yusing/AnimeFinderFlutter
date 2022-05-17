import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/service/settings.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final void Function() onTap;
  const AnimeCard({super.key, required this.anime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            color: kBackgroundColor,
            borderRadius:
                const BorderRadius.all(Radius.circular(kAnimeCardBorderRadius)),
            boxShadow: [
              BoxShadow(
                color: kOnBackgroundColor.withOpacity(0.2),
                spreadRadius: 4,
                blurRadius: 5,
              ),
            ]),
        alignment: Alignment.center,
        child: (Settings.instance.layoutOrientation.value == "auto"
                    ? MediaQuery.of(context).orientation
                    : Orientation.values.where((ori) =>
                        Settings.instance.layoutOrientation.value == ori.toString())) ==
                Orientation.portrait
            ? _verticalLayout()
            : _horizontalLayout(context),
      ),
    );
  }

  Widget _horizontalLayout(context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.3),
                child: anime.image()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: _textPart(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalLayout() {
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
        child: _textPart(),
      ),
    );
  }

  Widget _textPart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AutoSizeText(
          anime.title ?? "沒有標題",
          style: kTitleSmall,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Visibility(
          visible: anime.provider != null,
          child: AutoSizeText(
            '字幕組：' + (anime.provider ?? ''),
            style: kBodySmall,
            minFontSize: 9,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }

  // _showDescriptionDialog(BuildContext context, Anime anime) {
  //   Get.defaultDialog(
  //       backgroundColor: kBackgroundColor,
  //       title: "動漫簡介",
  //       titleStyle: kHeadlineMedium,
  //       content: FutureText(
  //           future: anime.description,
  //           placeHolder: '載入中...',
  //           style: kBodyLarge));
  // }
}
