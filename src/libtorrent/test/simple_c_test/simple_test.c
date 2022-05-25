#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

#include <libtorrent.h>
#include <stdio.h>
#include <string.h>

void alert_listener(struct Alert* p_alert) {
    const char* alert_type = lt_alert_type(p_alert);
    if (strcmp(alert_type, "other_notification") != 0) {
        printf("%s: %s (%s)\n", alert_type, p_alert->message, p_alert->what);
    }
    lt_free_alert(p_alert);
}

int main() {
    lt_init_session();
    lt_add_torrent("magnet:?xt=urn:btih:HJIR6R5QT4SFVOOEHHSQF2LV6VBM4NBY", "/Users/yusing/Documents/GitHub/AnimeFinderFlutter/src/libtorrent/test_dl/");
    while(true) {
        struct TorrentList* p_torrents = lt_get_torrents();
        for (int i = 0; i < p_torrents->n_torrents; i++) {
            struct Torrent* p_torrent = &p_torrents->arr_torrents[i];
            printf("%s: %s (%.2f%% %.f secs left)\n", p_torrent->name, lt_torrent_state(p_torrent->state), p_torrent->progress * 100, p_torrent->eta);
        }
        lt_free_torrents(p_torrents);
        sleep(1);
    }

    // wait for the user to end
    char a;
    int ret = scanf("%c\n", &a);
    (void)ret; // ignore
    return 0;

}