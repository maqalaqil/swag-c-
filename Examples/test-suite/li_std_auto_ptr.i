%module li_std_auto_ptr

%{
#if __GNUC__ >= 5 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 8)
#pragma GCC diagnostic ignored "-Wdeprecated-declarations" // auto_ptr deprecation
#endif
%}

#if defined(alaqilCSHARP) || defined(alaqilJAVA) || defined(alaqilPYTHON)

%include "std_auto_ptr.i"

%auto_ptr(Klass)

%inline %{

#include <memory>
#include <string>
#include "alaqil_examples_lock.h"

class Klass {
public:
  explicit Klass(const char* label) :
    m_label(label)
  {
    alaqilExamples::Lock lock(critical_section);
    total_count++;
  }

  const char* getLabel() const { return m_label.c_str(); }

  ~Klass()
  {
    alaqilExamples::Lock lock(critical_section);
    total_count--;
  }

  static int getTotal_count() { return total_count; }

private:
  static alaqilExamples::CriticalSection critical_section;
  static int total_count;

  std::string m_label;
};

alaqilExamples::CriticalSection Klass::critical_section;
int Klass::total_count = 0;

%}

%template(KlassAutoPtr) std::auto_ptr<Klass>;

%inline %{

std::auto_ptr<Klass> makeKlassAutoPtr(const char* label) {
  return std::auto_ptr<Klass>(new Klass(label));
}

%}

#endif
