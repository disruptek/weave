# Strings
# -------------------------------------------------------

proc printf*(formatstr: cstring) {.header: "<stdio.h>", varargs, sideeffect.}
  # Nim interpolation with "%" doesn't support formatting
  # And strformat requires inlining the variable with the format

proc fprintf*(file: File, formatstr: cstring) {.header: "<stdio.h>", varargs, sideeffect.}

# We use the system malloc to reproduce the original results
# instead of Nim alloc or implementing our own multithreaded allocator
# This also allows us to use normal memory leaks detection tools
# during proof-of-concept stage

# Memory
# -------------------------------------------------------

func malloc(size: csize): pointer {.header: "<stdio.h>".}
  # We consider that malloc as no side-effect
  # i.e. it never fails
  #      and we don't care about pointer addresses

func malloc*(T: typedesc): ptr T {.inline.}=
  result = cast[type result](malloc(sizeof(T)))

func malloc*(T: typedesc, len: Natural): ptr UncheckedArray[T] {.inline.}=
  result = cast[type result](malloc(sizeof(T) * len))

func free*(p: sink pointer) {.header: "<stdio.h>".}
  # We consider that free as no side-effect
  # i.e. it never fails

when defined(windows):
  proc alloca(size: csize): pointer {.header: "<malloc.h>".}
else:
  proc alloca(size: csize): pointer {.header: "<alloca.h>".}

template alloca*(T: typedesc): ptr T =
  cast[ptr T](alloca(sizeof(T)))

template alloca*(T: typedesc, len: Natural): ptr UncheckedArray[T] =
  cast[ptr UncheckedArray[T]](alloca(sizeof(T) * len))

# Random
# -------------------------------------------------------

proc rand_r*(seed: var uint32): int32 {.header: "<stdlib.h>".}
  ## Random number generator
  ## Threadsafe but small amount of state
