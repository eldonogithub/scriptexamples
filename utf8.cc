#include <iostream>
#include <string>

std::string show(std::string message) {
  int len = 0;
  for ( std::string::iterator it = message.begin(); it != message.end(); ++it ) {
    if ( ((*it) & 0xc0) != 0x80) {
      len++;
    }
  }

  std::cout << "Message: " << message << " Bytes: " << message.length() << " Characters: " << len << std::endl;
  return message;
}

std::string chop(std::string message) {
  std::string chopped(message, 0, 100);

  std::cout << "Chopped: " << chopped << std::endl;

  return chopped;
}

//    Char. number range  |        UTF-8 octet sequence
//       (hexadecimal)    |              (binary)
//    --------------------+---------------------------------------------
//    0000 0000-0000 007F | 0xxxxxxx
//    0000 0080-0000 07FF | 110xxxxx 10xxxxxx
//    0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
//    0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx

std::string shorten(std::string message) {
  //if ( message.size() <= 100 ) {
  //  return message;
  //}
  //else 
  {
    std::string shortened;
    std::string utf8Character;

    for ( std::string::iterator  it = message.begin(); it != message.end(); ++it) {
      if ( ((*it) & 0xc0) != 0x80) {
	if ( shortened.size() + utf8Character.size() <= 100 ) {
	  shortened.append(utf8Character);
	}
        else {
          break;
        }
	utf8Character.clear();
	utf8Character.push_back((*it));
      }
      else {
	utf8Character.push_back(*it);
      }
    }

    //if ( shortened.size() + utf8Character.size() <= 100 ) {
    //  shortened.append(utf8Character);
    //}

    std::cout << "Shortened: " << shortened << std::endl;
    return shortened;
  }
}

int main() {
  show(shorten(show("example text")));
  show(shorten(show("example text€")));
  show(shorten(show("example text€€")));
  show(shorten(show("example text€€€")));
  show(shorten(show("example text€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€")));
  std::cout << std::endl;
  show(shorten(show("example te€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€")));
  show(shorten(show("example te€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€a")));
  show(shorten(show("example te€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€")));

  // Chinese
  show(shorten(show("example text𠜎𠜱𠝹𠱓𠱸𠲖𠳏𠳕𠴕𠵼𠵿𠸎𠸏𠹷𠺝𠺢𠻗𠻹𠻺𠼭𠼮𠽌𠾴𠾼𠿪𡁜𡁯𡁵𡁶𡁻𡃁𡃉𡇙𢃇𢞵𢫕𢭃𢯊𢱑𢱕𢳂𢴈𢵌𢵧𢺳𣲷𤓓𤶸𤷪𥄫𦉘𦟌𦧲𦧺𧨾𨅝𨈇𨋢𨳊𨳍𨳒𩶘")));
  show(shorten(show("example text𠜎𠜱𠝹𠾼𠿪𡁜𡁯𡁵𡁶𢞵𢫕𢭃𢯊𢵧𢺳𣲷𤓓𤶸𤷪𥄫𦉘𦟌")));
  show(chop(show("example text𠜎𠜱𠝹𠱓𠱸𠲖𠳏𠳕𠴕𠵼𠵿𠸎𠸏𠹷𠺝𠺢𠻗𠻹𠻺𠼭𠼮𠽌𠾴𠾼𠿪𡁜𡁯𡁵𡁶𡁻𡃁𡃉𡇙𢃇𢞵𢫕𢭃𢯊𢱑𢱕𢳂𢴈𢵌𢵧𢺳𣲷𤓓𤶸𤷪𥄫𦉘𦟌𦧲𦧺𧨾𨅝𨈇𨋢𨳊𨳍𨳒𩶘")));

  //  Greek word 'kosme'
  show(shorten(show("example textxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxκόσμε")));
  show(chop(show("example textxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxκόσμε")));

  // Korean
  std::string letter("한");
  show(chop(show("example text 한국어")));
}
