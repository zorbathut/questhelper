#ifndef COMPILE_LUA
#define COMPILE_LUA

#include <string>
#include <utility>
#include <vector>
#include <cassert>

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

#endif
