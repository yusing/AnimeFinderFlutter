import 'package:anime_finder/service/anime.dart';
import 'package:anime_finder/service/translation.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/widgets/anime_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              child: Text(trPageNothingYet),
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
    final formKey = GlobalKey<FormState>();
    final filenameController = TextEditingController(text: anime.title);

    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(16),
      radius: 12,
      title: trConfirmation,
      titleStyle: kTitleMedium,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: filenameController,
              style: kBodySmall,
              decoration: InputDecoration(
                icon: const Icon(Icons.file_download),
                labelText: trFilename,
                labelStyle: kBodyMedium,
                contentPadding: const EdgeInsets.only(bottom: 8),
              ),
              validator: (value) {
                if (value?.isEmpty ?? false) {
                  return trFilenameEmptyError;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        MaterialButton(
          child: Text(trDownload, style: kLabelSmall),
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) {
              return; // invalid input
            }
            anime.download(filenameController.text).then((value) {
              Get.snackbar(
                trDownloadAdded,
                anime.title ?? "",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: kBackgroundColor,
                duration: kSnackbarDuration,
              );
            }).onError((e, st) {
              Get.snackbar(
                trDownloadError,
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
          child: Text(trCancel, style: kLabelSmall),
          onPressed: () => Get.back(),
        ),
      ],
      backgroundColor: kBackgroundColor,
    ).then((value) {
      filenameController.dispose();
    });
  }
}
