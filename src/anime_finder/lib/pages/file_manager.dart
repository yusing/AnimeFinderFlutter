import 'dart:async';
import 'dart:io';

import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/service/open_file.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:anime_finder/utils/show_toast.dart';
import 'package:anime_finder/widgets/af_animated_list.dart';
import 'package:anime_finder/widgets/af_page.dart';
import 'package:anime_finder/widgets/slidable_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

class FileManager extends StatefulWidget {
  FileManager({super.key, String? path})
      : rootPath = path ?? torrentSavePathRoot;

  final String rootPath;

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  final globalKey = GlobalKey<AnimatedListState>();
  final entities = <FileSystemEntity>[];
  late StreamSubscription<FileSystemEntity> fileUpdateSubscription;

  @override
  void initState() {
    fileUpdateSubscription = Directory(widget.rootPath).list().listen((entity) {
      entities.add(entity);
      globalKey.currentState!.insertItem(entities.length - 1);
    }, onDone: () {
      fileUpdateSubscription.cancel();
      if (entities.isEmpty) {
        Get.back();
        showToast(
          message: 'Empty folder',
        );
      }
      if (entities.length == 1 && entities.first is Directory) {
        Get.off(
            () => AFPage(
                title: basename(entities.first.path),
                body: FileManager(path: entities.first.path)),
            routeName: basename(entities.first.path));
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    fileUpdateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AFAnimatedList(
        key: globalKey, initialItemCount: 0, builder: buildItem);
  }

  Widget buildItem(BuildContext context, int index) {
    final entity = entities[index];
    String filename = basename(entity.path);
    if (widget.rootPath == torrentSavePathRoot) {
      filename = torrentNamesMap[filename] ?? filename;
    }
    return Visibility(
      visible: filename != 'session.db',
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            DeleteSlidableAction(onPressed: (_) {
              AFAnimatedList.removeItem(globalKey, index, () {
                entities.removeAt(index);
                try {
                  entity.deleteSync(recursive: true);
                } catch (e) {
                  showToast(message: 'Error deleting file');
                }
              });
            })
          ],
        ),
        child: ListTile(
            leading: Icon(
                entity is Directory ? Icons.folder : Icons.insert_drive_file),
            title: Text(filename, style: kBodyMedium),
            onTap: () async {
              if (entity is Directory) {
                debugPrint(entity.path);
                Get.to(
                    () => AFPage(
                          title: filename,
                          body: FileManager(path: entity.path),
                        ),
                    routeName: basename(entity.path));
              } else {
                await openFile(entity.path,
                    name: basename(entity.path), folderPath: widget.rootPath);
              }
            }),
      ),
    );
  }
}
