---
name: prolog-dev
description: Write, test and self-review SWI-Prolog 9.x code for CS F301 Assignment 2 (P1 puzzle and P2 equations), declarative and definitions-only.
---

# prolog-dev

## 1. Language

- SWI-Prolog 9.x.
- Run the main program: `swipl -q -f id_q1.pl -g main -t halt`
- Run any other goal: `swipl -q -f FILE -g "<goal>" -t halt`
- The grader supplies `halt` through `-t halt`. Code must never call `halt/0` itself.
- Allowed libraries only: `lists`, `apply`, `yall`, `aggregate`.
- Files: `id_q1.pl` (P1) and `id_q2.pl` (P2), where `id` is the group ID.

## 2. Conventions

- **Naming:** predicate and atom names are `snake_case` (`count_solutions`, `tree_string`). Variables are `CamelCase` with meaningful names (`Active`, `Sol`, `Rest`). Use `_` for deliberately unused variables.
- **Comments:** put exactly one `%` comment line directly above each predicate, saying what it does.
- **Declarative reading:** every predicate gets a second comment line giving its declarative reading, in the form `% Reads: <Head> holds when <conditions>.`
- **Structure:** group all clauses of a predicate together, in a fixed order: base case first, then recursive cases.
- **Style:** prefer relations and pattern matching over control flow. Use `findall/3`, `forall/2`, `member/2`, `select/3` and `permutation/2` rather than hand-written loops where they fit.
- **Data representation:** use the exact atoms the assignment specifies, quoted where needed (`'Alex'`, `'c++'`, `'AI'`). Strings are SWI-Prolog strings (double-quoted) only where the spec says "string".
- **Output:** use `format/2` with `~w` for values that must print unquoted, and end each line with `~n`.

## 3. How to run and test

1. Load check: `swipl -q -f FILE -g true -t halt`. The output must be empty, with no warnings and no errors.
2. Run the entry point: `swipl -q -f id_q1.pl -g main -t halt`.
3. Run a single goal: `swipl -q -f FILE -g "count_solutions([1,2,3,4,5,6,7,8],N), write(N), nl" -t halt`.
4. Keep tests in `tests/` (one file per problem). Test files may use `:- initialization` and `plunit`. Code files may not.
5. Test every example given in the assignment, then edge cases: empty input, single-element input, impossible input, and inputs containing 0.
6. Compare output byte for byte against the expected format. Check for stray spaces, quotes and missing newlines.

## 4. Self-review checklist (apply before answering)

- [ ] The file contains only definitions, with no top-level goals and no `:- initialization(...)`.
- [ ] There is no call to `halt/0`.
- [ ] There is no `assert`, `asserta`, `assertz`, `retract`, `b_setval` or `nb_setval`.
- [ ] Only `lists`, `apply`, `yall` and `aggregate` are used (no `clpfd`, `dcg/basics`, `strings` and so on).
- [ ] Nothing is printed except what the problem specifies (no debug output, no `print_message`, no `listing`).
- [ ] Loading the file produces no warnings (no singleton variables, discontiguous clauses or unknown procedures).
- [ ] Every predicate has its two comment lines (purpose and declarative reading).
- [ ] Each predicate was tested on at least one success case and one failure case.
- [ ] Predicates required to fail (rather than loop or error) do fail, including on `[]` and one-element lists.
- [ ] Atoms such as `'Alex'`, `'c++'` and `'AI'` are quoted correctly, and output prints them unquoted where the format requires.

## 5. Known AI failure modes for Prolog

- **Imperative thinking:** loops, counters and mutable state instead of relations. Fix by restating each predicate as a logical rule.
- **Left recursion that loops:** a recursive call placed before any consuming goal. Put the consuming goal (such as `select/3` or a list-pattern head) first.
- **Negation on unbound variables:** `\+ Goal` with unbound variables is unsound. Make sure every variable is bound before the negation, which is why clues are checked on a fully filled-in solution.
- **Mixing atoms, strings and code lists:** `"abc"` is a string in SWI-Prolog 7+, not a code list or atom. Use `atom_string/2` or `string_concat/3` deliberately, and never build text and parse it back into a term.
- **Forgetting quotes:** `c++` unquoted is a syntax error, and `AI` unquoted is a variable. Write `'c++'` and `'AI'`.
- **`sort/2` vs `msort/2`:** `sort/2` removes duplicates and sorts in standard order. `msort/2` keeps duplicates. Use the one the spec asks for.
- **Extra output:** debugging `write/1` or `print/1` left in the file, or a trailing space or newline different from the spec.
- **Unneeded cuts:** `!` added "for speed" that changes the set of solutions, or that breaks `count_solutions`. Prefer `once/1` at the call site, and only when one answer is truly wanted.
- **Forbidden features by habit:** `assert/retract`, global variables, `clpfd`, `string_to_atom`-style round trips for evaluation.
- **Wrong exactness of arithmetic:** `/` may produce floats. Check divisibility explicitly with `mod` and a non-zero divisor before dividing.
- **Singleton and discontiguous warnings:** these are signs of typos and misplaced clauses, so fix them rather than ignore them.
