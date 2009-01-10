
#include <iostream>
#include <cstdio>
#include <errno.h>

#include <luabind/luabind.hpp>
#include <boost/noncopyable.hpp>

#include <png.h>

using namespace std;

bool semiass_failure = false;
#define semi_assert(x) (__builtin_expect(!!(x), 1) ? (void)(1) : (printf("SEMIASSERT at %s:%d - %s\n", __FILE__, __LINE__, #x), semiass_failure = true, (void)(1)))

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
    unsigned int *itx = getPtr(x, y);
    const unsigned int *src = image.getPtr(0, 0);
    for(int i = 0; i < image.hei; i++) {
      memcpy(itx, src, sizeof(unsigned int) * image.wid);
      itx += hei;
      src += image.hei;
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
  ImageTileWriter(const string &fname, int xblock, int yblock, int blocksize) : temp(xblock * blocksize, yblock) {
    printf("Opening %s %dx%d\n", fname.c_str(), xblock, yblock);
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
    
    png_set_filter(png_ptr, 0, PNG_ALL_FILTERS);
    png_set_compression_level(png_ptr, Z_BEST_COMPRESSION);
    
    png_set_IHDR(png_ptr, info_ptr, wid * chunk, hei * chunk, 8, PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
    png_set_filler(png_ptr, 0, PNG_FILLER_BEFORE);
    
    png_write_info(png_ptr, info_ptr);
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
    printf("Closing %dx%d\n", wid, hei);
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

