% tests/p2_tests.pl: plunit tests for 33_q2.pl (Problem P2, arithmetic equations).
% Run from the repo root:
%   swipl -q -f Group_no_33/tests/p2_tests.pl -g run_tests -t halt

:- use_module(library(plunit)).
:- use_module(library(lists)).

:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/../code/33_q2.pl', File),
   consult(File).

:- begin_tests(p2).

% ---- examples from the assignment ----

test(all_4253, [true(Es == ["4*2-5=3","4*2=5+3","4-2=5-3","4/2=5-3",
                            "4=2*(5-3)","4=2+(5-3)","4=2+5-3"])]) :-
    all_equations([4,2,5,3], Es).

test(generate_4253_is_one_of_the_seven, [nondet]) :-
    generate_equation([4,2,5,3], E),
    memberchk(E, ["4*2-5=3","4*2=5+3","4-2=5-3","4/2=5-3",
                  "4=2*(5-3)","4=2+(5-3)","4=2+5-3"]).

test(generate_4253_finds_all_seven_on_backtracking, [true(N == 7)]) :-
    findall(E, generate_equation([4,2,5,3], E), L),
    sort(L, U),
    length(U, N).

test(count_4253, [true(N == 7)]) :-
    count_equations([4,2,5,3], N).

test(generate_234_fails, [fail]) :-
    generate_equation([2,3,4], _).

test(all_234_empty, [true(Es == [])]) :-
    all_equations([2,3,4], Es).

test(all_248, [true(Es == ["2*4=8"])]) :-
    all_equations([2,4,8], Es).

test(generate_248, [nondet, true(E == "2*4=8")]) :-
    generate_equation([2,4,8], E).

% ---- short lists: fail cleanly, no error, no loop ----

test(generate_empty_fails, [fail]) :-
    generate_equation([], _).

test(generate_single_fails, [fail]) :-
    generate_equation([5], _).

test(all_empty, [true(Es == [])]) :-
    all_equations([], Es).

test(all_single, [true(Es == [])]) :-
    all_equations([5], Es).

test(count_empty_and_single, [true(Ns == [0,0])]) :-
    count_equations([], N1),
    count_equations([5], N2),
    Ns = [N1,N2].

test(two_numbers_unequal, [true(Es == [])]) :-
    all_equations([1,3], Es).

test(two_numbers_equal, [true(Es == ["3=3"])]) :-
    all_equations([3,3], Es).

% ---- zeros ----

test(zero_zero, [true(Es == ["0=0"])]) :-
    all_equations([0,0], Es).

% 0/0 is never allowed, so only +, - and * appear
test(zero_zero_zero, [true(Es == ["0*0=0","0+0=0","0-0=0",
                                  "0=0*0","0=0+0","0=0-0"])]) :-
    all_equations([0,0,0], Es).

% 1/0 and 0/0 must not appear
test(one_zero_zero, [true(Es == ["1*0=0"])]) :-
    all_equations([1,0,0], Es).

% 0/4 is exact and allowed; 4/0 is never allowed
test(zero_four_zero, [true(Es == ["0*4=0","0/4=0","0=4*0"])]) :-
    all_equations([0,4,0], Es).

% no equation ever has a literal 0 as divisor
test(no_divide_by_literal_zero) :-
    forall(( member(L, [[0,0,0],[4,0,2],[1,0,0],[0,4,0],[2,0,0,1],[6,0,3,0]]),
             all_equations(L, Es),
             member(E, Es) ),
           \+ sub_string(E, _, _, _, "/0")).

% a divisor that evaluates to zero inside parentheses is rejected too
test(no_divide_by_computed_zero) :-
    all_equations([8,4,4,0], Es),
    forall(member(E, Es), \+ sub_string(E, _, _, _, "/(4-4)")).

% ---- inexact division ----

% 3/2 and 2/3 are inexact, so only 3-2=1 and 3=2+1 remain
test(inexact_321, [true(Es == ["3-2=1","3=2+1"])]) :-
    all_equations([3,2,1], Es).

% a truncating division would wrongly give 7/2=3
test(inexact_723, [true(Es == [])]) :-
    all_equations([7,2,3], Es).

% ---- negative intermediate values are allowed ----

test(negative_intermediate) :-
    all_equations([1,3,2,0], Es),
    memberchk("1-3+2=0", Es).

% ---- output is a string, no duplicates, sorted ----

test(generate_result_is_string, [nondet]) :-
    generate_equation([4,2,5,3], E),
    string(E).

test(all_results_are_strings) :-
    all_equations([4,2,5,3], Es),
    forall(member(E, Es), string(E)).

test(no_spaces_in_results) :-
    all_equations([4,2,5,3], Es),
    forall(member(E, Es), \+ sub_string(E, _, _, _, " ")).

test(no_duplicates_in_all_equations) :-
    all_equations([1,1,1,1,1], Es),
    sort(Es, Sorted),
    length(Es, N1),
    length(Sorted, N2),
    N1 =:= N2.

test(generate_produces_no_duplicates) :-
    findall(E, generate_equation([1,1,1,1,1], E), L),
    sort(L, U),
    length(L, N1),
    length(U, N2),
    N1 =:= N2.

test(all_equations_in_standard_order) :-
    all_equations([2,2,2,2,2], Es),
    msort(Es, Sorted),
    Es == Sorted.

% ---- canonical parentheses: both 1+(2+3) and 1+2+3 appear when valid ----

test(both_association_forms_left) :-
    all_equations([1,2,3,6], Es),
    memberchk("1+2+3=6", Es),
    memberchk("1+(2+3)=6", Es).

test(both_association_forms_right) :-
    all_equations([6,1,2,3], Es),
    memberchk("6=1+2+3", Es),
    memberchk("6=1+(2+3)", Es).

% ---- every returned equation really has equal sides ----

test(count_matches_all_equations_length) :-
    all_equations([1,2,3,6], Es),
    length(Es, N),
    count_equations([1,2,3,6], N).

:- end_tests(p2).