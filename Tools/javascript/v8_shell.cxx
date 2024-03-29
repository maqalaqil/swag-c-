#include <assert.h>
#include <fcntl.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include <v8.h>
#include <vector>

#include "js_shell.h"

typedef int (*V8ExtensionInitializer) (v8::Handle<v8::Object> module);

// Note: these typedefs and defines are used to deal with  v8 API changes since version 3.19.00

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031903)
typedef v8::Handle<v8::Value> alaqilV8ReturnValue;
typedef v8::Arguments alaqilV8Arguments;
typedef v8::AccessorInfo alaqilV8PropertyCallbackInfo;
#define alaqilV8_RETURN(val) return scope.Close(val)
#define alaqilV8_RETURN_INFO(val, info) return scope.Close(val)
#else
typedef void alaqilV8ReturnValue;
typedef v8::FunctionCallbackInfo<v8::Value> alaqilV8Arguments;
typedef v8::PropertyCallbackInfo<v8::Value> alaqilV8PropertyCallbackInfo;
#define alaqilV8_RETURN(val) args.GetReturnValue().Set(val); return
#define alaqilV8_RETURN_INFO(val, info) info.GetReturnValue().Set(val); return
#endif


#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032117)
#define alaqilV8_HANDLESCOPE() v8::HandleScope scope
#define alaqilV8_HANDLESCOPE_ESC() v8::HandleScope scope
#define alaqilV8_ESCAPE(val) return scope.Close(val)
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032318)
#define alaqilV8_HANDLESCOPE() v8::HandleScope scope(v8::Isolate::GetCurrent());
#define alaqilV8_HANDLESCOPE_ESC() v8::HandleScope scope(v8::Isolate::GetCurrent());
#define alaqilV8_ESCAPE(val) return scope.Close(val)
#else
#define alaqilV8_HANDLESCOPE() v8::HandleScope scope(v8::Isolate::GetCurrent());
#define alaqilV8_HANDLESCOPE_ESC() v8::EscapableHandleScope scope(v8::Isolate::GetCurrent());
#define alaqilV8_ESCAPE(val) return scope.Escape(val)
#endif

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x032318)
#define alaqilV8_CURRENT_CONTEXT() v8::Context::GetCurrent()
#define alaqilV8_STRING_NEW(str) v8::String::New(str)
#define alaqilV8_FUNCTEMPLATE_NEW(func) v8::FunctionTemplate::New(func)
#define alaqilV8_OBJECT_NEW() v8::Object::New()
#define alaqilV8_EXTERNAL_NEW(val) v8::External::New(val)
#define alaqilV8_UNDEFINED() v8::Undefined()
#else
#define alaqilV8_CURRENT_CONTEXT() v8::Isolate::GetCurrent()->GetCurrentContext()
#define alaqilV8_STRING_NEW(str) v8::String::NewFromUtf8(v8::Isolate::GetCurrent(), str)
#define alaqilV8_FUNCTEMPLATE_NEW(func) v8::FunctionTemplate::New(v8::Isolate::GetCurrent(), func)
#define alaqilV8_OBJECT_NEW() v8::Object::New(v8::Isolate::GetCurrent())
#define alaqilV8_EXTERNAL_NEW(val) v8::External::New(v8::Isolate::GetCurrent(), val)
#define alaqilV8_UNDEFINED() v8::Undefined(v8::Isolate::GetCurrent())
#endif


#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
typedef v8::Persistent<v8::Context> alaqilV8Context;
#else
typedef v8::Local<v8::Context> alaqilV8Context;
#endif

class V8Shell: public JSShell {

public:
  V8Shell();

  virtual ~V8Shell();

  virtual bool RunScript(const std::string &scriptPath);

  virtual bool RunShell();


protected:

  virtual bool InitializeEngine();

  virtual bool ExecuteScript(const std::string &source, const std::string &scriptPath);

  virtual bool DisposeEngine();

private:

  v8::Handle<v8::Value> Import(const std::string &moduleName);

  alaqilV8Context CreateShellContext();

  void ReportException(v8::TryCatch *handler);

  static alaqilV8ReturnValue Print(const alaqilV8Arguments &args);

  static alaqilV8ReturnValue Require(const alaqilV8Arguments &args);

  static alaqilV8ReturnValue Quit(const alaqilV8Arguments &args);

  static alaqilV8ReturnValue Version(const alaqilV8Arguments &args);

