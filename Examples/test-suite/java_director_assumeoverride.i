%module(directors="1") java_director_assumeoverride

%{
class OverrideMe {
public:
  virtual ~OverrideMe() {}
  virtual void funk() {};
};

#include "java_director_assumeoverride_wrap.h"
bool isFuncOverridden(OverrideMe* f) {
  alaqilDirector_OverrideMe* director = dynamic_cast<alaqilDirector_OverrideMe*>(f);
  if (!director) {
    return false;
  }
  return director->alaqil_overrides(0);
}

%}

%feature("director", assumeoverride=1) OverrideMe;

class OverrideMe {
public:
  virtual ~OverrideMe();
  virtual void funk();
};

bool isFuncOverridden(OverrideMe* f);
