---
name: scheme-dev
description: Write, test and self-review Racket 8.x (#lang racket/base) code restricted to a small set of built-ins, for CS F301 Assignment 2 (S1 tree traversals and S2 nested-list insertion).
---

# scheme-dev

## 1. Language

- Racket 8.x. Every file starts with `#lang racket/base`.
- Run a file with `racket FILE.rkt`.
- The grader appends its own calls to the end of the file. The file must therefore contain only definitions: no top-level calls and no output on load.
- Files: `id_q3.rkt` (S1) and `id_q4.rkt` (S2), where `id` is the group ID.

## 2. Conventions

- **Naming:** lowercase with hyphens (`print-inorder`, `tree-height`). Predicates end in `?` (`len-ok?`). Own replacements for forbidden built-ins use the `my-` prefix: `my-length`, `my-reverse`, `my-map`, `my-append` and so on.
- **Comments:** put a `;` comment above every function with its purpose, its arguments and what it returns or prints.
- **Helpers:** if a forbidden built-in would help, write a small helper that does one thing, instead of inlining the logic.
- **State:** pass all state through function arguments (accumulators). There is no mutation.
- **Recursion:** use tail recursion where it is natural, with a named `let` or an accumulator argument. Where it is not natural (for example when building a result from two subtrees), non-tail recursion is fine as long as depth stays proportional to nesting or tree height, not to list length.
- **Data:**
  - A binary tree is `()` or `(value left right)`.
  - A nested list contains atoms and sublists, with no dotted pairs.
  - An atom is anything that is neither a pair nor `()`.
- **Output:** use `display` and `newline` only.

## 3. The ONLY allowed built-ins

- **Binding and control:** `define`, `lambda`, `let`, `let*`, `letrec`, named `let`, `if`, `cond` (with `else`), `and`, `or`, `not`, `begin`.
- **Data:**
  - `quote` (written `'`), `cons`, `car`, `cdr`, `list`.
  - Every composition of `car` and `cdr` up to four levels: `cadr`, `cddr`, `caddr`, `cdddr`, `cadddr`, `cddddr`, `cdar`, `caar` and so on.
- **Tests:** `null?`, `pair?`, `eq?`, `assq`, `assoc`.
- **Arithmetic and comparison:** `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=`, `max`.
- **Output:** `display`, `newline`.
- **S2 only:** `read`.

Nothing else from `racket/base` may be used. If a function is needed that is not in this list, write it yourself.

## 4. Self-review checklist (apply before answering)

- [ ] The file starts with `#lang racket/base`.
- [ ] No `set!` or relatives (`set-car!`, `set-box!` and so on).
- [ ] No vectors, hash tables or strings (no `string-append`, `number->string`, `make-vector`, `make-hash`).
- [ ] No loops (`do`, `for`, `for/list`, `for/fold`).
- [ ] None of these is used: `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, `list-tail`, `foldl`, `foldr`, `apply`, `list?`, `equal?`, `zero?`, `add1`, `sub1`, `void`, `printf`, `format`.
- [ ] No top-level calls, so nothing is printed when the file is loaded (run `racket FILE.rkt` and the output must be empty).
- [ ] Every printing function uses `display` and ends its output with `(newline)`.
- [ ] `else` appears only as the last clause of a `cond`.
- [ ] `()` is handled explicitly, as a list and not as an atom.
- [ ] Each function was tested on `()` (or `'()`), a single element, and a typical example from the assignment.
- [ ] Deep recursion was tested at the sizes the assignment names (nesting depth 100, lists of 10,000 elements).
- [ ] S2 only: there is exactly one definition of `insert-if-short`, and it uses `make-inserter`.

## 5. Known AI failure modes for Scheme

- **Using `append`, `map` or `length` out of habit:** these are forbidden. Use `my-append`, `my-map` and `my-length`, or restructure with accumulators.
- **`else` outside `cond`:** `else` is only meaningful as the last clause of a `cond`. Do not use it in `if` or `case`.
- **Printing with `print` or `write` instead of `display`:** these can differ for symbols and quoting. Use `display` only.
- **Forgetting the final newline:** every function that prints must end with `(newline)`, and `print-all-traversals` prints three lines, each newline-terminated.
- **Treating `()` as an atom:** `(pair? '())` is `#f` and `(null? '())` is `#t`. A sublist test must be `(or (pair? e) (null? e))`, and an atom test must be `(and (not (pair? e)) (not (null? e)))`.
- **Non-tail recursion on 10,000-element lists:** it is slow and memory-heavy even if Racket does not crash. Prefer an accumulator plus `my-reverse` for long flat lists, and recurse on depth, not on length.
- **Measuring length after insertion:** in S2 the length is measured on the original list, before `x` is inserted.
- **Top-level test calls left in the file:** these print on load and break the grader. Keep tests in `tests/`.
- **Quoting mistakes:** an unquoted `()` evaluates in some contexts. Write `'()`. Also check that quoted data in tests is a literal list, not a call.
- **Forbidden built-ins by habit:** `assertion`, `list?`, `equal?`, `zero?`, `add1`, `sub1`, `let-values`, `case`. Replace with allowed forms (`null?`, `eq?`, `=`, `+ 1`, `cond`).
- **Using `read` outside S2:** `read` is allowed only in `id_q4.rkt`.
