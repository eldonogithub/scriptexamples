#include "one.hh"

namespace X {

template <>
bool check_is_ascii(const char c)
{
  return (c == 0x20 || c == 0x21 || (c >= 0x23 && c <= 0x2E) ||
	 (c >= 0x30 && c <= 0x5B) || c >= 0x5D);
}

template <>
bool check_is_ascii(const unsigned char c)
{
  return (c == 0x20 || c == 0x21 || (c >= 0x23 && c <= 0x2E) ||
	 (c >= 0x30 && c <= 0x5B) || c >= 0x5D);
}

}
