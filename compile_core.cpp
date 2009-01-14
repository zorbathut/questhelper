
#include <iostream>
#include <cstdio>
#include <errno.h>

#include <luabind/luabind.hpp>
#include <boost/noncopyable.hpp>
#include <boost/optional.hpp>

#include <png.h>

using namespace std;
using boost::optional;

bool semiass_failure = false;
#define semi_assert(x) (__builtin_expect(!!(x), 1) ? (void)(1) : (printf("SEMIASSERT at %s:%d - %s\n", __FILE__, __LINE__, #x), semiass_failure = true, (void)(1)))

template<typename T> void pushit(lua_State *L, const string &vid, optional<T> &v) {
  if(v) {
    lua_pushlstring(L, vid.data(), vid.size());
    lua_pushnumber(L, *v);
    lua_settable(L, -3);
  }
}

struct Loc {
  optional<int> c;
  optional<float> x;
  optional<float> y;
  optional<int> rc;
  optional<int> rz;
  
  void push(lua_State *L) {
    lua_newtable(L);
    
    pushit(L, "c", c);
    pushit(L, "x", x);
    pushit(L, "y", y);
    pushit(L, "rc", rc);
    pushit(L, "rz", rz);
  }
};

Loc getLoc(const char *pt) {
  signed char c = pt[0];
  signed int x = *(int*)&(pt[1]);  // go go gadget alignment error
  signed int y = *(int*)&(pt[5]);
  signed char rc = pt[9];
  signed char rz = pt[10];
  
  Loc rv;
  if(c != -128) rv.c = c;
  if(x != -2147483648) rv.x = x / 1000.0;
  if(y != -2147483648) rv.y = y / 1000.0;
  if(rc != -128) rv.rc = rc;
  if(rz != -128) rv.rz = rz;
  
  return rv;
};

void slice_loc(lua_State *L, const std::string &dat) {
  assert(dat.size() == 11);
  
  getLoc(dat.c_str()).push(L);
}
/*
void split_se_key_core(lua_State &l, const std::string &dat) {
  const char *st = dat.c_str();
  const char *ed = st + dat.size();
  while(st != ed) {
    vector<int> monsty;
    while(true) {
      if(*st == 'M') {
        st++;
        const char *stm = st;
        while(true) {
          assert(*st == 'm' || isdigit(*st));
          if(*st == 'm') break;
          st++;
        }
        monsty.push_back(atoi(stm));
        st++;
      }
      
      const char *stl = st;
      st += 11;
      assert(st <= ed);
      
}
*/
class Image : boost::noncopyable {
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
  
  const unsigned int *getPtr(int x, int y) const { return &data[y * wid + x]; }
  unsigned int *getPtr(int x, int y) { return &data[y * wid + x]; }
  
  void copyfrom(const Image &image, int x, int y) {
    assert(x >= 0);
    assert(y >= 0);
    assert(x + image.wid <= wid);
    assert(y + image.hei <= hei);
    
    unsigned int *itx = getPtr(x, y);
    const unsigned int *src = image.getPtr(0, 0);
    for(int i = 0; i < image.hei; i++) {
      memcpy(itx, src, sizeof(unsigned int) * image.wid);
      itx += wid;
      src += image.wid;
    }
  }
  
  void clear() {
    fill(data.begin(), data.end(), 0);
  }
};

class ImageTileWriter : boost::noncopyable {
  Image temp;
  int wid;
  int hei;
  int chunk;
  
  int cury;
  int curx;
  
  FILE *fp;
  png_structp png_ptr;
  png_infop info_ptr;
  
public:
  ImageTileWriter(const string &fname, int xblock, int yblock, int blocksize) : temp(xblock * blocksize, blocksize) {
    printf("Constructing, temp is %dx%d\n", xblock * blocksize, blocksize);
    cury = 0;
    curx = -1;
    
    wid = xblock;
    hei = yblock;
    chunk = blocksize;
    
    fp = fopen(fname.c_str(), "wb");
    assert(fp);
    
    png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    assert(png_ptr);
    
    info_ptr = png_create_info_struct(png_ptr);
    assert(info_ptr);
    
    if(setjmp(png_jmpbuf(png_ptr))) {
      assert(0);
    }
    
    png_init_io(png_ptr, fp);
    
    //png_set_filter(png_ptr, 0, PNG_ALL_FILTERS);
    //png_set_compression_level(png_ptr, Z_BEST_COMPRESSION);
    
    png_set_IHDR(png_ptr, info_ptr, wid * chunk, hei * chunk, 8, PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
    
    png_write_info(png_ptr, info_ptr);
    png_set_filler(png_ptr, 255, PNG_FILLER_AFTER);
  }
  
  void flush_row() {
    assert(cury != hei);
    
    vector<png_bytep> dats;
    for(int i = 0; i < chunk; i++)
      dats.push_back((png_bytep)temp.getPtr(0, i));

    png_write_rows(png_ptr, &dats[0], chunk);
    
    temp.clear();
    
    cury++;
    curx = -1;
  }
  
  void write_tile(int x, int y, const Image &tile) {
    assert(y >= cury);
    assert(y > cury || x > curx);
    
    while(y > cury)
      flush_row();
    
    curx = x;
    temp.copyfrom(tile, x * chunk, 0);
  }
  
  void finish() {
    while(cury < hei)
      flush_row();
    
    png_write_end(png_ptr, info_ptr);
    png_destroy_write_struct(&png_ptr, &info_ptr);
    
    fclose(fp);
    
    fp = NULL;
  }
  
  ~ImageTileWriter() {
    semi_assert(!fp);
  }
};

void check_semiass_failure() {
  assert(!semiass_failure);
};

extern "C" int init(lua_State* L) {
  using namespace luabind;

  open(L);

  module(L)
  [
    def("slice_loc", &slice_loc, raw(_1)),
    //def("split_se_key_core", &split_se_key_core, raw(_1)),
    def("check_semiass_failure", &check_semiass_failure),
    class_<Image>("Image")
      .def(constructor<int, int>())
      .def("set", &Image::set),
    class_<ImageTileWriter>("ImageTileWriter")
      .def(constructor<const string &, int, int, int>())
      .def("write_tile", &ImageTileWriter::write_tile)
      .def("finish", &ImageTileWriter::finish)
  ];

  return 0;
}

