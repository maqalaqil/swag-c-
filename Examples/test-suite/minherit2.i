%module minherit2

// A multiple inheritance example, mainly for Java, C# and D.
// The example shows how it is possible to turn C++ abstract base classes into
// Java/C#/D interfaces.
// In the future, all this trouble might be more automated.

%warnfilter(alaqilWARN_JAVA_MULTIPLE_INHERITANCE,
	    alaqilWARN_CSHARP_MULTIPLE_INHERITANCE,
	    alaqilWARN_D_MULTIPLE_INHERITANCE,
	    alaqilWARN_RUBY_MULTIPLE_INHERITANCE,
	    alaqilWARN_PHP_MULTIPLE_INHERITANCE) RemoteMpe;


#if defined(alaqilJAVA) || defined(alaqilCSHARP) || defined(alaqilD)

#if defined(alaqilCSHARP)
#define javaclassmodifiers   csclassmodifiers
#define javabody             csbody
#define javafinalize         csfinalize
#define javadestruct         csdestruct
#define javaout              csout
#define javainterfaces       csinterfaces
#define javabase             csbase
#endif

#if defined(alaqilD)
#define javaclassmodifiers   dclassmodifiers
#define javabody             dbody
#define javafinalize         ddestructor
#define javadestruct         ddispose
#define javaout              dout
#define javainterfaces       dinterfaces
#define javabase             dbase

%typemap(dimports) RemoteMpe %{
$importtype(IRemoteSyncIO)
$importtype(IRemoteAsyncIO)
%}
#endif

// Modify multiple inherited base classes into inheriting interfaces
%typemap(javainterfaces) RemoteMpe "IRemoteSyncIO, IRemoteAsyncIO";
%typemap(javabase, replace="1") RemoteMpe "";

// Turn the proxy class into an interface
%typemap(javaclassmodifiers) IRemoteSyncIO "public interface";
%typemap(javaclassmodifiers) IRemoteAsyncIO "public interface";
%typemap(javabody) IRemoteSyncIO "";
%typemap(javabody) IRemoteAsyncIO "";
%typemap(javafinalize) IRemoteSyncIO "";
%typemap(javafinalize) IRemoteAsyncIO "";
%typemap(javadestruct) IRemoteSyncIO "";
%typemap(javadestruct) IRemoteAsyncIO "";

// Turn the methods into abstract methods
%typemap(javaout) void IRemoteSyncIO::syncmethod ";"
%typemap(javaout) void IRemoteAsyncIO::asyncmethod ";"
#if defined(alaqilJAVA)
%javamethodmodifiers IRemoteSyncIO::syncmethod "abstract public";
%javamethodmodifiers IRemoteAsyncIO::asyncmethod "abstract public";
// Features are inherited by derived classes, so override this
%javamethodmodifiers RemoteMpe::syncmethod "public"
%javamethodmodifiers RemoteMpe::asyncmethod "public"
#elif defined(alaqilCSHARP)
%csmethodmodifiers IRemoteSyncIO::syncmethod "";
%csmethodmodifiers IRemoteAsyncIO::asyncmethod "";
// Features are inherited by derived classes, so override this
%csmethodmodifiers RemoteMpe::syncmethod "public"
%csmethodmodifiers RemoteMpe::asyncmethod "public"
#elif defined(alaqilD)
%dmethodmodifiers IRemoteSyncIO::syncmethod "";
%dmethodmodifiers IRemoteAsyncIO::asyncmethod "";
// Features are inherited by derived classes, so override this
%dmethodmodifiers RemoteMpe::syncmethod "public"
%dmethodmodifiers RemoteMpe::asyncmethod "public"
#endif

#endif


%inline %{
class IRemoteSyncIO
{
public:
  virtual ~IRemoteSyncIO () {}
  virtual void syncmethod() = 0;
protected:
  IRemoteSyncIO () {}
  
private:
  IRemoteSyncIO (const IRemoteSyncIO&);
  IRemoteSyncIO& operator= (const IRemoteSyncIO&);
};

class IRemoteAsyncIO
{
public:
  virtual ~IRemoteAsyncIO () {}
  virtual void asyncmethod() = 0;
protected:
  IRemoteAsyncIO () {}
  
private:
  IRemoteAsyncIO (const IRemoteAsyncIO&);
  IRemoteAsyncIO& operator= (const IRemoteAsyncIO&);
};

class RemoteMpe : public IRemoteSyncIO, public IRemoteAsyncIO
{
public:
  virtual void syncmethod() {}
  virtual void asyncmethod() {}
};

%}

