# Patch file to fix NuMojo library for Mojo 0.26.2.0
# This file contains fixes for deprecated syntax

# Fix 1: Replace 'alias' with 'comptime'
# Fix 2: Replace '' with RegisterPassable trait
# Fix 3: Replace '' with TrivialRegisterPassable trait
# Fix 4: Replace '__copyinit__(out self, other: Self)' with '__init__(out self, *, copy: Self)'
# Fix 5: Replace '__moveinit__(out self, deinit existing: Self)' with '__init__(out self, *, deinit take: Self)'
# Fix 6: Replace 'VariadicList[Int]' with 'VariadicList[Int, _]'
# Fix 7: Replace 'from std.memory import' with 'from std.memory import'
# Fix 8: Replace 'from std.python import' with 'from std.python import'
# Fix 9: Replace 'UnsafePointer' with 'UnsafePointer'
# Fix 10: Replace 'Equatable' with 'Equatable'
# Fix 11: Replace 'Writable' with 'Writable'
# Fix 12: Replace 'Writable' with 'Writable'
# Fix 13: Replace 'MutExternalOrigin' with 'MutExternalOrigin'
