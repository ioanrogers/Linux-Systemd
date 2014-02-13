#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <systemd/sd-journal.h>

// TODO Can I call sd_journal_print directly from the .pm?
int _my_sd_journal_print(int pri, const char *msg) {
    return sd_journal_print(pri, msg);
}

int _my_sd_journal_send(AV *data) {
    int array_size = av_top_index(data) + 1;
    struct iovec iov[array_size];
    int ret = 0;

    printf ("Array size: %i\n", array_size);
    printf ("IOVEC array size: %lu\n", sizeof(iov) / 16);

    for (int i = 0; i < array_size; i++) {
        SV *s = av_shift(data);
        char *str = SvPV(s, SvLEN(s));
        printf("%i -- Setting string '%s'\n", i, str);
        iov[i].iov_base = str;
        iov[i].iov_len = strlen(str);
    }

    ret = sd_journal_sendv(iov, array_size);
    printf("Ret is %i\n", ret);
    if (ret != 0) {
        strerror(ret);
    }
    return ret;
}

/*
int sd_journal_print(int priority, const char *format, ...) _sd_printf_attr_(2, 3);
int sd_journal_printv(int priority, const char *format, va_list ap) _sd_printf_attr_(2, 0);
int sd_journal_send(const char *format, ...) _sd_printf_attr_(1, 0) _sd_sentinel_attr_;
int sd_journal_sendv(const struct iovec *iov, int n);
int sd_journal_perror(const char *message);
*/
MODULE = Linux::Systemd::Journal::Write	PACKAGE = Linux::Systemd::Journal::Write

PROTOTYPES: DISABLE

int
_my_sd_journal_print (pri, msg)
    int pri
	const char *msg

int
_my_sd_journal_send (data)
    AV *data
