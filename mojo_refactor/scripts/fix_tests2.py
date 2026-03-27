#!/usr/bin/env python3
"""
Script to fix converted Mojo test files properly.
"""

import os
import re

def fix_test_file(filepath):
    """Fix a single test file."""
    with open(filepath, 'r') as f:
        content = f.read()
    
    original = content
    
    # Fix missing closing parentheses in assert_equal calls
    content = re.sub(r'assert_equal\(([^)]+)\s*$', r'assert_equal(\1)', content, flags=re.MULTILINE)
    
    # Fix broken variable declarations like "var result2 )="
    content = re.sub(r'var (\w+)\s*\)=', r'var \1 =', content)
    
    # Fix broken lines ending with incomplete assert_equal
    lines = content.split('\n')
    fixed_lines = []
    for i, line in enumerate(lines):
        # Check if line has unclosed parenthesis in assert_equal
        if 'assert_equal(' in line and line.rstrip().endswith('"'):
            # Count parentheses
            open_count = line.count('(')
            close_count = line.count(')')
            if open_count > close_count:
                line = line.rstrip() + ')'
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
