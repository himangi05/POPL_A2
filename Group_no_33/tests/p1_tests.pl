% Tests for code/33_q1.pl (P1: department puzzle).
% Run from the Group_no_33 folder:
%   swipl -q -f tests/p1_tests.pl -g run_p1_tests -t halt
% The goal run_p1_tests succeeds when every test passes and fails otherwise.

:- use_module(library(plunit)).

% Load the solution file that sits next to this tests folder, wherever swipl is started from.
:- prolog_load_context(directory, Dir),
   atom_concat(Dir, '/../code/33_q1.pl', Code),
   consult(Code).

run_p1_tests :-
    run_tests(p1).

% Every solution of clues 1 to 8, in candidate order.
solutions_1_to_8(Sols) :-
    findall(S, ( candidate(S), satisfies([1,2,3,4,5,6,7,8], S) ), Sols).

:- begin_tests(p1).

% ---------- main/0 output ----------

test(main_output_exact_text) :-
    with_output_to(string(Out), main),
    Out == "Alex = [design, java, embedded]\nBen = [development, javascript, web]\nCarla = [testing, python, AI]\nDana = [research, c++, data]\n".

test(main_prints_exactly_four_lines) :-
    with_output_to(string(Out), main),
    split_string(Out, "\n", "", Parts),
    Parts = [_, _, _, _, ""].              % four lines, then the empty piece after the final newline

test(main_line_order_alex_ben_carla_dana) :-
    with_output_to(string(Out), main),
    split_string(Out, "\n", "", [L1, L2, L3, L4, ""]),
    sub_string(L1, 0, _, _, "Alex = ["),
    sub_string(L2, 0, _, _, "Ben = ["),
    sub_string(L3, 0, _, _, "Carla = ["),
    sub_string(L4, 0, _, _, "Dana = [").

test(main_atoms_are_unquoted) :-
    with_output_to(string(Out), main),
    \+ sub_string(Out, _, _, _, "'").       % no quotes anywhere, so 'c++' and 'AI' print bare

test(main_solution_satisfies_clues_1_to_8) :-
    % main prints the first solution that satisfies clues 1 to 9, which also satisfies 1 to 8
    candidate(S),
    satisfies([1,2,3,4,5,6,7,8,9], S),
    !,
    satisfies([1,2,3,4,5,6,7,8], S).

% ---------- count_solutions/2 ----------

test(count_clues_1_to_8_is_3) :-
    count_solutions([1,2,3,4,5,6,7,8], N),
    N == 3.

test(count_clues_1_to_9_is_1) :-
    count_solutions([1,2,3,4,5,6,7,8,9], N),
    N == 1.

% ---------- clue 9 ----------

test(clue9_false_in_every_other_solution_of_1_to_8) :-
    solutions_1_to_8(Sols),
    include([S]>>(\+ clue(9, S)), Sols, Others),
    length(Others, 2).                     % two of the three solutions fail clue 9

test(clue9_true_in_exactly_one_solution_of_1_to_8) :-
    solutions_1_to_8(Sols),
    include([S]>>clue(9, S), Sols, Kept),
    length(Kept, 1).

test(clue9_true_in_the_kept_solution) :-
    Kept = [ p('Alex',design,java,embedded),
             p('Ben',development,javascript,web),
             p('Carla',testing,python,'AI'),
             p('Dana',research,'c++',data) ],
    once(clue(9, Kept)).

% ---------- edge cases ----------

test(empty_active_list_gives_all_13824_candidates) :-
    count_solutions([], N),
    N == 13824.

test(empty_active_list_satisfied_by_any_candidate) :-
    once(( candidate(S), satisfies([], S) )).

test(single_clue_3_alone) :-
    count_solutions([3], N),
    N == 3456.

test(single_clue_5_alone) :-
    count_solutions([5], N),
    N == 3456.

test(repeated_clue_numbers_do_not_change_the_count) :-
    count_solutions([1,2], A),
    count_solutions([1,1,2,2,1], B),
    A == B.

test(order_of_clue_numbers_does_not_matter) :-
    count_solutions([8,7,6,5,4,3,2,1], A),
    count_solutions([1,2,3,4,5,6,7,8], B),
    A == B.

test(nonexistent_clue_number_gives_zero_solutions) :-
    count_solutions([42], N),
    N == 0.

test(nonexistent_clue_makes_clue_fail, [fail]) :-
    candidate(S),
    clue(42, S).

test(nonexistent_clue_among_real_ones_gives_zero) :-
    count_solutions([1,2,3,99], N),
    N == 0.

test(candidate_has_four_friends_in_order) :-
    candidate([p(A,_,_,_), p(B,_,_,_), p(C,_,_,_), p(D,_,_,_)]),
    [A,B,C,D] == ['Alex','Ben','Carla','Dana'],
    !.

:- end_tests(p1).