  static const char* ToCString(const v8::String::Utf8Value &value);

};

#ifdef __GNUC__
#include <dlfcn.h>
#define LOAD_SYMBOL(handle, name) dlsym(handle, name)
#else
#error "implement dll loading"
#endif

V8Shell::V8Shell() {}

V8Shell::~V8Shell() {}

bool V8Shell::RunScript(const std::string &scriptPath) {
  std::string source = ReadFile(scriptPath);

  v8::Isolate *isolate = v8::Isolate::New();
  v8::Isolate::Scope isolate_scope(isolate);

  alaqilV8_HANDLESCOPE();

  alaqilV8Context context = CreateShellContext();

  if (context.IsEmpty()) {
      printf("Could not create context.\n");
      return false;
  }

  context->Enter();

  // Store a pointer to this shell for later use

  v8::Handle<v8::Object> global = context->Global();
  v8::Local<v8::External> __shell__ = alaqilV8_EXTERNAL_NEW((void*) (long) this);

  global->SetHiddenValue(alaqilV8_STRING_NEW("__shell__"), __shell__);

  // Node.js compatibility: make `print` available as `console.log()`
  ExecuteScript("var console = {}; console.log = print;", "<console>");

  bool success = ExecuteScript(source, scriptPath);

  // Cleanup

  context->Exit();

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
    context.Dispose();
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
    context.Dispose(v8::Isolate::GetCurrent());
#else
//    context.Dispose();
#endif

//  v8::V8::Dispose();

  return success;
}

bool V8Shell::RunShell() {
  alaqilV8_HANDLESCOPE();

  alaqilV8Context context = CreateShellContext();

  if (context.IsEmpty()) {
      printf("Could not create context.\n");
      return false;
  }

  context->Enter();

  v8::Context::Scope context_scope(context);

  ExecuteScript("var console = {}; console.log = print;", "<console>");

  static const int kBufferSize = 1024;
  while (true) {
    char buffer[kBufferSize];
    printf("> ");
    char *str = fgets(buffer, kBufferSize, stdin);
    if (str == NULL) break;
    std::string source(str);
    ExecuteScript(source, "(shell)");
  }
  printf("\n");

  // Cleanup

  context->Exit();

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031710)
    context.Dispose();
#elif (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
    context.Dispose(v8::Isolate::GetCurrent());
#else
//    context.Dispose();
#endif

//  v8::V8::Dispose();

  return true;
}


bool V8Shell::InitializeEngine() {
  return true;
}

bool V8Shell::ExecuteScript(const std::string &source, const std::string &name) {
  alaqilV8_HANDLESCOPE();

  v8::TryCatch try_catch;
  v8::Handle<v8::Script> script = v8::Script::Compile(alaqilV8_STRING_NEW(source.c_str()), alaqilV8_STRING_NEW(name.c_str()));

  // Stop if script is empty
  if (script.IsEmpty()) {
    // Print errors that happened during compilation.
    ReportException(&try_catch);
    return false;
  }

  v8::Handle<v8::Value> result = script->Run();

  // Print errors that happened during execution.
  if (try_catch.HasCaught()) {
    ReportException(&try_catch);
    return false;
  } else {
    return true;
  }
}

bool V8Shell::DisposeEngine() {
  return true;
}

alaqilV8Context V8Shell::CreateShellContext() {
  // Create a template for the global object.
  v8::Handle<v8::ObjectTemplate> global = v8::ObjectTemplate::New();

  // Bind global functions
  global->Set(alaqilV8_STRING_NEW("print"), alaqilV8_FUNCTEMPLATE_NEW(V8Shell::Print));
  global->Set(alaqilV8_STRING_NEW("quit"), alaqilV8_FUNCTEMPLATE_NEW(V8Shell::Quit));
  global->Set(alaqilV8_STRING_NEW("require"), alaqilV8_FUNCTEMPLATE_NEW(V8Shell::Require));
  global->Set(alaqilV8_STRING_NEW("version"), alaqilV8_FUNCTEMPLATE_NEW(V8Shell::Version));

#if (V8_MAJOR_VERSION-0) < 4 && (alaqil_V8_VERSION < 0x031900)
  alaqilV8Context context = v8::Context::New(NULL, global);
  return context;
#else
  alaqilV8Context context = v8::Context::New(v8::Isolate::GetCurrent(), NULL, global);
  return context;
#endif
}

