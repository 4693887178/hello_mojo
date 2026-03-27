#!/usr/bin/env python3
"""
Script to properly fix Mojo test files.
"""

import os
import re

def fix_test_file(filepath):
    """Fix a single test file."""
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content
    
    # Fix broken patterns like ")==" or ")!="
    content = re.sub(r'\s*\)==', ' ==', content)
    content = re.sub(r'\s*\)!=', ' !=', content)
    content = re.sub(r'\s*\)=', ' =', content)
    
    # Fix lines ending with incomplete assert_equal
    lines = content.split('\n')
    fixed_lines = []
    for i, line in enumerate(lines):
        # Fix unclosed parenthesis in assert_equal
        if 'assert_equal(' in line:
            open_count = line.count('(')
            close_count = line.count(')')
            if open_count > close_count:
                diff = open_count - close_count
                line = line.rstrip() + ')' * diff
        fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

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
