#include <iostream>
#include <string>
#include <fstream>

int main(int argc, char *argv[]) {

  std::string x("eldon");
  ((char *)x.data())[0] = 'X';
  ((char *)x.c_str())[1] = 'Y';
  std::cout << x << std::endl;

  std::istream *ifs = &std::cin;
  std::ifstream fileStream;

  if ( argc > 1 ) {
    // open input file

    fileStream.open(argv[1], std::ifstream::in);
    if ( !fileStream.is_open() ) {
      std::cerr << "Error: Unable to open file: " << argv[1] << std::endl;
      return 1;
    }
    ifs = &fileStream;
  }

  std::cout << "Interpreter started" << std::endl;

  // Max buffer size
  const int cMaxLine = 1;

  // input buffer
  char line[cMaxLine];

  // parsing buffer
  std::string buffer;

  while (!ifs->eof()) {
    ifs->read(line, cMaxLine);

    buffer.append(line, ifs->gcount());

    // process commands
    size_t end = 0;
    while ((end = buffer.find("\n")) != std::string::npos) {

      // copy command
      std::string command(buffer, 0, end);

      // remove command from input
      buffer.erase(0, end+1);

      std::cout << "Command: " << command << std::endl;
    }
  }
  return 0;
}
