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
        int r = sd_journal_open(&j, SD_JOURNAL_LOCAL_ONLY);
        if (r < 0)
            croak("Failed to open journal: %s\n", strerror(r));

void
__close()
    CODE:
        sd_journal_close(j);

uint64_t
get_usage(self)
    CODE:
        int r = sd_journal_get_usage(j, &RETVAL);
        if (r < 0)
            croak("Failed to open journal: %s\n", strerror(-r));
    OUTPUT:
        RETVAL

NO_OUTPUT void
__next()
    CODE:
        int r = sd_journal_next(j);
        if (r < 0)
            croak("Failed to move to next record: %s\n", strerror(-r));

NO_OUTPUT void
__seek_head()
    CODE:
        int r = sd_journal_seek_head(j);
        if (r < 0)
            croak("Failed to seek to journal head: %s\n", strerror(-r));

NO_OUTPUT void
__seek_tail(sd_journal *j)
    CODE:
        int r = sd_journal_seek_tail(j);
        if (r < 0)
            croak("Failed to seek to journal tail: %s\n", strerror(-r));

SV *
__get_data(const char *field)
    CODE:
        SV     *key_sv;
        char   *data;
        size_t l;
        int r = sd_journal_get_data(j, field, (const void**) &data, &l);
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

# TODO should take binary data as well
NO_OUTPUT void
__add_match(const char *data)
    CODE:
        int r = sd_journal_add_match(j, data, 0);
        if (r < 0)
            croak("Failed to add a match: %s\n", strerror(-r));

NO_OUTPUT void
__match_and()
    CODE:
        int r = sd_journal_add_conjunction(j);
        if (r < 0)
            croak("Failed to set conjunction: %s\n", strerror(-r));

NO_OUTPUT void
__match_or()
    CODE:
        int r = sd_journal_add_disjunction(j);
        if (r < 0)
            croak("Failed to set disjunction: %s\n", strerror(-r));

NO_OUTPUT void
flush_matches(self)
    CODE:
        sd_journal_flush_matches(j);
