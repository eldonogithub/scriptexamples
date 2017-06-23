#include <string>
#include <vector>

#include "one.hh"

void blah() {
  X::foo<char>();
  X::check_is_ascii<char>('a');
}
