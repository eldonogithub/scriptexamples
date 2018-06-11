#include <iostream>
#include <stdio.h>
#include <stdint.h>

class Base
{
public:
  Base(void) : i(23) {}
  void printAddress(void) {
    std::cout << (uint64_t) &i << std::endl;
    printf("address=%lld\n", &i);
  }
protected:
  int i;
};

class Derived : public Base
{
public:
  int &getter(void) {
    printf("address=%lld\n", &(Base::i));
    printf("address=%lld\n", &this->i);
    return Base::i;
  }
};

int main(void)
{
  Derived d;
  d.printAddress();
  printf("address=%lld\n", &d.getter());
  return 0;
}
