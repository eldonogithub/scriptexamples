#include <iostream>

struct X {
  X() { std::cout << "X"; }
  friend std::ostream &operator<<(std::ostream &os, const X &obj);
};

std::ostream & 
operator<<(std::ostream &os, const X&/*obj*/) {
    return os << "X()";
}

struct Y {
  Y(const X &x) { std::cout << "Y(" << x << ")"; }
  Y() { std::cout << "Y"; }
public:
  void f() { std::cout << "f"; }
};

int main() {
  Y y;

  y.f();
}
