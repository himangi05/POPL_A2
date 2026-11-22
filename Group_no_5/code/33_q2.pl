:- use_module(library(lists)).

% expr(+Nums, -Tree, -Value): generates, on backtracking, every expression tree over Nums (in order) and its integer value.
% Reads: expr(Nums, Tree, Value) holds when Tree is an expression over the non-empty list Nums, with the numbers in order, and Value is its value.
expr([N], num(N), N).
expr(Nums, op(Op, L, R), Value) :-
    append([A|As], [B|Bs], Nums),
    expr([A|As], L, LeftValue),
    expr([B|Bs], R, RightValue),
    apply_op(Op, LeftValue, RightValue, Value).

% apply_op(?Op, +X, +Y, -V): V is X Op Y; division succeeds only when Y is not zero and the division is exact.
% Reads: apply_op(Op, X, Y, V) holds when V = X Op Y, and for Op = / also Y =\= 0 and X is divisible by Y.
apply_op(+, X, Y, V) :- V is X + Y.
apply_op(-, X, Y, V) :- V is X - Y.
apply_op(*, X, Y, V) :- V is X * Y.
apply_op(/, X, Y, V) :- Y =\= 0, X mod Y =:= 0, V is X // Y.