#!/usr/bin/env python3
"""
Script to fix converted Mojo test files.
"""

import os
import re

def fix_test_file(filepath):
    """Fix a single test file."""
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Add raises to test functions that don't have it
    content = re.sub(r'def (test_\w+)\(\):', r'def \1() raises:', content)
    
    # Convert assert to assert_true
    content = re.sub(r'assert ([^=]+) == ([^=]+)', r'assert_equal(\1, \2)', content)
    content = re.sub(r'assert ([^=]+) != ([^=]+)', r'assert_true(\1 != \2)', content)
    content = re.sub(r'assert ([^=\n]+)$', r'assert_true(\1)', content, flags=re.MULTILINE)
    
    with open(filepath, 'w') as f:
        f.write(content)
    
    return True

def main():
    test_dirs = [
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_01',
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_02',
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_03',
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_04',
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_05',
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_06',
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_07',
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_08',
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_09',
        '/home/zhou/hello_mojo/trae_cn_78/mojo_refactor/tests/mojo/group_13',
    ]
    
    fixed = 0
    for test_dir in test_dirs:
        if not os.path.exists(test_dir):
            continue
        for filename in os.listdir(test_dir):
            if filename.endswith('.mojo'):
                filepath = os.path.join(test_dir, filename)
                if fix_test_file(filepath):
                    fixed += 1
                    print(f"Fixed: {filepath}")
    
    print(f"\nTotal fixed: {fixed} files")

if __name__ == '__main__':
    main()
