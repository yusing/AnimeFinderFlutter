#include <iostream>
#include <thread>
#include <chrono>
#include <fstream>
#include <sstream>
#include <stdexcept>
#include <limits>

#include <libtorrent/session.hpp>
#include <libtorrent/session_params.hpp>
#include <libtorrent/add_torrent_params.hpp>
#include <libtorrent/torrent_handle.hpp>
#include <libtorrent/alert_types.hpp>
#include <libtorrent/bencode.hpp>
#include <libtorrent/torrent_status.hpp>
#include <libtorrent/read_resume_data.hpp>
#include <libtorrent/write_resume_data.hpp>
#include <libtorrent/error_code.hpp>
#include <libtorrent/magnet_uri.hpp>

#include "../include/libtorrent.h"

using clk = std::chrono::steady_clock;

static lt::session* g_ses;

auto lt_get_session() -> lt::session&
{
    return *g_ses;
}

void lt_alert_listener() {
    std::vector<lt::alert*> alerts;
    g_ses->pop_alerts(&alerts);
    for (auto*& alert : alerts) {
        if (lt::alert_cast<lt::save_resume_data_failed_alert>(alert)) {
            continue;
        }
        lt::save_resume_data_alert const* rd = lt::alert_cast<lt::save_resume_data_alert>(alert);
        if (rd) { // alert is save_resume_data_alert
            lt::torrent_handle h = rd->handle;
            lt::torrent_status st = h.status(lt::torrent_handle::query_save_path
                    | lt::torrent_handle::query_name);
            std::ofstream out(st.save_path + "/" + st.name + ".fastresume"
                    , std::ios_base::binary);
            std::vector<char> buf = write_resume_data_buf(rd->params);
            out.write(buf.data(), buf.size());
            out.flush();
            out.close();
        }
    }
}

EXPORT_TO_DART void lt_init_session() {
    lt::settings_pack pack;
    pack.set_int(lt::settings_pack::alert_mask
        , lt::alert_category::error
        | lt::alert_category::storage
        // | lt::alert_category::status
        | lt::alert_category::file_progress
        | lt::alert_category::stats);
    pack.set_int(lt::settings_pack::active_seeds, 0);
    pack.set_int(lt::settings_pack::active_downloads, 5);
    pack.set_bool(lt::settings_pack::enable_dht, true);
    pack.set_bool(lt::settings_pack::enable_upnp, false);
    pack.set_bool(lt::settings_pack::enable_lsd, false);
    pack.set_bool(lt::settings_pack::enable_natpmp, false);
    pack.set_bool(lt::settings_pack::enable_incoming_tcp, false);
    pack.set_bool(lt::settings_pack::enable_incoming_utp, false);
    pack.set_bool(lt::settings_pack::auto_sequential, true);
    g_ses = new lt::session(pack);
    // g_ses->set_alert_notify(lt_alert_listener);
}

