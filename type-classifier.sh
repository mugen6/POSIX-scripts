#!/bin/sh

# A POSIX script to classify a list of test values into different categories 

# List of test values
test_values="
350
123
-456
+789
0
099
000000055
0x1A3F
0x123a4
0.00
0.18
85.67
3.1415926535
000000.8
26.0
27.00
28.000000001
-456.0
+789.0
1e10
2.5e-3
-3.5e-11
test e-456
e123
true
false
True
TRUE
hello world
123abc
xyz789
73#
81%
%82
38|6
0x123a4k
50.a
51.1b
7a.5
a7.6
54.c1
0.1j5
7f5
8.2.0
1.2.3.4.5.6
--66
++77
8+6
5++
5--
7=
00=0
"

classify_type() {
    value="$1"
    case "$value" in
    # LONG256 Integer - must start with 0x/0X and contain only hex digits
    0[xX][0-9a-fA-F]*)
        case "$value" in
        0[xX][0-9a-fA-F]*[!0-9a-fA-F]*)
            type=String
            ;;
        *)
            type=Int  # LongInt
        esac
        ;;
    # Floating point in scientific notation
    [0-9]*[eE][+-][0-9]* | [0-9]*[eE][0-9]* | *[.][0-9]*[eE][+-][0-9]* | *[.][0-9]*[eE][0-9]*)
        case "$value" in
        *[!0-9.eE+-]*)
            type=String
            ;;
        *)
            type=Float
        esac
    ;;
    # Floating point with leading sign
    [-+]*.*)
        case "$value" in
        *[!0-9-+.]*|*.*.*)
            type=String
            ;;
        *)
            type=Float
        esac
        ;;
    # Floating point without sign
    *.*)
        case "$value" in
        *[!0-9.]*|*.*.*)
            type=String
            ;;
        *)
            type=Float
        esac
        ;;
    # Integers with leading sign (e.g. -1 or +2)
    [-+][0-9]*)
        case "$value" in
        *[!0-9-+]*)
            type=String
            ;;
        *)
            type=Int
        esac
        ;;
    # Integers without sign
    [0-9]*)
        case "$value" in
        *[!0-9]*) 
            type=String
            ;;
        *)         
            type=Int
        esac
        ;;
    # Booleans (only lower case)
    true|false)
            type=Bool
            ;;
    # Everything else should be a string
    *)
            type=String
    esac
}

printf %s "$test_values" | while IFS= read -r value; do
    [ -n "$value" ] && classify_type "$value"
    printf '%s\t%s\n' "$type" "$value"
done
