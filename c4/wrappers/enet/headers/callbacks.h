#ifdef C2NIM
#  skipcomments
#  dynlib lib
#  cdecl
#  if defined(windows)
#    define lib "enet.dll"
#  elif defined(macosx)
#    define lib "enet.dylib"
#  else
#    define lib "libenet.so"
#  endif
# def ENET_CALLBACK
#endif



typedef struct _ENetCallbacks
{
    void * (ENET_CALLBACK * malloc) (size_t size);
    void (ENET_CALLBACK * free) (void * memory);
    void (ENET_CALLBACK * no_memory) (void);
} ENetCallbacks;

extern void * enet_malloc (size_t);
extern void   enet_free (void *);
