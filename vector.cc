#include <list>
#include <vector>
#include <string>
#include <iostream>

void vector() {
  std::vector< std::string > list;

  list.push_back("asdf");


  for( std::vector< std::string >::iterator it = list.begin(); it != list.end(); ) {
    std::vector< std::string >::iterator toErase = it;

    if ( *toErase == "asdf" ) {
      it = list.erase(toErase);
    }
    else {
      ++it;
    }
  }
}

void list() {
  std::list< std::string > list;

  list.push_back("asdf");

  for( std::list< std::string >::iterator it = list.begin(); it != list.end(); ) {
    std::list< std::string >::iterator toErase = it;
      ++it;

    if ( *toErase == "asdf" ) {
      list.erase(toErase);
    }
    else {
    }
  }
}

int main() {
  vector();
  list();
}
