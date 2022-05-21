import 'package:get/get.dart';

import 'settings.dart';

class TranslationService extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'colon': ':',
          'qbt_error_msg':
              'Unable to communicate with qBittorrent\nPlease check your connection',
          'no_magnet_url': 'No magnet URL found for this item',
          'connection_error': 'Connection error',

          'page_nth_yet': 'Nothing here...',
          'resume_dl': 'Resume download',
          'pause_dl': 'Pause download',
          
          'open_file': 'Open file',
          'open_file_location': 'Open file location',
          'delete': 'Delete',
          'searchbar_hint': 'Search anything...',
          'searchbar_empty': 'Please enter a search term',
          'no_search_history': 'No search history',

          'home': 'Home',
          'downloads': 'Downloads',
          'settings': 'Settings',

          'version': 'Current Version: ${Settings.currentVersion}',
          // qbittorrent states
          "error": "Error",
          "missingFiles": "Missing File",
          "uploading": "Finished",
          "pausedUP": "Finished",
          "queuedUP": "Finished",
          "stalledUP": "Finished",
          "checkingUP": "Verifying",
          "forcedUP": "Finished",
          "allocating": "Allocating",
          "downloading": "Downloading",
          "metaDL": "Downloading",
          "pausedDL": "Paused",
          "queuedDL": "Queued",
          "stalledDL": "Downloading (no connection)",
          "checkingDL": "Verifying",
          "forcedDL": "Downloading",
          "checkingResumeData": "Verifying",
          "moving": "Moving",
          "unknown": "Unknown",

          // settings
          'locale': 'Language',
          'dark_mode': 'Dark Mode',
          'text_scale': 'Text size',
          'layout_orientation': 'UI Orientation',
          'filter_no_chs': 'Filter Simplified Chinese Content',
          'filter_no_chinese': 'Filter All Chinese Content',
          'qbittorrent_api_url': 'qBittorrent Endpoint',
          'provider': 'Provider',
          'reset_all_settings': 'Reset all settings',
          'reset_all_settings_confirm':
              'Are you sure you want to reset all settings?',
          'warning': 'Warning',

          'font_small': 'Small',
          'font_normal': 'Normal',
          'font_large': 'Large',

          'auto': 'Auto',
          'portrait': 'Portrait',
          'landscape': 'Landscape',

          'confirm': 'Confirm',
          'confirmation': 'Confirmation',
          'confirm_dl': 'Are you sure you want to download this file?',
          'filename': 'File name',
          'filename_empty_error': 'Title cannot be empty',
          'download': 'Download',
          'download_added': 'Added to downloads',
          'download_error': 'Error downloading file',
          'cancel': 'Cancel',

          'cannot_be_empty': 'Cannot be empty',
          'invalid_format': 'Invalid format',

          'all_categories': 'All Categories',
          'anime': 'Anime',
          'software': 'Software',
          'anime_songs': 'Anime Songs',
          'games': 'Games',
          'comics': 'Comics',
          'jp_tv_shows': 'JP TV Shows',
          'music': 'Music',
          'other_categories': 'Other',
          'lossless_music': 'Lossless Music',
          'literature': 'Literature',
          'photos': 'Photos',
        },
        'zh': {
          'colon': '：',
          'qbt_error_msg': "無法與qBittorrent連接\n請檢查網路及qBittorrent是否已開啟",
          'no_magnet_url': '沒有為此項目找到磁力連結',
          'connection_error': '連線錯誤',

          'page_nth_yet': '這裡什麼都沒有...',
          'resume_dl': '繼續下載',
          'pause_dl': '暫停下載',

          'open_file': '開啟檔案',
          'open_file_location': '開啟檔案位置',
          'delete': '刪除',
          'searchbar_hint': '搜尋關鍵字...',
          'searchbar_empty': '請輸入搜尋關鍵字',
          'no_search_history': '沒有搜尋記錄',

          'home': '首頁',
          'downloads': '下載',
          'settings': '設定',

          'version': '當前版本：${Settings.currentVersion}',

          // qBittorrent 狀態
          "error": "錯誤",
          "missingFiles": "檔案遺失",
          "uploading": "完成",
          "pausedUP": "完成",
          "queuedUP": "完成",
          "stalledUP": "完成",
          "checkingUP": "驗證中",
          "forcedUP": "完成",
          "allocating": "分配中",
          "downloading": "下載中",
          "metaDL": "下載中",
          "pausedDL": "暫停",
          "queuedDL": "排隊中",
          "stalledDL": "下載中 (無連線)",
          "checkingDL": "驗證中",
          "forcedDL": "下載中",
          "checkingResumeData": "驗證中",
          "moving": "移動中",
          "unknown": "未知",

          // Settings
          'locale': '語言',
          'dark_mode': '黑夜模式',
          'text_scale': '文字大小',
          'layout_orientation': '界面佈局',
          'filter_no_chs': '過濾簡體中文內容',
          'filter_no_chinese': '過濾所有中文內容',
          'qbittorrent_api_url': 'qBittorrent 接入點',
          'provider': '提供者',
          'reset_all_settings': '重置所有設定',
          'reset_all_settings_confirm': '確定要重置所有設定嗎？',
          'warning': '警告',

          'font_small': '小',
          'font_normal': '中',
          'font_large': '大',

          'auto': '自動',
          'portrait': '縱向',
          'landscape': '橫向',

          'confirm': '確認',
          'confirmation': '確認',
          'confirm_dl': '確定要下載此檔案嗎？',
          'filename': '檔案名稱',
          'filename_empty_error': '檔案名稱不能為空',
          'download': '下載',
          'download_added': '已加入至下載列表',
          'download_error': '下載錯誤',
          'cancel': '取消',

          'cannot_be_empty': '不能為空',
          'invalid_format': '格式錯誤',

          'all_categories': '所有類別',
          'anime': '動漫',
          'software': '軟體',
          'anime_songs': '動漫歌曲',
          'games': '遊戲',
          'comics': '漫畫',
          'jp_tv_shows': '日劇',
          'music': '音樂',
          'other_categories': '其他',
          'lossless_music': '無損音樂',
          'literature': '小說',
          'photos': '圖片',
        }
      };
}

