import 'dart:io';

import 'package:anime_finder/service/libtorrent.dart';
import 'package:anime_finder/theme/style.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';

class FileManager extends StatefulWidget {
  FileManager({Key? key, String? rootPath})
      : rootPath = rootPath ?? torrentSavePathRoot,
        super(key: key);

  final String rootPath;

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  final List<String> _subPaths = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
        future: Directory(join(widget.rootPath, joinAll(_subPaths)))
            .list()
            .toList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final entity = snapshot.data![index];
                  return ListTile(
                      leading: Icon(entity is Directory
                          ? Icons.folder
                          : Icons.insert_drive_file),
                      title: Text(basename(entity.path), style: kBodyMedium),
                      onTap: () {
                        if (entity is Directory) {
                          setState(() {
                            _subPaths.add(entity.path);
                          });
                        } else {
                          // TODO: open file
                        }
                      });
                });
          } else if (snapshot.hasError) {
            Logger().e('File manager error: ', snapshot.error);
            return const Icon(Icons.error_outline);
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
