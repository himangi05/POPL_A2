#!/usr/bin/env bash
# Tests for ../code/33_q4.rkt (S2: conditional insert into a nested list).
# Run from anywhere:   bash tests/run_s2.sh
# For each case it appends s2_calls.rkt to the code file (as the grader does), feeds the
# case on standard input, and compares what is printed with the expected text.
# Exit code 0 = every test passed, 1 = at least one failed.

cd "$(dirname "$0")" || exit 1
CODE=../code/33_q4.rkt
CALLS=s2_calls.rkt
TMP=_tmp_s2
rm -rf "$TMP"; mkdir "$TMP"
trap 'rm -rf "$TMP"' EXIT
cat "$CODE" "$CALLS" > "$TMP/run.rkt"
pass=0; fail=0

report() {                       # report <name> <ok:0/1> [detail]
  if [ "$2" -eq 0 ]; then pass=$((pass+1)); echo "PASS  $1"
  else fail=$((fail+1)); echo "FAIL  $1  $3"; fi
}

# check_files <name> <input-file> <expected-file>
check_files() {
  racket "$TMP/run.rkt" < "$2" 2>"$TMP/err" | tr -d '\r' > "$TMP/actual"
  if cmp -s "$TMP/actual" "$3" && [ ! -s "$TMP/err" ]; then report "$1" 0
  else report "$1" 1 "(output differs from expected)"
       diff <(head -c 300 "$TMP/actual") <(head -c 300 "$3") | head -5; fi
}

# check <name> <input text> <expected output text>
check() {
  printf '%s\n' "$2" > "$TMP/in"
  printf '%s\n' "$3" > "$TMP/exp"
  check_files "$1" "$TMP/in" "$TMP/exp"
}

echo "--- examples from the assignment"
check "example 1"  '42 ((1 2) (3 4 5) (6) ()) 3'            '((42 1 2) (3 4 5) (42 6) (42))'
check "example 2"  '0 (((1) 2) (3) ((4 5 6) ())) 3'         '((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))'
check "example 3: empty list, n=3" '7 () 3'                 '(7)'
check "example 4: empty list, n=0" '7 () 0'                 '()'

echo "--- n = 0 (nothing may be inserted)"
check "n=0 with a nested list"   'x ((a) (b c) () ((d))) 0' '((a) (b c) () ((d)))'
check "n=0 flat list"            'x (1 2 3) 0'              '(1 2 3)'

echo "--- other small cases"
check "length is measured on the original list" '9 (1) 2'   '(9 1)'
check "list exactly of length n is not changed" '5 (1 2 3) 3' '(1 2 3)'
check "list of length n-1 gets x"       '5 (1 2 3) 4'       '(5 1 2 3)'
check "nested single-element lists"     '9 ((1)) 2'         '(9 (9 1))'
check "empty sublists become (x)"       'z (a () (b ()) c) 2' '(a (z) (b (z)) c)'
check "only empty lists get x when n=1" 'x (() () ()) 1'    '((x) (x) (x))'
check "empty list inside empty list"    'x (()) 1'          '((x))'
check "x can be a symbol"               'hello ((1) (2 3)) 2' '((hello 1) (2 3))'
check "x can be a number"               '0 ((1) ()) 2'      '((0 1) (0))'
check "input spread over several lines" $'42\n((1 2)\n (3 4 5)\n (6) ())\n  3' '((42 1 2) (3 4 5) (42 6) (42))'

echo "--- big inputs (generated here)"
ints=$(seq 1 10000 | tr '\n' ' ' | sed 's/ $//')
check "10,000 elements, n=3 (unchanged)"   "x ($ints) 3"      "($ints)"
check "10,000 elements, n=20000 (x in front)" "x ($ints) 20000" "(x $ints)"
subs=$(seq 1 10000 | sed 's/.*/(&)/' | tr '\n' ' ' | sed 's/ $//')
xsubs=$(seq 1 10000 | sed 's/.*/(x &)/' | tr '\n' ' ' | sed 's/ $//')
check "10,000 one-element sublists, n=2"   "x ($subs) 2"      "($xsubs)"

open99=$(printf '(%.0s' $(seq 1 99));   close99=$(printf ')%.0s' $(seq 1 99))
xopen99=$(printf '(x %.0s' $(seq 1 99))
check "nesting depth 100, n=0 (unchanged)" "x ${open99}()${close99} 0" "${open99}()${close99}"
check "nesting depth 100, n=1 (only the innermost ())" "x ${open99}()${close99} 1" "${open99}(x)${close99}"
check "nesting depth 100, n=2 (x at every level)" "x ${open99}()${close99} 2" "${xopen99}(x)${close99}"
open999=$(printf '(%.0s' $(seq 1 999)); close999=$(printf ')%.0s' $(seq 1 999))
xopen999=$(printf '(x %.0s' $(seq 1 999))
check "nesting depth 1000, n=2"            "x ${open999}()${close999} 2" "${xopen999}(x)${close999}"

echo "--- rules for the code file"
if [ -z "$(racket "$CODE" 2>&1)" ]; then report "loading the file prints nothing" 0
else report "loading the file prints nothing" 1; fi

if grep -n '^(' "$CODE" | grep -v '^[0-9]*:(define' | grep -q .; then
  report "only definitions at top level" 1
else report "only definitions at top level" 0; fi

if [ "$(grep -c '^(define (insert-if-short' "$CODE")" -eq 1 ] && \
   sed -n '/^(define (insert-if-short/,/^$/p' "$CODE" | grep -q 'make-inserter'; then
  report "single definition of insert-if-short, built on make-inserter" 0
else report "single definition of insert-if-short, built on make-inserter" 1; fi

if sed 's/my-[a-z]*//g; s/make-inserter//g; s/insert-if-short//g; s/print-insert-result//g' "$CODE" \
   | grep -v '^[[:space:]]*;' \
   | grep -qE '\b(length|append|reverse|map|filter|member|memq|list-ref|list-tail|set!|vector|hash|string|for|do|apply|foldl|foldr|list\?|equal\?|printf|format|print|write)\b'; then
  report "no forbidden built-ins" 1
else report "no forbidden built-ins" 0; fi

echo
echo "passed: $pass   failed: $fail"
[ "$fail" -eq 0 ]