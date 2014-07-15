#include <assert.h>

extern "C" __device__ void exit(int ret) __THROW { assert(0); }

