
#include "boost/filesystem.hpp"

#include <cstdio>
#include <cmath>

#include <vector>
#include <utility>

using namespace std;

enum LTE { LT_TABLE, LT_STRING, LT_NUMBER, LT_NIL, LT_BOOL };
class LuaType {
public:
  LTE type;

  vector<pair<LuaType, LuaType> > table;
  string str;
  double number;
  bool boolean;
};

LuaType parseLuaType(const char *&ptx) {  // urgh *&
  LuaType rv;
  
  if(*ptx == 'I') {
    ptx++;
    rv.type = LT_NIL;
    assert(*ptx == 'i');
    ptx++;
  } else if(*ptx == 'N') {
    ptx++;
    const char *stt = ptx;
    while(*stt != 'n') {
      assert(*stt == '-' || *stt == '.' || isdigit(*stt));
      stt++;
    }
    rv.type = LT_NUMBER;
    rv.number = strtod(string(ptx, stt).c_str(), NULL);
    ptx = stt;
    ptx++;
  } else if(*ptx == 'B') {
    ptx++;
    assert(*ptx == 'F' || *ptx == 'T');
    rv.type = LT_BOOL;
    rv.boolean = (*ptx == 'T');
    ptx++;
    assert(*ptx == 'b');
    ptx++;
  } else if(*ptx == 'S') {
    ptx++;
    LuaType vx = parseLuaType(ptx);
    assert(vx.type == LT_NUMBER);
    assert(vx.number == floor(vx.number));
    int sct = (int)vx.number;
    rv.type = LT_STRING;
    rv.str = string(ptx, ptx + sct);
    ptx += sct;
    assert(*ptx == 's');
    ptx++;
  } else if(*ptx == 'T') {
    ptx++;
    LuaType vx = parseLuaType(ptx);
    assert(vx.type == LT_NUMBER);
    assert(vx.number == floor(vx.number));
    int sct = (int)vx.number;
    rv.type = LT_TABLE;
    for(int i = 0; i < sct; i++) {
      LuaType lhs = parseLuaType(ptx);
      LuaType rhs = parseLuaType(ptx);
      rv.table.push_back(make_pair(lhs, rhs));
    }
    assert(*ptx == 't');
    ptx++;
  } else {
    assert(0);
  }
  return rv;
}

LuaType loadLuaType(const string &filename) {
  FILE *blerg = fopen(filename.c_str(), "rb");
  assert(blerg);
  string dat;
  while(!feof(blerg)) {
    char beef[1024];
    int amt = fread(beef, 1, sizeof(beef), blerg);
    dat += string(beef, beef + amt);
    if(amt != sizeof(beef))
      break;
  }
  printf("%d bytes\n", (int)dat.size());
  const char *pt = dat.c_str();
  const char *pte = pt + dat.size();
  
  LuaType rv = parseLuaType(pt);
  assert(pt == pte);
  return rv;
}

int main() {
  vector<LuaType> files;
  
  boost::filesystem::directory_iterator end_itr;
  for(boost::filesystem::directory_iterator itr("data/09"); itr != end_itr; ++itr) {
    printf("%s\n", itr->path().leaf().c_str());
    printf("%s\n", itr->path().native_file_string().c_str());
    files.push_back(loadLuaType(itr->path().native_file_string()));
  }
}
