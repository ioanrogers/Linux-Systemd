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

char *
_introspect(char *service, char *path)
    PREINIT:
        sd_bus_message *reply = NULL;
        sd_bus_error error = SD_BUS_ERROR_NULL;
        // const char *xml;
    CODE:
        int r = sd_bus_call_method(
            bus,
            service,
            path,
            "org.freedesktop.DBus.Introspectable",
            "Introspect",
            &error,
            &reply,
            ""
        );

        if (r < 0)
            croak("Failed to introspect object: %s\n", strerror(-r));

        r = sd_bus_message_read(reply, "s", &RETVAL);
        if (r < 0)
            croak("Failed to parse message: %s\n", strerror(-r));

        // printf("XML: %s\n", RETVAL);
    OUTPUT: RETVAL

NO_OUTPUT void
_call_method(char *service, char *path, char *interface, char *method)
    PREINIT:
        sd_bus_message *reply = NULL;
        sd_bus_error error = SD_BUS_ERROR_NULL;

    CODE:
        int r = sd_bus_call_method(
            bus,
            service,
            path,
            interface,
            method,
            &error,
            &reply,
            ""
        );

        if (r < 0)
            croak("Failed to call method: %s\n", strerror(-r));

        // r = sd_bus_message_read(reply, "s", &xml);
        // if (r < 0)
        //     croak("Failed to parse message: %s\n", strerror(-r));
        //
        // printf("XML: %s\n", xml);

SV *
_get_property_string(char *service, char *path, char *interface, char *property)
    PREINIT:
        sd_bus_message *reply = NULL;
        sd_bus_error error = SD_BUS_ERROR_NULL;
        const char *s;
    CODE:
        int r = sd_bus_get_property(
            bus,
            service,
            path,
            interface,
            property,
            &error,
            &reply,
            "s"
        );

        if (r < 0)
            croak("Failed to get property: %s\n", strerror(-r));

        r = sd_bus_message_read(reply, "s", &s);
        if (r < 0)
            croak("Failed to parse message: %s\n", strerror(-r));

        RETVAL = newSVpv(s, strlen(s));

    OUTPUT: RETVAL
