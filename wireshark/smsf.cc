#include "config.h"

#include <epan/packet.h>

#define FOO_PORT 1234

static int proto_foo = -1;


void
proto_register_foo(void)
{
  proto_foo = proto_register_protocol (
                "FOO Protocol", /* name       */
                "FOO",      /* short name */
                "foo"       /* abbrev     */
              );
}
