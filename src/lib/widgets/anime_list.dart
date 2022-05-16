import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/widgets/anime_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimeList extends StatefulWidget {
  final Future<List<Anime>> future;
  const AnimeList({super.key, required this.future});

  @override
  State<AnimeList> createState() => _AnimeListState();
}

class _AnimeListState extends State<AnimeList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Anime>>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('甚麼都沒有...'),
            );
          }
          return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(
                    height: 32,
                  ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final anime = snapshot.data![index];
                return AnimeCard(
                    anime: anime, onTap: () => _showDownloadDialog(anime));
              });
        } else if (snapshot.hasError) {
          return Center(
            child: Text('${snapshot.error}'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  _showDownloadDialog(Anime anime) {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(16),
      radius: 12,
      title: "下載確認",
      titleStyle: kTitleMedium,
      content: Text(
        "是否下載\n${anime.title}?",
        softWrap: true,
        style: kBodyMedium,
      ),
      actions: [
        MaterialButton(
          child: Text("下載", style: kLabelSmall),
          onPressed: () {
            anime.download().then((value) {
              Get.snackbar(
                "正在下載",
                anime.title ?? "",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: kBackgroundColor,
                duration: kSnackbarDuration,
              );
            }).onError((e, st) {
              Get.snackbar(
                "下載失敗",
                e.toString(),
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: kBackgroundColor,
                duration: const Duration(seconds: 2),
              );
            });
            Get.back(closeOverlays: true);
          },
        ),
        MaterialButton(
          child: Text("取消", style: kLabelSmall),
          onPressed: () => Get.back(),
        ),
      ],
      backgroundColor: kBackgroundColor,
    );
  }
}
