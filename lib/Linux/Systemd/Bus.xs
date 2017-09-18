#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <systemd/sd-bus.h>

sd_bus *bus;

MODULE = Linux::Systemd::Bus	PACKAGE = Linux::Systemd::Bus

PROTOTYPES: DISABLE

NO_OUTPUT void
_get_system_bus()
    CODE:
        int r = sd_bus_default_system(&bus);
        if (r < 0)
            croak("Failed to get bus: %s\n", strerror(-r));


NO_OUTPUT void
DESTROY(self)
    CODE:
        sd_bus_unref(bus);

AV *
_list()
    PREINIT:
        char **i = NULL;
        char **sv = NULL;
        sd_bus_message *reply = NULL;
    CODE:
        int r = sd_bus_call_method(
                bus,
                "org.freedesktop.DBus",
                "/org/freedesktop/DBus",
                "org.freedesktop.DBus",
                "ListNames",
                NULL,
                &reply,
                NULL);

        if (r < 0)
            croak("Failed to list names: %s\n", strerror(-r));

        r = sd_bus_message_read_strv(reply, &sv);
        if (r < 0)
            croak("Failed to list names: %s\n", strerror(-r));

        sd_bus_message_unref(reply);

        RETVAL = newAV();
        for ((i) = (sv); (i) && *(i); (i)++) {
            SV *str = newSVpv(*i, strlen(*i));
            av_push(RETVAL, str);
        }

    OUTPUT: RETVAL
