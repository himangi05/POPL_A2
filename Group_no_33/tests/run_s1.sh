#!/usr/bin/env bash
# Tests for ../code/33_q3.rkt (S1: binary tree traversals).
# Run from anywhere:   bash tests/run_s1.sh
# It appends s1_calls.rkt to the code file (as the grader does) into a temp file, runs that
# with racket, and diffs the output against s1_expected.txt (small trees, written by hand from
# the assignment) plus the expected lines for the two 1000-node chains (generated with seq).
# Exit code 0 = every check passed, 1 = at least one failed.

cd "$(dirname "$0")" || exit 1
CODE=../code/33_q3.rkt
CALLS=s1_calls.rkt
EXPECTED=s1_expected.txt
TMP=_tmp_s1
rm -rf "$TMP"; mkdir "$TMP"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0

report() {                       # report <name> <ok:0/1>
  if [ "$2" -eq 0 ]; then pass=$((pass+1)); echo "PASS  $1"
  else fail=$((fail+1)); echo "FAIL  $1"; fi
}

# ---- expected output: the hand-written part, then the generated part for the chains
join() { tr '\n' ' ' | sed 's/ $//'; }
asc="($(seq 1 1000 | join))"          # (1 2 ... 1000)
desc="($(seq 1000 -1 1 | join))"      # (1000 999 ... 1)
cp "$EXPECTED" "$TMP/expected"
{
  # left-leaning chain: inorder and postorder are 1000..1, preorder is 1..1000
  echo "$desc"                                  # print-inorder
  echo "$desc"; echo "$asc"; echo "$desc"       # print-all-traversals
  echo "(1000 1)"                               # print-height-and-leaves
  # right-leaning chain: inorder and preorder are 1..1000, postorder is 1000..1
  echo "$asc"                                   # print-inorder
  echo "$asc"; echo "$asc"; echo "$desc"        # print-all-traversals
  echo "(1000 1)"                               # print-height-and-leaves
} >> "$TMP/expected"

# ---- run: code file + calls file, as the grader does
cat "$CODE" "$CALLS" > "$TMP/run.rkt"
racket "$TMP/run.rkt" 2>"$TMP/err" | tr -d '\r' > "$TMP/actual"

if cmp -s "$TMP/actual" "$TMP/expected" && [ ! -s "$TMP/err" ]; then
  report "all output matches the expected file ($(wc -l < "$TMP/expected") lines)" 0
else
  report "all output matches the expected file" 1
  echo "--- first differences (actual vs expected):"
  diff <(cut -c1-80 "$TMP/actual") <(cut -c1-80 "$TMP/expected") | head -20
  [ -s "$TMP/err" ] && { echo "--- racket error:"; head -5 "$TMP/err"; }
fi

# ---- the same output, checked block by block so a failure says which tree broke
names=(t1 t2 t3 "empty tree" "single node" "unbalanced tree"
       "root with only a left child (t5)" "root with only a right child (t6)"
       "left chain (1000)" "right chain (1000)")
for i in 0 1 2 3 4 5 6 7 8 9; do
  start=$((i*5+1)); end=$((i*5+5))
  if [ "$(sed -n "${start},${end}p" "$TMP/actual")" == "$(sed -n "${start},${end}p" "$TMP/expected")" ]; then
    report "${names[$i]}" 0
  else report "${names[$i]}" 1; fi
done

# ---- rules for the code file
if [ -z "$(racket "$CODE" 2>&1)" ]; then report "loading the file prints nothing" 0
else report "loading the file prints nothing" 1; fi

if grep -n '^(' "$CODE" | grep -v '^[0-9]*:(define' | grep -q .; then
  report "only definitions at top level" 1
else report "only definitions at top level" 0; fi

if [ "$(sed -n 1p "$CODE" | tr -d '\r')" == "#lang racket/base" ]; then report "starts with #lang racket/base" 0
else report "starts with #lang racket/base" 1; fi

for f in print-inorder print-all-traversals print-height-and-leaves; do
  if grep -q "^(define ($f tree)" "$CODE"; then report "defines ($f tree)" 0
  else report "defines ($f tree)" 1; fi
done

if grep -v '^[[:space:]]*;' "$CODE" \
   | sed 's/inorder-list//g; s/preorder-list//g; s/postorder-list//g; s/print-inorder//g; s/print-all-traversals//g; s/print-height-and-leaves//g; s/tree-height//g; s/leaf-count//g' \
   | grep -qE '\b(length|append|reverse|map|filter|member|memq|list-ref|list-tail|set!|vector|hash|string|for|do|apply|foldl|foldr|list\?|equal\?|printf|format|print|write)\b'; then
  report "no forbidden built-ins" 1
else report "no forbidden built-ins" 0; fi

echo
echo "passed: $pass   failed: $fail"
[ "$fail" -eq 0 ]