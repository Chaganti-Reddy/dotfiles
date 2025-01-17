import sys
import math
from sys import stdin, stdout
from math import gcd, ceil, sqrt, log
from collections import defaultdict
from bisect import bisect_left, bisect_right

# Increase the recursion limit to handle deep recursion
sys.setrecursionlimit(10**6)

# Input functions
read_int = lambda: int(input())
read_str = lambda: input().strip()
read_int_list = lambda: list(map(int, input().strip().split()))
read_float_list = lambda: list(map(float, input().strip().split()))
join_str = lambda sep, lst: sep.join(map(str, lst))

# Math utility functions
ceil_div = lambda x, d: (x + d - 1) // d  # Efficient ceiling division

# Input/output optimizations
flush = lambda: stdout.flush()
read_line = lambda: stdin.readline().strip()
read_int_stdin = lambda: int(stdin.readline())
write_output = lambda x: stdout.write(str(x) + '\n')

# Constants
MOD = 10**9 + 7

# Main function
def main():
    # Add main logic here
    pass

if __name__ == "__main__":
    main()