String get trColon => 'colon'.tr;
String get trQbtErrorMsg => 'qbt_error_msg'.tr;
String get trNoMagnetUrl => 'no_magnet_url'.tr;
String get trConnectionError => 'connection_error'.tr;

String get trPageNothingYet => 'page_nth_yet'.tr;
String get trResumeDl => 'resume_dl'.tr;
String get trPauseDl => 'pause_dl'.tr;

String get trOpenFile => 'open_file'.tr;
String get trOpenFileLocation => 'open_file_location'.tr;
String get trDelete => 'delete'.tr;
String get trSearchbarHint => 'searchbar_hint'.tr;
String get trSearchbarEmpty => 'searchbar_empty'.tr;
String get trNoSearchHistory => 'no_search_history'.tr;

String get trHome => 'home'.tr;
String get trDownloads => 'downloads'.tr;
String get trSettings => 'settings'.tr;

String get trSettingLocale => 'locale'.tr;
String get trSettingDarkMode => 'dark_mode'.tr;
String get trSettingTextScale => 'text_scale'.tr;
String get trSettingLayoutOrientation => 'layout_orientation'.tr;
String get trSettingFilterNoChs => 'filter_no_chs'.tr;
String get trSettingFilterNoChinese => 'filter_no_chinese'.tr;
String get trSettingQbittorrentApiUrl => 'qbittorrent_api_url'.tr;
String get trSettingProvider => 'provider'.tr;
String get trSettingResetAllSettings => 'reset_all_settings'.tr;
String get trSettingResetAllSettingsConfirm => 'reset_all_settings_confirm'.tr;
String get trWarning => 'warning'.tr;

String get trSettingFontSmall => 'font_small'.tr;
String get trSettingFontNormal => 'font_normal'.tr;
String get trSettingFontLarge => 'font_large'.tr;

String get trSettingAuto => 'auto'.tr;
String get trSettingPortrait => 'portrait'.tr;
String get trSettingLandscape => 'landscape'.tr;

String get trConfirm => 'confirm'.tr;
String get trConfirmation => 'confirmation'.tr;
String get trConfirmDl => 'confirm_dl'.tr;
String get trFilename => 'filename'.tr;
String get trFilenameEmptyError => 'filename_empty_error'.tr;
String get trDownload => 'download'.tr;
String get trDownloadAdded => 'download_added'.tr;
String get trDownloadError => 'download_error'.tr;
String get trCancel => 'cancel'.tr;

String get trCannotBeEmpty => 'cannot_be_empty'.tr;
String get trInvalidFormat => 'invalid_format'.tr;

String get trAllCategories => 'all_categories'.tr;
String get trAnime => 'anime'.tr;
String get trSoftware => 'software'.tr;
String get trAnimeSongs => 'anime_songs'.tr;
String get trGames => 'games'.tr;
String get trComics => 'comics'.tr;
String get trJpTvShows => 'jp_tv_shows'.tr;
String get trMusic => 'music'.tr;
String get trOtherCategories => 'other_categories'.tr;
String get trLosslessMusic => 'lossless_music'.tr;
String get trLiterature => 'literature'.tr;
String get trPhotos => 'photos'.tr;

String get trVersion => 'version'.tr;
