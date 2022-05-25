import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'libtorrent.g.dart';

final libtorrent = LibTorrent(
    DynamicLibrary.open('${Directory.current.path}/build/libtorrent.dylib'));

Pointer<Char> toCStr(String dartString) {
  return dartString.toNativeUtf8().cast<Char>();
}

const String savePath =
    '/Users/yusing/Documents/GitHub/AnimeFinderFlutter/src/libtorrent/test_dl/';
final pathCString = toCStr(savePath);

void main() {
  libtorrent.init_session();
  final torrent = libtorrent.add_torrent(
      toCStr('magnet:?xt=urn:btih:HJIR6R5QT4SFVOOEHHSQF2LV6VBM4NBY'),
      pathCString);
  while (true) {
    print(
        '${torrent.ref.name.cast<Utf8>().toDartString()}: ${libtorrent.torrent_state(torrent.ref.state).cast<Utf8>().toDartString()} (${(torrent.ref.progress * 100).toStringAsFixed(2)}%)');
    sleep(Duration(seconds: 1));
    libtorrent.update_torrent(torrent);
  }

  // final result = libtorrent
  //     .remove_torrent_delete_files(toCStr('HJIR6R5QT4SFVOOEHHSQF2LV6VBM4NBY'));
  // print(result.cast<Utf8>().toDartString());
}
