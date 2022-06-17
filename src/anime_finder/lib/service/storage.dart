import 'package:get_storage/get_storage.dart';

Future<void> initStorage() async {
  await GetStorage.init();
  _prefs = GetStorage();
}

GetStorage getStorage() {
  return _prefs;
}

Future<void> clearStorage() async {
  await _prefs.erase();
}

Future<void> setPref<T>(String key, T value) async {
  await _prefs.write(key, value);
}

T? getPref<T>(String key) {
  return _prefs.read(key);
}

Future<void> removePref(String key) async {
  await _prefs.remove(key);
}

late final GetStorage _prefs;
