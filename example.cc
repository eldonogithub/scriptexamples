#include <iostream>

class Base
{
protected:
  int i;
};

class Derived : public Base
{
protected:
  inline int &getter(void) {
    std::cout << &Base::i << std::endl; // &(Base::i) works
    return Base::i;
  }
};

int main(void)
{
  Derived d;
  std::cout << "address=" <<  &d.getter() << std::endl;
  return 0;
}
