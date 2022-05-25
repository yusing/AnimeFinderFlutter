#ifndef LIBTORRENT_H
#define LIBTORRENT_H

#define EXPORT_TO_DART __attribute__((visibility("default"))) __attribute__((used))

#include <stdint.h>
#include <stdbool.h>

struct FileInfo {
    char* name; // file name (mallocated)
    int64_t file_size; // file size in bytes
};

struct Torrent {
    char* name; // name of the torrent (mallocated)
    char* hash; // info hash of torrent (mallocated)
    int state;
    char* save_path; // path to the directory where the torrent is saved (mallocated)
    double progress; // [0, 1]
    int64_t total_file_size; // bytes
    int download_rate; // bytes per second
    double eta;

    bool is_paused; // 1 if the torrent is paused, 0 otherwise
    bool is_finished; // 1 if the torrent is finished, 0 otherwise

    struct FileInfo* p_files;
    int n_files;
};

struct TorrentList {
    struct Torrent* arr_torrents;
    int n_torrents;
};

struct Alert {
    char* message; // mallocated
    uint32_t category; // mallocated
    char* what; // mallocated
};

#ifdef __cplusplus /* If this is a C++ compiler, use C linkage */
extern "C" {
#endif // __cplusplus

EXPORT_TO_DART struct TorrentList* lt_get_torrents();
EXPORT_TO_DART void lt_free_file(struct FileInfo* p_file);
EXPORT_TO_DART void lt_free_torrent_content(struct Torrent* p_torrent);
EXPORT_TO_DART void lt_free_torrent(struct Torrent* p_torrent);
EXPORT_TO_DART void lt_free_torrents(struct TorrentList* p_torrent_list);

EXPORT_TO_DART const char* lt_pause_torrent(const char* torrent_hash);
EXPORT_TO_DART const char* lt_resume_torrent(const char* torrent_hash);
EXPORT_TO_DART const char* lt_remove_torrent_delete_files(const char* torrent_hash);
EXPORT_TO_DART struct Torrent* lt_add_torrent(char* magnet_uri, char* save_path);
EXPORT_TO_DART const char* lt_torrent_state(int state);
EXPORT_TO_DART void lt_init_session();

EXPORT_TO_DART void lt_update_torrent(struct Torrent* p_torrent);
EXPORT_TO_DART void lt_free_alert(struct Alert* p_alert);
EXPORT_TO_DART const char* lt_alert_type(struct Alert* p_alert);

#ifdef __cplusplus /* If this is a C++ compiler, end C linkage */
}
#endif // __cplusplus

#endif // LIBTORRENT_H