void lt_torrent_handle_to_torrent(const lt::torrent_handle& handle, Torrent* p_torrent) {
    auto torrent_status = handle.status();
    auto torrent_file = handle.torrent_file();
    auto torrent_flags = handle.flags();
    auto torrent_name = torrent_status.name;
    auto torrent_hash = handle.info_hash().to_string();
    auto torrent_save_path = torrent_status.save_path;

    p_torrent->name = strdup(torrent_name.c_str()); // copy name to malloc'd c-string
    p_torrent->hash = strdup(torrent_hash.c_str()); // copy string to malloc'd c-string
    p_torrent->state = torrent_status.state;
    p_torrent->save_path = strdup(torrent_save_path.c_str()); // copy string to malloc'd c-string
    p_torrent->progress = torrent_status.progress;
    p_torrent->total_file_size = torrent_status.total;
    p_torrent->download_rate = torrent_status.download_rate;
    if (p_torrent->download_rate > 0) {
        p_torrent->eta = (p_torrent->total_file_size - torrent_status.total_download) / (double)p_torrent->download_rate;
    }
    else {
        p_torrent->eta = std::numeric_limits<double>::infinity();
    }

    p_torrent->is_paused = (torrent_flags & lt::torrent_flags::paused) != 0;
    p_torrent->is_finished = torrent_status.is_seeding;
    
    p_torrent->n_files = 0;
    p_torrent->p_files = nullptr;

    if (torrent_file == nullptr) {
        p_torrent->n_files = 0;
        p_torrent->p_files = nullptr;
    } else {
        const auto& file_storage = torrent_file->files(); // fix this
        auto file_storage_index_range = file_storage.file_range();
        auto file_storage_index_it = file_storage_index_range.begin();
        p_torrent->n_files = torrent_file->num_files();
        p_torrent->p_files = new FileInfo[p_torrent->n_files];

        for (FileInfo* p_file = p_torrent->p_files,
            * const files_end = p_file + p_torrent->n_files; 
            p_file != files_end;
            ++p_file, ++file_storage_index_it) {
            
            auto file_name = file_storage.file_name(*file_storage_index_it);
            p_file->name = strdup(file_name.data()); // copy string to malloc'd c-string
            p_file->file_size = file_storage.file_size(*file_storage_index_it);
        }
    }
}

