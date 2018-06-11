#include <iostream>

void foo(...) {
  std::cout << "foo" << std::endl;
}

int main(int, char *[]) {
  foo();
  foo(1);
  foo("fdsa");
  foo("fdsa", 333, 'c');
}
