
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

enum LTE { LT_TABLE, LT_STRING, LT_NUMBER, LT_NIL, LT_BOOL };
class LuaType {
public:
  LTE type;

  vector<pair<LuaType, LuaType> > table;
  string strv;
  double number;
  bool boolean;

  const LuaType &operator[](const LuaType &lt) const {
    assert(type == LT_TABLE);
    for(int i = 0; i < table.size(); i++)
      if(table[i].first == lt)
        return table[i].second;
    printf("Doesn't have ");
    lt.print();
    printf("\n");
    assert(0);
  }
  bool has(const LuaType &lt) const {
    assert(type == LT_TABLE);
    for(int i = 0; i < table.size(); i++)
      if(table[i].first == lt)
        return true;
    return false;
  }
  
  bool operator==(const LuaType &cmp) const {
    if(type != cmp.type) return false;
    assert(type != LT_TABLE);
    if(type == LT_STRING) return strv == cmp.strv;
    if(type == LT_NUMBER) return number == cmp.number;
    if(type == LT_BOOL) return boolean == cmp.boolean;
    if(type == LT_NIL) return true;
    assert(0);
  }
  bool operator==(const string &cmp_str) const {
    return type == LT_STRING && cmp_str == strv;
  }
  bool operator==(const char *cmp_str) const {
    return type == LT_STRING && cmp_str == strv;
  }
  
  LuaType() { type = LT_NIL; }
  LuaType(const LuaType &rhs) {
    type = rhs.type;
    table = rhs.table;
    strv = rhs.strv;
    number = rhs.number;
    boolean = rhs.boolean;
  }
  ~LuaType() { };
  
  LuaType(const string &in_str) {
    type = LT_STRING;
    strv = in_str;
  }
  LuaType(const char *in_str) {
    type = LT_STRING;
    strv = in_str;
  }
  const string &str() const {
    assert(type == LT_STRING);
    return strv;
  }
  
  void print(int depth = -1) const {
    if(type == LT_NIL) {
      printf("(nil)");
    } else if(type == LT_BOOL) {
      printf(boolean ? "True" : "False");
    } else if(type == LT_NUMBER) {
      printf("%f", number);
    } else if(type == LT_STRING) {
      printf("\"%s\"", strv.c_str());
    } else if(type == LT_TABLE) {
      if(depth == 0) {
        printf("(table)");
      } else {
        printf("{ ");
        for(int i = 0; i < table.size(); i++) {
          if(i) printf(", ");
          table[i].first.print(depth - 1);
          printf(" = ");
          table[i].second.print(depth - 1);
        }
        printf("}");
      }
    } else {
      assert(0);
    }
  }
};

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

int main() {
  vector<LuaType> files;
  
  system("rm -rf intermed");
  
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
    
    files.resize(fnames.size());
    for(int i = 0; i < fnames.size(); i++) {
      loadLuaType(fnames[i], &files[i]);
    }
  }
  
  // Error calculations!
  {
    map<string, map<string, vector<string> > > dat;
    for(int i = 0; i < files.size(); i++) {
      assert(files[i].type == LT_TABLE);
      for(int j = 0; j < files[i].table.size(); j++) {
        if(files[i].table[j].first == "QuestHelper_Errors") {
          const LuaType &group = files[i].table[j].second;
          for(int m = 0; m < group.table.size(); m++) {
            const LuaType &g2 = group.table[m].second;
            for(int k = 0; k < g2.table.size(); k++) {
              const LuaType &ltd = g2.table[k].second;
              string chunk = ltd["stack"].str();
              if(ltd.has("addons"))
                chunk += "\n" + ltd["addons"].str();
              if(ltd.has("message"))
                chunk = ltd["message"].str() + "\n" + chunk;
              dat[ltd["toc_version"].str()][ltd["stack"].str()].push_back(chunk);
            }
          }
        }
      }
    }
    
    for(map<string, map<string, vector<string> > >::const_iterator itr = dat.begin(); itr != dat.end(); itr++) {
      vector<pair<int, pair<string, vector<string> > > > dat;
      for(map<string, vector<string> >::const_iterator titr = itr->second.begin(); titr != itr->second.end(); titr++) {
        dat.push_back(make_pair(titr->second.size(), *titr));
      }
      sort(dat.begin(), dat.end());
      reverse(dat.begin(), dat.end());
      
      mkdir(("intermed/" + itr->first).c_str(), 0755);
      for(int i = 0; i < dat.size(); i++) {
        char bf[100];
        sprintf(bf, "%03d_%05d.txt", i, dat[i].first);
        ofstream ofs(("intermed/" + itr->first + "/" + bf).c_str());
        ofs << dat[i].second.first << endl;
        ofs << endl << endl << endl;
        for(int j = 0; j < dat[i].second.second.size(); j++)
          ofs << dat[i].second.second[j] << endl << endl << endl;
      }
    }
  }
}
