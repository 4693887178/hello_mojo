"""Test importing third-party Mojo packages."""

from argmojo import Argument, Arg, Command, ParseResult
from emberjson import Value, JSON, Array, Object, parse
from numojo import NDArray, zeros, ones, array
from yaml import parse as yaml_parse, YamlValue, Lexer, Parser
from morrow import Morrow, TimeZone, TimeDelta

def main() raises:
    print("=" * 60)
    print("Third-Party Package Import Tests")
    print("=" * 60)
    
    print("\n1. argmojo - imported successfully")
    print("   Available: Argument, Arg, Command, ParseResult")
    
    print("\n2. EmberJson - imported successfully")
    print("   Available: Value, JSON, Array, Object, parse")
    
    print("\n3. NuMojo - imported successfully")
    print("   Available: NDArray, zeros, ones, array")
    
    print("\n4. mojo-yaml - imported successfully")
    print("   Available: yaml_parse, YamlValue, Lexer, Parser")
    
    print("\n5. morrow - imported successfully")
    print("   Available: Morrow, TimeZone, TimeDelta")
    
    print("\n" + "=" * 60)
    print("All 5 third-party packages imported successfully!")
    print("=" * 60)
