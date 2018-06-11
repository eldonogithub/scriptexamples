#include <stdint.h>
#include <iostream>

int main(int , char*[]) {
  for ( int i = 0; i < 10000; i++ ) {
    uint64_t *p = new uint64_t();
    if ( *p != 0 ) {
      std::cout << "Not 0" << std::endl;
    }
  }

}
