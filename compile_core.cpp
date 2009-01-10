#include <iostream>
#include <luabind/luabind.hpp>

using namespace std;

void slice_loc(lua_State *L, const std::string &dat) {
  cout << dat << endl;
}
void greet() {
  std::cout << "hello world!\n";
}

extern "C" int init(lua_State* L) {
  using namespace luabind;

  open(L);

  module(L)
  [
    def("slice_loc", &slice_loc, raw(_1)),
    def("greet", &greet)
  ];

  return 0;
}

