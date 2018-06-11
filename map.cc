#include <boost/shared_ptr.hpp>
#include <iostream>
#include <map>
#include <string>
#include <memory>

class A {
public:
  A() {
    std::cout << *this << ": Created" << std::endl;
  } 
  virtual ~A() {}
};

int main() {
  
  std::map<int, std::shared_ptr<A> > map;

  map.insert(std::make_pair(1, std::shared_ptr<A>(new A()));

  return 0;
}
