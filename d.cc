#include <iostream>

class Base {
  public:
    Base() {foo();}
    virtual ~Base() { foo(); }

    virtual void foo() = 0;

  private:

};

class Derived1 {
  public:
    Derived1(int p1) : m_x(p1) { foo(); } 
    virtual ~Derived1() { foo(); }

    virtual void foo() {
      std::cout << "X: " << m_x << std::endl;
    }

  private: 
    int m_x;
};

class Derived: public Derived1 {
  public:
    Derived(int p1, int p2) : Derived1(p1), m_y(p2) {foo();} 
    virtual ~Derived() { foo(); }

    virtual void foo() {
      std::cout << "Y: " << m_y << std::endl;
    }

  private: 
    int m_y;
};

int main( int argc, char**argv ) {
  Base * b = new Base(42);
  Base * c = new Derived(69, 65);

  std::cout << "Destructing..." << std::endl;
  delete b;
  delete c;

  return 0;
}