v8::Handle<v8::Value> V8Shell::Import(const std::string &module_path)
{
  alaqilV8_HANDLESCOPE_ESC();

  HANDLE library;
  std::string module_name = LoadModule(module_path, &library);

  std::string symname = std::string(module_name).append("_initialize");

  V8ExtensionInitializer init_function = reinterpret_cast<V8ExtensionInitializer>((long) LOAD_SYMBOL(library, symname.c_str()));

  if(init_function == 0) {
    printf("Could not find initializer function.");

    return alaqilV8_UNDEFINED();
  }

  v8::Local<v8::Object> module = alaqilV8_OBJECT_NEW();
  init_function(module);

  alaqilV8_ESCAPE(module);
}

alaqilV8ReturnValue V8Shell::Print(const alaqilV8Arguments &args) {
  alaqilV8_HANDLESCOPE();

  bool first = true;
  for (int i = 0; i < args.Length(); i++) {

    if (first) {
      first = false;
    } else {
      printf(" ");
    }
    v8::String::Utf8Value str(args[i]);
    const char *cstr = V8Shell::ToCString(str);
    printf("%s", cstr);
  }
  printf("\n");
  fflush(stdout);

  alaqilV8_RETURN(alaqilV8_UNDEFINED());
}

alaqilV8ReturnValue V8Shell::Require(const alaqilV8Arguments &args) {
  alaqilV8_HANDLESCOPE();

  if (args.Length() != 1) {
    printf("Illegal arguments for `require`");
  };

  v8::String::Utf8Value str(args[0]);
  const char *cstr = V8Shell::ToCString(str);
  std::string moduleName(cstr);

  v8::Local<v8::Object> global = alaqilV8_CURRENT_CONTEXT()->Global();

  v8::Local<v8::Value> hidden = global->GetHiddenValue(alaqilV8_STRING_NEW("__shell__"));
  v8::Local<v8::External> __shell__ = v8::Local<v8::External>::Cast(hidden);
  V8Shell *_this = (V8Shell *) (long) __shell__->Value();

  v8::Handle<v8::Value> module = _this->Import(moduleName);

  alaqilV8_RETURN(module);
}

alaqilV8ReturnValue V8Shell::Quit(const alaqilV8Arguments &args) {
  alaqilV8_HANDLESCOPE();

  int exit_code = args[0]->Int32Value();
  fflush(stdout);
  fflush(stderr);
  exit(exit_code);

  alaqilV8_RETURN(alaqilV8_UNDEFINED());
}

alaqilV8ReturnValue V8Shell::Version(const alaqilV8Arguments &args) {
    alaqilV8_HANDLESCOPE();
    alaqilV8_RETURN(alaqilV8_STRING_NEW(v8::V8::GetVersion()));
}

void V8Shell::ReportException(v8::TryCatch *try_catch) {
  alaqilV8_HANDLESCOPE();

  v8::String::Utf8Value exception(try_catch->Exception());
  const char *exception_string = V8Shell::ToCString(exception);
  v8::Handle<v8::Message> message = try_catch->Message();
  if (message.IsEmpty()) {
    // V8 didn't provide any extra information about this error; just
    // print the exception.
    printf("%s\n", exception_string);
  } else {
    // Print (filename):(line number): (message).
    v8::String::Utf8Value filename(message->GetScriptResourceName());
    const char *filename_string = V8Shell::ToCString(filename);
    int linenum = message->GetLineNumber();
    printf("%s:%i: %s\n", filename_string, linenum, exception_string);
    // Print line of source code.
    v8::String::Utf8Value sourceline(message->GetSourceLine());
    const char *sourceline_string = V8Shell::ToCString(sourceline);
    printf("%s\n", sourceline_string);
    // Print wavy underline (GetUnderline is deprecated).
    int start = message->GetStartColumn();
    for (int i = 0; i < start; i++) {
      printf(" ");
    }
    int end = message->GetEndColumn();
    for (int i = start; i < end; i++) {
      printf("^");
    }
    printf("\n");
    v8::String::Utf8Value stack_trace(try_catch->StackTrace());
    if (stack_trace.length() > 0) {
      const char *stack_trace_string = V8Shell::ToCString(stack_trace);
      printf("%s\n", stack_trace_string);
    }
  }
}

// Extracts a C string from a V8 Utf8Value.
const char *V8Shell::ToCString(const v8::String::Utf8Value &value) {
  return *value ? *value : "<string conversion failed>";
}

JSShell *V8Shell_Create() {
  return new V8Shell();
}
