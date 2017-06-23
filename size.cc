#include <string>
#include <vector>

#include <stdlib.h>

int main() {
  std::vector<std::string> list;
  
  for( int i = 0; i < 1000000; i++ ) {
    list.push_back("fdsafhgjtruekw");
  }

  for( int i = 0; i < 1000000; i++ )  {
    if ( list.size() > 0 ) {
    }
  }
}
