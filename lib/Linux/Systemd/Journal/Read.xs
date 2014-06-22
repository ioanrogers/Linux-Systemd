#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <systemd/sd-journal.h>

sd_journal *j;

void split_data_to_svs(const char *msg, SV **k_sv, SV **v_sv) {
    char *data_copy = strdup(msg);
    char *k = strtok(data_copy, "=");
    char *v = strtok(NULL, "=");

    (*k_sv) = newSVpv(k, strlen(k));
    (*v_sv) = newSVpv(v, strlen(v));

}

MODULE = Linux::Systemd::Journal::Read PACKAGE = Linux::Systemd::Journal::Read

PROTOTYPES: DISABLE

NO_OUTPUT void
__open()
    CODE:
        int r = sd_journal_open( &j, SD_JOURNAL_LOCAL_ONLY);
        if (r < 0)
            croak("Failed to open journal: %s\n", strerror(r));

void
__close(sd_journal *j)
    CODE:
        sd_journal_close(j);

uint64_t
get_usage(self)
    CODE:
        int r = sd_journal_get_usage(j, &RETVAL);
        if (r < 0)
            croak("Failed to get journal usage: %s\n", strerror(-r));
    OUTPUT:
        RETVAL

int
next(self)
    CODE:
        RETVAL = 1;
        int r = sd_journal_next(j);
        if (r < 0)
            croak("Failed to move to next record: %s\n", strerror(-r));

        if (r == 0)
            RETVAL = 0;

    OUTPUT:
        RETVAL

NO_OUTPUT void
seek_head(self)
    CODE:
        int r = sd_journal_seek_head(j);
        if (r < 0)
            croak("Failed to seek to journal head: %s\n", strerror(-r));

NO_OUTPUT void
seek_tail(self)
    CODE:
        int r = sd_journal_seek_tail(j);
        if (r < 0)
            croak("Failed to seek to journal tail: %s\n", strerror(-r));

SV *
get_data(self, const char *field)
    PREINIT:
        char   *data;
        int    r;
        size_t l;
        SV     *key_sv;

    CODE:
        r = sd_journal_get_data(j, field, (const void**) &data, &l);
        if (r < 0)
            croak("Failed to read message field '%s': %s\n", field, strerror(-r));

        split_data_to_svs(data, &key_sv, &RETVAL);
    OUTPUT:
        RETVAL

HV *
get_entry(self)
    CODE:
        const void *data;
        size_t l;
        RETVAL = newHV();
        SD_JOURNAL_FOREACH_DATA(j, data, l) {
            SV   *key_sv, *val_sv;
            split_data_to_svs(data, &key_sv, &val_sv);
            hv_store_ent(RETVAL, key_sv, val_sv, 0);
        }
    OUTPUT:
        RETVAL
