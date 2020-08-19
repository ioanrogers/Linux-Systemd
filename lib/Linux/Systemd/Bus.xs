#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <systemd/sd-bus.h>

sd_bus *bus;

SV * message_to_sv(sd_bus_message *m, char type) {
    union {
        uint8_t u8;
        uint16_t u16;
        int16_t s16;
        uint32_t u32;
        int32_t s32;
        uint64_t u64;
        int64_t s64;
        double d64;
        const char *string;
        int i;
    } basic;

    if (sd_bus_message_read_basic(m, type, &basic) < 0)
        croak("Failed to get basic");

    switch (type) {
        case SD_BUS_TYPE_BYTE:
            printf("BYTE %u;\n", basic.u8);
        break;

        case SD_BUS_TYPE_BOOLEAN:
        case SD_BUS_TYPE_UNIX_FD:
            printf("BOOLEAN|UNIX_FD %i\n", basic.i);
            return newSViv(basic.i);
        break;

        case SD_BUS_TYPE_INT16:
            printf("INT16 %i\n", basic.s16);
        break;

        case SD_BUS_TYPE_UINT16:
            printf("UINT16 %u\n", basic.u16);
        break;

        case SD_BUS_TYPE_INT32:
            printf("INT32 %i\n", basic.s32);
        break;

        case SD_BUS_TYPE_UINT32:
            printf("UINT32 %u\n", basic.u32);
            return newSViv(basic.u32);
        break;

        case SD_BUS_TYPE_INT64:
            printf("INT64 %s%"PRIi64"%s;\n", basic.s64);
        break;

        case SD_BUS_TYPE_UINT64:
            printf("UINT64 %s%"PRIu64"%s;\n", basic.u64);
        break;

        case SD_BUS_TYPE_DOUBLE:
            printf("DOUBLE %g;\n", basic.d64);
        break;

        case SD_BUS_TYPE_STRING:
        case SD_BUS_TYPE_OBJECT_PATH:
        case SD_BUS_TYPE_SIGNATURE:
            printf("STRING|OBJECT|SIGNATURE %s\n", basic.string);
            return newSVpv(basic.string, strlen(basic.string));
            break;

        default:
            croak("Unknown basic type");
    }

}

SV *parse_struct(sd_bus_message *m) {
    int r;
    char type;
    AV *struct_av = newAV();

    printf("Parsing struct\n");
    r = sd_bus_message_enter_container(m, type, NULL);
    printf("ENTER STRUCT: %d - %s\n", r, strerror(-r));

    if (r == 0) {
      printf("No more structs\n");
      return NULL;
    } else if ( r < 0) {
        croak("Failed to enter struct container");
    }

    for (;;) {
        const char *contents = NULL;
        char type;

        r = sd_bus_message_peek_type(m, &type, &contents);

        if (r < 0) {
            croak("Failed to peek type");
        } else if (r == 0) {
            printf("Finished struct\n");
            if (sd_bus_message_exit_container(m) < 0)
                croak("Failed to exit container");

            break;
        }

        printf("[STRUCT] %c\n", type);

        av_push(struct_av, message_to_sv(m, type));
    }

    return newRV_noinc((SV*) struct_av);
}

AV *parse_array(sd_bus_message *message) {
  AV *array_av = newAV();
  char type;
  const char *contents;
  int r;

  r = sd_bus_message_peek_type(message, &type, &contents);
  if (r < 0)
      croak("Failed to peek type");

  if (type != SD_BUS_TYPE_ARRAY)
      croak("Expected an array, got a: %c\n", type);

  printf("Got %c[%s]\n", type, contents);

  r = sd_bus_message_enter_container(message, SD_BUS_TYPE_ARRAY, contents);
  if (r < 0)
      croak("enter container fail: %s\n", strerror(-r));

  if (strncmp(contents, "s", 1) == 0) {
      printf("Gettings strings\n");
      const char *str;

      while ((r = sd_bus_message_read_basic(message, SD_BUS_TYPE_STRING, &str)) > 0) {
          printf("s: %s\n", str);
          av_push(array_av, newSVpv(str, strlen(str)));
      }

  } else if (strncmp(contents, "(", 1) == 0) {
      const char *struct_contents = NULL;
      char struct_type;
      AV *struct_av = newAV();

      printf("Getting structs\n");

      while (struct_av = parse_struct(message)) {
          av_push(array_av, struct_av);
      }

  }

  r = sd_bus_message_exit_container(message);
  if (r < 0)
    croak("exit container fail: %s\n", strerror(-r));

  return array_av;
}

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
list_names(NULL)
    PREINIT:
        char **acquired;
        char **i;
    CODE:
        // TODO we should also flag which names are activatable
        int r = sd_bus_list_names(bus, &acquired, NULL);

        if (r < 0)
            croak("Failed to list names: %s\n", strerror(-r));

        RETVAL = newAV();
        for ((i) = (acquired); (i) && *(i); (i)++) {
            SV *str = newSVpv(*i, strlen(*i));
            av_push(RETVAL, str);
            free(*i);
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

SV *
_call_method_returning_string(char *service, char *path, char *interface, char *method)
    PREINIT:
        sd_bus_message *reply = NULL;
        sd_bus_error error = SD_BUS_ERROR_NULL;
        const char *s;

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

        r = sd_bus_message_read(reply, "s", &s);
        if (r < 0)
            croak("Failed to parse message: %s\n", strerror(-r));

        RETVAL = newSVpv(s, strlen(s));

    OUTPUT: RETVAL

AV *
_call_method_returning_array(char *service, char *path, char *interface, char *method)
    PREINIT:
        sd_bus_message *reply = NULL;
        sd_bus_error error = SD_BUS_ERROR_NULL;
        const char *contents;
        char type;

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

        RETVAL = parse_array(reply);

        // r = sd_bus_message_enter_container(reply, 'a', "(susso)");
        // if (r < 0)
        //     croak("Bus message parsing error");
        // RETVAL = newAV();
        // printf("%s\n", signature);
        // for (i = (char *)signature; i && *i; i++) {
        // //     SV *str = newSVpv(*i, strlen(*i));
        // //     av_push(RETVAL, str);
        //     printf("%s -- %c\n", i, *i);
        //
        // }
        // while ((r = sd_bus_message_read(reply, signature, &id, &uid, &user, &seat, &object)) > 0) {
        //     printf("%10s %10"PRIu32" %-16s %-16s\n", id, uid, user, seat);
        // }


    OUTPUT: RETVAL

NO_OUTPUT void
_call_method_returning_void(char *service, char *path, char *interface, char *method)
    PREINIT:
        sd_bus_message *reply = NULL;
        sd_bus_error error = SD_BUS_ERROR_NULL;
        const char *s;

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
