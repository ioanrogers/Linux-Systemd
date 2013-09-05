#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <systemd/sd-journal.h>

int _lsj_print(const char *msg) {
    struct iovec *iov = NULL;

    if (!msg)
        return -EINVAL;

    IOVEC_SET_STRING(iov, msg);

    return sd_journal_sendv(iov, 1);
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
_lsj_print (msg)
	const char *msg


