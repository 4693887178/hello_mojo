#!/usr/bin/env python3
import os
import re

# Base directory
base_dir = "/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/rqmojo/third_party/NuMojo"

# Find all .mojo files
mojo_files = []
for root, dirs, files in os.walk(base_dir):
    for file in files:
        if file.endswith(".mojo"):
            mojo_files.append(os.path.join(root, file))

print(f"Found {len(mojo_files)} .mojo files")

# Patterns to replace
replacements = [
    # alias -> comptime (at start of line)
    (r'^alias ', 'comptime '),
    # @register_passable("trivial") -> remove and add TrivialRegisterPassable trait
    (r'@register_passable\("trivial"\)', ''),
    # @register_passable -> remove and add RegisterPassable trait
    (r'@register_passable', ''),
    # from memory import -> from std.memory import
    (r'from memory import', 'from std.memory import'),
    # from python import -> from std.python import
    (r'from python import', 'from std.python import'),
    # LegacyUnsafePointer -> UnsafePointer
    (r'LegacyUnsafePointer', 'UnsafePointer'),
    # EqualityComparable -> Equatable
    (r'EqualityComparable', 'Equatable'),
    # Representable -> Writable
    (r'Representable', 'Writable'),
    # Stringable -> Writable
    (r'Stringable', 'Writable'),
    # MutOrigin.external -> MutExternalOrigin
    (r'MutOrigin\.external', 'MutExternalOrigin'),
]

# Process each file
for filepath in mojo_files:
    try:
        with open(filepath, 'r') as f:
            content = f.read()
        
        original_content = content
        
        for pattern, replacement in replacements:
            content = re.sub(pattern, replacement, content)
        
        if content != original_content:
            with open(filepath, 'w') as f:
                f.write(content)
            print(f"Updated: {filepath}")
    except Exception as e:
        print(f"Error processing {filepath}: {e}")

print("Done!")
