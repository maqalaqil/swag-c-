#if defined(alaqil_PYTHON_NO_THREADS)
#  if defined(alaqil_PYTHON_THREADS)
#    undef alaqil_PYTHON_THREADS
#  endif
#endif
#if defined(alaqil_PYTHON_THREADS) /* Threading support is enabled */
#  if !defined(alaqil_PYTHON_USE_GIL) && !defined(alaqil_PYTHON_NO_USE_GIL)
#    define alaqil_PYTHON_USE_GIL
#  endif
#  if defined(alaqil_PYTHON_USE_GIL) /* Use PyGILState threads calls */
#    ifndef alaqil_PYTHON_INITIALIZE_THREADS
#     define alaqil_PYTHON_INITIALIZE_THREADS  PyEval_InitThreads() 
#    endif
#    ifdef __cplusplus /* C++ code */
       class alaqil_Python_Thread_Block {
         bool status;
         PyGILState_STATE state;
       public:
         void end() { if (status) { PyGILState_Release(state); status = false;} }
         alaqil_Python_Thread_Block() : status(true), state(PyGILState_Ensure()) {}
         ~alaqil_Python_Thread_Block() { end(); }
       };
       class alaqil_Python_Thread_Allow {
         bool status;
         PyThreadState *save;
       public:
         void end() { if (status) { PyEval_RestoreThread(save); status = false; }}
         alaqil_Python_Thread_Allow() : status(true), save(PyEval_SaveThread()) {}
         ~alaqil_Python_Thread_Allow() { end(); }
       };
#      define alaqil_PYTHON_THREAD_BEGIN_BLOCK   alaqil_Python_Thread_Block _alaqil_thread_block
#      define alaqil_PYTHON_THREAD_END_BLOCK     _alaqil_thread_block.end()
#      define alaqil_PYTHON_THREAD_BEGIN_ALLOW   alaqil_Python_Thread_Allow _alaqil_thread_allow
#      define alaqil_PYTHON_THREAD_END_ALLOW     _alaqil_thread_allow.end()
#    else /* C code */
#      define alaqil_PYTHON_THREAD_BEGIN_BLOCK   PyGILState_STATE _alaqil_thread_block = PyGILState_Ensure()
#      define alaqil_PYTHON_THREAD_END_BLOCK     PyGILState_Release(_alaqil_thread_block)
#      define alaqil_PYTHON_THREAD_BEGIN_ALLOW   PyThreadState *_alaqil_thread_allow = PyEval_SaveThread()
#      define alaqil_PYTHON_THREAD_END_ALLOW     PyEval_RestoreThread(_alaqil_thread_allow)
#    endif
#  else /* Old thread way, not implemented, user must provide it */
#    if !defined(alaqil_PYTHON_INITIALIZE_THREADS)
#      define alaqil_PYTHON_INITIALIZE_THREADS
#    endif
#    if !defined(alaqil_PYTHON_THREAD_BEGIN_BLOCK)
#      define alaqil_PYTHON_THREAD_BEGIN_BLOCK
#    endif
#    if !defined(alaqil_PYTHON_THREAD_END_BLOCK)
#      define alaqil_PYTHON_THREAD_END_BLOCK
#    endif
#    if !defined(alaqil_PYTHON_THREAD_BEGIN_ALLOW)
#      define alaqil_PYTHON_THREAD_BEGIN_ALLOW
#    endif
#    if !defined(alaqil_PYTHON_THREAD_END_ALLOW)
#      define alaqil_PYTHON_THREAD_END_ALLOW
#    endif
#  endif
#else /* No thread support */
#  define alaqil_PYTHON_INITIALIZE_THREADS
#  define alaqil_PYTHON_THREAD_BEGIN_BLOCK
#  define alaqil_PYTHON_THREAD_END_BLOCK
#  define alaqil_PYTHON_THREAD_BEGIN_ALLOW
#  define alaqil_PYTHON_THREAD_END_ALLOW
#endif