extern "C" {

EXPORT_TO_DART
Torrent* lt_add_torrent(char* magnet_uri, char* save_path) {
    auto& ses = lt_get_session();

    lt::add_torrent_params atp = lt::parse_magnet_uri(magnet_uri);
    atp.max_uploads = 0; // ensure no uploads
    atp.upload_limit = 0; // ensure no uploads
    atp.save_path = save_path;

    auto handle = ses.add_torrent(std::move(atp));
    auto* torrent = new Torrent;
    lt_torrent_handle_to_torrent(handle, torrent);
    return torrent;
}

EXPORT_TO_DART
const char* lt_torrent_state(int state)
{
    switch(state) {
        case lt::torrent_status::checking_files: return "Checking";
        case lt::torrent_status::downloading_metadata: return "Downloading metadata";
        case lt::torrent_status::downloading: return "Downloading";
        case lt::torrent_status::finished: return "Finished";
        case lt::torrent_status::seeding: return "Seeding";
        case lt::torrent_status::checking_resume_data: return "Checking resume";
        default: return "<>";
    }
}

EXPORT_TO_DART
const char* lt_remove_torrent_delete_files(const char* torrent_hash) {
    auto& ses = lt_get_session();
    lt::torrent_handle handle = ses.find_torrent(lt::sha1_hash(torrent_hash));
    if (!handle.is_valid()) {
        return "torrent not found";
    }
    try {
        ses.remove_torrent(handle, lt::session_handle::delete_files);
    } catch(std::exception&) {
        return "error removing torrent";
    }
    return nullptr;
}

EXPORT_TO_DART
const char* lt_pause_torrent(const char* torrent_hash) {
    auto& ses = lt_get_session();
    lt::torrent_handle handle = ses.find_torrent(lt::sha1_hash(torrent_hash));
    if (!handle.is_valid()) {
        return "torrent not found";
    }
    if (handle.flags() & lt::torrent_flags::paused) {
        return "torrent already paused";
    }
    try {
        handle.pause();
        // if (handle.has_metadata() && handle.need_save_resume_data()) {
        //     handle.save_resume_data();
        // }
    }
    catch(std::exception&) {
        return "error pausing torrent";
    }
    return nullptr;
}

EXPORT_TO_DART
const char* lt_resume_torrent(const char* torrent_hash) {
    auto& ses = lt_get_session();
    lt::torrent_handle handle = ses.find_torrent(lt::sha1_hash(torrent_hash));
    if (!handle.is_valid()) {
        return "torrent not found";
    }
    if (!handle.flags() & lt::torrent_flags::paused) {
        return "torrent already running";
    }
    try {
        handle.resume();
    }
    catch (std::exception&) {
        return "torrent failed to resume";
    }
    return nullptr;
}

EXPORT_TO_DART TorrentList* lt_get_torrents() {
    auto& ses = lt_get_session();
    ses.post_torrent_updates();

    TorrentList* torrents = new TorrentList;

    auto vec_torrent_handles = ses.get_torrents();
    torrents->n_torrents = vec_torrent_handles.size();
    torrents->arr_torrents = new Torrent[torrents->n_torrents];

    auto handle_it = vec_torrent_handles.begin();

    for (Torrent* p_torrent = torrents->arr_torrents, 
        *const torrent_end = p_torrent + torrents->n_torrents; p_torrent != torrent_end;
        ++p_torrent, ++handle_it) {
        lt_torrent_handle_to_torrent(*handle_it, p_torrent);
    }

    return torrents;
}

EXPORT_TO_DART void lt_update_torrent(Torrent* p_torrent) {
    auto& ses = lt_get_session();
    lt::sha1_hash hash(p_torrent->hash);
    lt::torrent_handle handle = ses.find_torrent(hash);
    if (!handle.is_valid()) {
        return;
    }
    lt_free_torrent_content(p_torrent);
    lt_torrent_handle_to_torrent(handle, p_torrent);
}

// EXPORT_TO_DART void lt_add_alert_listener(void (*callback)(Alert* alert)) {
//     auto& ses = lt_get_session();
//     ses.set_alert_notify([&ses, callback] {
//         std::vector<lt::alert*> alerts;
//         ses.pop_alerts(&alerts);
//         for (auto& alert : alerts) {
//             Alert* p_alert = new Alert;
//             auto message_string = alert->message();
//             p_alert->message = strdup(message_string.c_str());
//             p_alert->category = alert->category();
//             p_alert->what = strdup(alert->what());
//             callback(p_alert);
//         }
//         alerts.clear();
//     });
// }

EXPORT_TO_DART const char* lt_alert_type(Alert* p_alert) {
    switch (p_alert->category) {
        case lt::alert::error_notification:
            return "error_notification";
        case lt::alert::peer_notification:
            return "peer_notification";
        case lt::alert::port_mapping_notification:
            return "port_mapping_notification";
        case lt::alert::storage_notification:
            return "storage_notification";
        case lt::alert::tracker_notification:
            return "tracker_notification";
        case lt::alert::connect_notification:
            return "connect_notification";
        case lt::alert::status_notification:
            return "status_notification";
        case lt::alert::ip_block_notification:
            return "ip_block_notification";
        case lt::alert::session_log_notification:
            return "session_log_notification";
        case lt::alert::file_progress_notification:
            return "file_progress_notification";
        default: // other types are unnecessary
            return "other_notification";
    }
}

void lt_free_file(FileInfo* p_file) {
    free(p_file->name);
}

void lt_free_torrent_content(Torrent* p_torrent) {
    free(p_torrent->name);
    free(p_torrent->hash);
    free(p_torrent->save_path);
    
    FileInfo* begin = p_torrent->p_files;
    FileInfo* end = p_torrent->p_files + p_torrent->n_files;

    while (begin != end) {
        lt_free_file(begin);
        begin++;
    }

    delete[] p_torrent->p_files;
}

EXPORT_TO_DART void lt_free_torrent(Torrent* p_torrent) {
    delete p_torrent;
}

void lt_free_torrents(TorrentList* p_torrent_list) {
    Torrent* begin = p_torrent_list->arr_torrents;
    Torrent* end = p_torrent_list->arr_torrents + p_torrent_list->n_torrents;
    while(begin != end) {
        lt_free_torrent_content(begin);
        begin++;
    }

    delete[] p_torrent_list->arr_torrents;
    delete p_torrent_list;
}

void lt_free_alert(Alert* p_alert) {
    free(p_alert->message);
    free(p_alert->what);
    delete p_alert;
}

} // extern "C"