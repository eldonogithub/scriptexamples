#include <typeinfo>
#include <iostream>

namespace X {
  template<typename A>
  void foo() {
    std::cout << "foo(): " << typeid(A).name() << std::endl;
  } 

  template <class Ch>
  bool check_is_ascii(const Ch c)
  {
    return (c == 0x20 || c == 0x21 || (c >= 0x23 && c <= 0x2E) ||
	   (c >= 0x30 && c <= 0x5B) || (c >= 0x5D && c <= 0xFF));
  }

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
