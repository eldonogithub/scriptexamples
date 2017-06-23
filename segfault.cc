#include <string>

class Alpha {

  public:
    std::string getText() { return m_text; }

  private:
    std::string m_text;
};

int main() {
  bool value;

  Alpha *ptr = 0;
  value = ptr->getText().empty();
}
