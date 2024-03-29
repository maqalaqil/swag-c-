/* -----------------------------------------------------------------------------
 * wrapperloader.swg
 *
 * Support code for dynamically linking the C wrapper library from the D
 * wrapper module.
 *
 * The loading code was adapted from the Derelict project and is used with
 * permission from Michael Parker, the original author.
 * ----------------------------------------------------------------------------- */

%pragma(d) wrapperloadercode = %{
private {
  version(linux) {
    version = Nix;
  } else version(darwin) {
    version = Nix;
  } else version(OSX) {
    version = Nix;
  } else version(FreeBSD) {
    version = Nix;
    version = freebsd;
  } else version(freebsd) {
    version = Nix;
  } else version(Unix) {
    version = Nix;
  } else version(Posix) {
    version = Nix;
  }

  version(Tango) {
    static import tango.stdc.string;
    static import tango.stdc.stringz;

    version (PhobosCompatibility) {
    } else {
      alias char[] string;
      alias wchar[] wstring;
      alias dchar[] dstring;
    }
  } else {
    version(D_Version2) {
      static import std.conv;
    }
    static import std.string;
    static import std.c.string;
  }

  version(D_Version2) {
    mixin("alias const(char)* CCPTR;");
  } else {
    alias char* CCPTR;
  }

  CCPTR alaqilToCString(string str) {
    version(Tango) {
      return tango.stdc.stringz.toStringz(str);
    } else {
      return std.string.toStringz(str);
    }
  }

  string alaqilToDString(CCPTR cstr) {
    version(Tango) {
      return tango.stdc.stringz.fromStringz(cstr);
    } else {
      version(D_Version2) {
        mixin("return std.conv.to!string(cstr);");
      } else {
        return std.c.string.toString(cstr);
      }
    }
  }
}

class alaqilalaqilSharedLibLoadException : Exception {
  this(in string[] libNames, in string[] reasons) {
    string msg = "Failed to load one or more shared libraries:";
    foreach(i, n; libNames) {
      msg ~= "\n\t" ~ n ~ " - ";
      if(i < reasons.length)
        msg ~= reasons[i];
      else
        msg ~= "Unknown";
    }
    super(msg);
  }
}

class alaqilSymbolLoadException : Exception {
  this(string alaqilSharedLibName, string symbolName) {
    super("Failed to load symbol " ~ symbolName ~ " from shared library " ~ alaqilSharedLibName);
    _symbolName = symbolName;
  }

  string symbolName() {
    return _symbolName;
  }

private:
  string _symbolName;
}

private {
  version(Nix) {
    version(freebsd) {
      // the dl* functions are in libc on FreeBSD
    }
    else {
      pragma(lib, "dl");
    }

    version(Tango) {
      import tango.sys.Common;
    } else version(linux) {
      import std.c.linux.linux;
    } else {
      extern(C) {
        const RTLD_NOW = 2;

        void *dlopen(CCPTR file, int mode);
        int dlclose(void* handle);
        void *dlsym(void* handle, CCPTR name);
        CCPTR dlerror();
      }
    }

    alias void* alaqilSharedLibHandle;

    alaqilSharedLibHandle alaqilLoadSharedLib(string libName) {
      return dlopen(alaqilToCString(libName), RTLD_NOW);
    }

    void alaqilUnloadSharedLib(alaqilSharedLibHandle hlib) {
      dlclose(hlib);
    }

    void* alaqilGetSymbol(alaqilSharedLibHandle hlib, string symbolName) {
      return dlsym(hlib, alaqilToCString(symbolName));
    }

    string alaqilGetErrorStr() {
      CCPTR err = dlerror();
      if (err is null) {
        return "Unknown Error";
      }
      return alaqilToDString(err);
    }
  } else version(Windows) {
    alias ushort WORD;
    alias uint DWORD;
    alias CCPTR LPCSTR;
    alias void* HMODULE;
    alias void* HLOCAL;
    alias int function() FARPROC;
    struct VA_LIST {}

    extern (Windows) {
      HMODULE LoadLibraryA(LPCSTR);
      FARPROC GetProcAddress(HMODULE, LPCSTR);
      void FreeLibrary(HMODULE);
      DWORD GetLastError();
      DWORD FormatMessageA(DWORD, in void*, DWORD, DWORD, LPCSTR, DWORD, VA_LIST*);
      HLOCAL LocalFree(HLOCAL);
    }

    DWORD MAKELANGID(WORD p, WORD s) {
      return (((cast(WORD)s) << 10) | cast(WORD)p);
    }

    enum {
      LANG_NEUTRAL                    = 0,
      SUBLANG_DEFAULT                 = 1,
      FORMAT_MESSAGE_ALLOCATE_BUFFER  = 256,
      FORMAT_MESSAGE_IGNORE_INSERTS   = 512,
      FORMAT_MESSAGE_FROM_SYSTEM      = 4096
    }

    alias HMODULE alaqilSharedLibHandle;

    alaqilSharedLibHandle alaqilLoadSharedLib(string libName) {
      return LoadLibraryA(alaqilToCString(libName));
    }

    void alaqilUnloadSharedLib(alaqilSharedLibHandle hlib) {
      FreeLibrary(hlib);
    }

    void* alaqilGetSymbol(alaqilSharedLibHandle hlib, string symbolName) {
      return GetProcAddress(hlib, alaqilToCString(symbolName));
    }

    string alaqilGetErrorStr() {
      DWORD errcode = GetLastError();

      LPCSTR msgBuf;
      DWORD i = FormatMessageA(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        null,
        errcode,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        cast(LPCSTR)&msgBuf,
        0,
        null);

      string text = alaqilToDString(msgBuf);
      LocalFree(cast(HLOCAL)msgBuf);

      if (i >= 2) {
        i -= 2;
      }
      return text[0 .. i];
    }
  } else {
    static assert(0, "Operating system not supported by the wrapper loading code.");
  }

  final class alaqilSharedLib {
    void load(string[] names) {
      if (_hlib !is null) return;

      string[] failedLibs;
      string[] reasons;

      foreach(n; names) {
        _hlib = alaqilLoadSharedLib(n);
        if (_hlib is null) {
          failedLibs ~= n;
          reasons ~= alaqilGetErrorStr();
          continue;
        }
        _name = n;
        break;
      }

      if (_hlib is null) {
        throw new alaqilalaqilSharedLibLoadException(failedLibs, reasons);
      }
    }

    void* loadSymbol(string symbolName, bool doThrow = true) {
      void* sym = alaqilGetSymbol(_hlib, symbolName);
      if(doThrow && (sym is null)) {
        throw new alaqilSymbolLoadException(_name, symbolName);
      }
      return sym;
    }

    void unload() {
      if(_hlib !is null) {
        alaqilUnloadSharedLib(_hlib);
        _hlib = null;
      }
    }

  private:
    string _name;
    alaqilSharedLibHandle _hlib;
  }
}

static this() {
  string[] possibleFileNames;
  version (Posix) {
    version (OSX) {
      possibleFileNames ~= ["lib$wraplibrary.dylib", "lib$wraplibrary.bundle"];
    }
    possibleFileNames ~= ["lib$wraplibrary.so"];
  } else version (Windows) {
    possibleFileNames ~= ["$wraplibrary.dll", "lib$wraplibrary.so"];
  } else {
    static assert(false, "Operating system not supported by the wrapper loading code.");
  }

  auto library = new alaqilSharedLib;
  library.load(possibleFileNames);

  string bindCode(string functionPointer, string symbol) {
    return functionPointer ~ " = cast(typeof(" ~ functionPointer ~
      "))library.loadSymbol(`" ~ symbol ~ "`);";
  }

  //#if !defined(alaqil_D_NO_EXCEPTION_HELPER)
  mixin(bindCode("alaqilRegisterExceptionCallbacks$module", "alaqilRegisterExceptionCallbacks_$module"));
  //#endif // alaqil_D_NO_EXCEPTION_HELPER
  //#if !defined(alaqil_D_NO_STRING_HELPER)
  mixin(bindCode("alaqilRegisterStringCallback$module", "alaqilRegisterStringCallback_$module"));
  //#endif // alaqil_D_NO_STRING_HELPER
  $wrapperloaderbindcode
}

//#if !defined(alaqil_D_NO_EXCEPTION_HELPER)
extern(C) void function(
  alaqilExceptionCallback exceptionCallback,
  alaqilExceptionCallback illegalArgumentCallback,
  alaqilExceptionCallback illegalElementCallback,
  alaqilExceptionCallback ioCallback,
  alaqilExceptionCallback noSuchElementCallback) alaqilRegisterExceptionCallbacks$module;
//#endif // alaqil_D_NO_EXCEPTION_HELPER

//#if !defined(alaqil_D_NO_STRING_HELPER)
extern(C) void function(alaqilStringCallback callback) alaqilRegisterStringCallback$module;
//#endif // alaqil_D_NO_STRING_HELPER
%}

%pragma(d) wrapperloaderbindcommand = %{
  mixin(bindCode("$function", "$symbol"));%}
