#include <string>
#include <iostream>

int main() {
  int a = 5;
  int b = 6;

  std::string str = "" + a + b;

  std::cout << "ex1:" << str << std::endl;

  std::cout << "ex2:" << "" << a << b << std::endl;
}
