
#include "compile_error.h"

#include <map>
#include <algorithm>

#include <sys/stat.h>
#include <fstream>

using namespace std;

static map<string, map<string, vector<string> > > dat;

void CompileError(const LuaType &lt) {
  assert(lt.type == LT_TABLE);
  for(int j = 0; j < lt.table.size(); j++) {
    if(lt.table[j].first == "QuestHelper_Errors") {
      const LuaType &group = lt.table[j].second;
      for(int m = 0; m < group.table.size(); m++) {
        const LuaType &g2 = group.table[m].second;
        for(int k = 0; k < g2.table.size(); k++) {
          const LuaType &ltd = g2.table[k].second;
          string chunk = ltd["stack"].str() + "\n" + group.table[m].first.str();
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

void CompleteError() {
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
