# P1 Report: Department Assignment Puzzle

## P1.b: number of solutions for clues 1 to 8

`count_solutions([1,2,3,4,5,6,7,8], N)` gives **N = 3**.

There are 13,824 candidate assignments in total (4! x 4! x 4!, one permutation each for departments, languages and projects). Clues 1 to 8 together rule out all but 3 of them.

## What this tells us about the puzzle

A well-posed puzzle has exactly one solution. With N = 3, this puzzle is **under-constrained**: the eight clues are consistent, but they do not determine a single answer. The three remaining solutions are:

| Friend | Solution A | Solution B | Solution C |
|---|---|---|---|
| Alex | design, java, AI | design, java, embedded | testing, python, embedded |
| Ben | development, javascript, web | development, javascript, web | development, javascript, web |
| Carla | research, c++, data | testing, python, AI | design, java, AI |
| Dana | testing, python, embedded | research, c++, data | research, c++, data |

Ben's row is the same in all three, so the clues already fix him completely. The ambiguity is in the other three friends.

Solutions A and C contain exactly the same four (department, language, project) combinations; only the names Alex and Carla are swapped. This matters for the repair below.

## P1.c: the repair (clue 9)

Clue 9 is: **"The friend who prefers the AI project works in the testing department."**

- It mentions no friend by name, only attribute values, as the task requires.
- Because A and C differ only in which name holds which combination, a clue that cannot use names can never separate them. So the solution to keep had to be B, the only one whose combinations are different.
- Clue 9 is true in B (the AI friend is in testing) and false in A and C (the AI friend is in design).

With clue 9 added, `count_solutions([1,2,3,4,5,6,7,8,9], N)` gives **N = 1**, so the puzzle now has a unique solution:

- Alex = [design, java, embedded]
- Ben = [development, javascript, web]
- Carla = [testing, python, AI]
- Dana = [research, c++, data]