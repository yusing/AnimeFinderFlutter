import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/service/open_file.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FileList extends ListView {
  FileList(Torrent torrent, List<FileInfo> files, {super.key})
      : super.separated(
          addSemanticIndexes: false,
          controller: ScrollController(),
          shrinkWrap: true,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final fileInfo = files[index];
            if (fileInfo.name.startsWith('__')) {
              return const SizedBox();
            }
            return Visibility(
              child: ListTile(
                minVerticalPadding: 0,
                minLeadingWidth: 0,
                visualDensity: VisualDensity.compact,
                dense: true,
                leading: const Icon(CupertinoIcons.doc),
                title: FutureBuilder<String>(
                    future: Future.value(fileInfo.name),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done ||
                          snapshot.data == null) {
                        return Text('...', style: kBodySmall);
                      }
                      return Text(snapshot.data!, style: kBodySmall);
                    }),
                trailing:
                    Text(fileInfo.size.toReadableSize(), style: kBodySmall),
                onTap: () async => await openFile(fileInfo.fullPath,
                    name: torrent.name, folderPath: torrent.savePath),
              ),
            );
          },
        );
}
