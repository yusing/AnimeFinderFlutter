import 'package:get_storage/get_storage.dart';

class SearchHistory {
  static final _box = GetStorage();

  static List<String> fetch() {
    var history = _box.read<String>('searchHistory');
    if (history == null || history.isEmpty) {
      return [];
    }
    return history.split('\n');
  }

  static void add(String keyword) {
    final history = fetch();
    if (history.length >= 20) {
      history.removeLast();
    }
    if (history.contains(keyword)) {
      return;
    }
    history.insert(0, keyword);
    _box.write('searchHistory', history.join('\n'));
  }

  static void remove(int index) {
    final history = fetch();
    history.removeAt(index);
    _box.write('searchHistory', history.join('\n'));
  }
}
