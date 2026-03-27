#!/usr/bin/env python3
"""
Script to convert Mojo test files to use std.testing standard library.
"""

import os
import re
import sys

def convert_test_file(filepath):
    """Convert a single test file to use std.testing."""
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Skip if already using std.testing
    if 'from std.testing import' in content:
        return False
    
    # Skip if it's not a test file
    if 'def test_' not in content and 'fn test_' not in content:
        return False
    
    # Add std.testing import after the docstring
    lines = content.split('\n')
    new_lines = []
    import_added = False
    
    for i, line in enumerate(lines):
        new_lines.append(line)
        
        # Add import after docstring and existing imports
        if not import_added:
            # Check if we're past the docstring and imports
            if line.startswith('from ') or line.startswith('import '):
                continue
            elif line.strip() == '' and i > 0:
                # Check if previous lines were imports or docstring
                prev_content = '\n'.join(lines[:i])
                if '"""' in prev_content or "'''" in prev_content or 'from ' in prev_content or 'import ' in prev_content:
                    continue
            
            # Add the import
            if not import_added and (line.startswith('fn test_') or line.startswith('def test_') or line.startswith('@') or line.strip() == ''):
                new_lines.insert(len(new_lines) - 1, '')
                new_lines.insert(len(new_lines) - 1, 'from std.testing import assert_equal, assert_true, assert_false, assert_raises, TestSuite')
                new_lines.insert(len(new_lines) - 1, '')
                import_added = True
    
    # Convert test functions
    new_content = '\n'.join(new_lines)
    
    # Convert fn test_ to def test_ and add raises
    new_content = re.sub(r'fn (test_\w+)\(\)', r'def \1() raises', new_content)
    new_content = re.sub(r'fn (test_\w+)\(\) -> Bool:', r'def \1() raises:', new_content)
    
    # Convert print + raise pattern to assert
    # Pattern: print("Test: xxx") ... if condition: raise "error"
    # This is complex, so we'll do simple conversions
    
    # Convert manual passed/failed counting to TestSuite
    # Remove main function if it exists and add new one
    if 'def main()' in new_content:
        # Replace existing main
        new_content = re.sub(
            r'def main\(\)[^:]*:.*?(?=\n\n|\Z)',
            'def main() raises:\n    TestSuite.discover_tests[__functions_in_module()]().run()',
            new_content,
            flags=re.DOTALL
        )
    else:
        # Add main at the end
        new_content = new_content.rstrip() + '\n\n\ndef main() raises:\n    TestSuite.discover_tests[__functions_in_module()]().run()\n'
    
    with open(filepath, 'w') as f:
        f.write(new_content)
    
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
    
    converted = 0
    for test_dir in test_dirs:
        if not os.path.exists(test_dir):
            continue
        for filename in os.listdir(test_dir):
            if filename.endswith('.mojo'):
                filepath = os.path.join(test_dir, filename)
                if convert_test_file(filepath):
                    converted += 1
                    print(f"Converted: {filepath}")
    
    print(f"\nTotal converted: {converted} files")

if __name__ == '__main__':
    main()
