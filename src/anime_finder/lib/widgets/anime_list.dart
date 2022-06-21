import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/show_toast.dart';
import 'package:anime_finder/widgets/anime_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AnimeList extends StatelessWidget {
  final Future<List<Anime>> animeListFuture;
  const AnimeList({super.key, required this.animeListFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Anime>>(
      future: animeListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(trPageNthYet),
            );
          }
          return ListView.separated(
              separatorBuilder: (_, index) => const SizedBox(
                    height: 16,
                  ),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                final anime = snapshot.data![index];
                return AnimeCard(
                    anime: anime,
                    onTap: () => _showDownloadDialog(
                        anime, MediaQuery.of(context).size));
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

  _showDownloadDialog(Anime anime, Size size) {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(16),
      radius: 12,
      title: trAbout,
      titleStyle: kTitleMedium,
      content: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: BoxConstraints.loose(Size(
          size.width * 0.8,
          size.height * 0.6,
        )),
        child: SingleChildScrollView(
          child: Center(
            child: Html(
              data: anime.misc,
              shrinkWrap: true,
              onLinkTap: (url, _, __, ___) async {
                if (url != null && await canLaunchUrlString(url)) {
                  await launchUrlString(url);
                }
              },
            ),
          ),
        ),
      ),
      confirm: ElevatedButton(
        child: Text(trDownload, style: kLabelSmall),
        onPressed: () async {
          if (anime.magnetUrl == null) {
            await showToast(message: trNoMagnetUrl, title: trDownloadError);
            return;
          }
          Get.back(closeOverlays: true); // close dialog
          showToast(message: trDownloadAdded, title: anime.title ?? "");
          await addTorrent(anime.title ?? anime.magnetUrl!, anime.magnetUrl!);
        },
      ),
      cancel: ElevatedButton(
        child: Text(trCancel, style: kLabelSmall),
        onPressed: () => Get.back(), // close dialog
      ),
      backgroundColor: kBackgroundColor,
    );
  }
}
