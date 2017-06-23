#include <string>
#include <vector>

#include "one.hh"

void blah2() {
  X::foo<unsigned char>();
  X::check_is_ascii<unsigned char>('a');
}
