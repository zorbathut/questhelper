
#include "compile_error.h"

#include "boost/filesystem.hpp"
#include <sys/stat.h>

#include <cstdio>
#include <cmath>
#include <cstring>

#include <vector>
#include <utility>
#include <map>
#include <fstream>

using namespace std;

void parseLuaType(const char *&ptx, LuaType *rv, int *tokens) {  // urgh *&
  if(*ptx == 'I') {
    ptx++;
    rv->type = LT_NIL;
    assert(*ptx == 'i');
    ptx++;
  } else if(*ptx == 'N') {
    ptx++;
    const char *stt = ptx;
    while(*stt != 'n') {
      assert(*stt == '-' || *stt == '.' || isdigit(*stt));
      stt++;
    }
    rv->type = LT_NUMBER;
    rv->number = strtod(string(ptx, stt).c_str(), NULL);
    ptx = stt;
    ptx++;
  } else if(*ptx == 'B') {
    ptx++;
    assert(*ptx == 'F' || *ptx == 'T');
    rv->type = LT_BOOL;
    rv->boolean = (*ptx == 'T');
    ptx++;
    assert(*ptx == 'b');
    ptx++;
  } else if(*ptx == 'S') {
    ptx++;
    LuaType vx;
    parseLuaType(ptx, &vx, tokens);
    assert(vx.type == LT_NUMBER);
    assert(vx.number == floor(vx.number));
    int sct = (int)vx.number;
    rv->type = LT_STRING;
    rv->strv = string(ptx, ptx + sct);
    ptx += sct;
    assert(*ptx == 's');
    ptx++;
  } else if(*ptx == 'T') {
    ptx++;
    LuaType vx;
    parseLuaType(ptx, &vx, tokens);
    assert(vx.type == LT_NUMBER);
    assert(vx.number == floor(vx.number));
    int sct = (int)vx.number;
    rv->type = LT_TABLE;
    rv->table.resize(sct);
    for(int i = 0; i < sct; i++) {
      parseLuaType(ptx, &rv->table[i].first, tokens);
      parseLuaType(ptx, &rv->table[i].second, tokens);
    }
    assert(*ptx == 't');
    ptx++;
  } else {
    assert(0);
  }
  
  (*tokens)++;
}

void loadLuaType(const string &filename, LuaType *rv) {
  printf("Loading %s . . . ", filename.c_str());
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
  fclose(blerg);
  
  const char *pt = dat.c_str();
  const char *pte = pt + dat.size();
  
  printf("%8d bytes . . . ", (int)dat.size());
  
  int toks = 0;
  parseLuaType(pt, rv, &toks);
  printf("%7d tokens\n", (int)toks);
  assert(pt == pte);
}

void Compile(const LuaType &lt);
void Complete();

int main() {
  int q = system("rm -rf intermed");  // we're only storing it to make the damn warning go away
  
  int maxfiles = 1000000;
  //maxfiles = 10;
  
  mkdir("intermed", 0755);
  {
    vector<string> fnames;
    boost::filesystem::directory_iterator end_itr;
    for(boost::filesystem::directory_iterator itr("data/09"); itr != end_itr; ++itr) {
      fnames.push_back(itr->path().native_file_string());
    }
    sort(fnames.begin(), fnames.end());
    if(fnames.size() > maxfiles) fnames.resize(maxfiles);
    
    for(int i = 0; i < fnames.size(); i++) {
      LuaType lt;
      loadLuaType(fnames[i], &lt);
      Compile(lt);
    }
  }
  
  Complete();
}

void Compile(const LuaType &lt) {
  CompileError(lt);
}
void Complete() {
  CompleteError();
}
