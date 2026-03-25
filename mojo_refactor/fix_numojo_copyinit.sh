#!/bin/bash
# Script to fix __copyinit__ and __moveinit__ in NuMojo library files

# List of files to fix
FILES=(
    "numojo/core/ndarray.mojo"
    "numojo/core/ndstrides.mojo"
    "numojo/core/ndshape.mojo"
    "numojo/core/flags.mojo"
    "numojo/core/item.mojo"
    "numojo/core/complex/complex_ndarray.mojo"
    "numojo/core/matrix.mojo"
)

# Function to fix __copyinit__ -> __init__(out self, *, copy: Self)
    # Fix the variable references from 'other' to 'copy'
    self.ndim = copy.ndim
    self._buf = alloc[Scalar[Self.element_type]](copy.ndim)
    if copy.ndim == 0:
        self._buf.init_pointee_copy(0)
    else:
        self._buf = alloc[Scalar[Self.element_type]](copy.ndim)
        memcpy(dest=self._buf, src=copy._buf, count=copy.ndim)
    # Fix __moveinit__ -> __init__(out self, *, deinit take: Self)
    self.ndim = take.ndim
    self._buf = take._buf
    self._buf.ptr.free()
