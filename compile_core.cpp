#include <iostream>
#include <cstdio>
#include <luabind/luabind.hpp>

using namespace std;

void poosh_char(lua_State *L, signed char val) {
  if(val == -128) {
    lua_pushnil(L);
  } else {
    lua_pushinteger(L, val);
  }
}

void poosh_defloat(lua_State *L, signed int val) {
  if(val == -2147483648) {
    lua_pushnil(L);
  } else {
    lua_pushnumber(L, (float)val / 1000);
  }
}

void slice_loc(lua_State *L, const std::string &dat) {
  assert(dat.size() == 11);
  signed char contid = dat[0];
  signed int x = *(int*)&(dat[1]);  // go go gadget alignment error
  signed int y = *(int*)&(dat[5]);
  signed char rc = dat[9];
  signed char rz = dat[10];
  
  poosh_char(L, contid);
  poosh_defloat(L, x);
  poosh_defloat(L, y);
  poosh_char(L, rc);
  poosh_char(L, rz);
}

class Image {
  vector<unsigned int> data;
  int wid;
  int hei;
public:
  Image(int width, int height) {
    assert(width >= 0);
    assert(height >= 0);
    wid = width;
    hei = height;
    data.resize(width * height, 0);
  }
  
  void set(int x, int y, unsigned int pix) {
    assert(x >= 0 && x < wid);
    assert(y >= 0 && y < wid);
    data[y * wid + x] = pix;
  }
};

extern "C" int init(lua_State* L) {
  using namespace luabind;

  open(L);

  module(L)
  [
    def("slice_loc", &slice_loc, raw(_1)),
    class_<Image>("Image")
      .def(constructor<int, int>())
      .def("set", &Image::set)
  ];

  return 0;
}

