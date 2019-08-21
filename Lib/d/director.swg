/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that D proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#if defined(DEBUG_DIRECTOR_OWNED)
#include <iostream>
#endif
#include <string>
#include <exception>

namespace alaqil {

  // Director base class – not used in D directors.
  class Director {
  };

  // Base class for director exceptions.
  class DirectorException : public std::exception {
  protected:
    std::string alaqil_msg;

  public:
    DirectorException(const std::string &msg) : alaqil_msg(msg) {
    }

    virtual ~DirectorException() throw() {
    }

    const char *what() const throw() {
      return alaqil_msg.c_str();
    }
  };

  // Exception which is thrown when attempting to call a pure virtual method
  // from D code through the director layer.
  class DirectorPureVirtualException : public DirectorException {
  public:
    DirectorPureVirtualException(const char *msg) : DirectorException(std::string("Attempted to invoke pure virtual method ") + msg) {
    }

    static void raise(const char *msg) {
      throw DirectorPureVirtualException(msg);
    }
  };
}

