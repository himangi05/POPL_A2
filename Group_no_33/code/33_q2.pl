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

% tree_string(+Tree, -String): String is the canonical, space-free text of the expression Tree, as an SWI-Prolog string.
% Reads: tree_string(Tree, String) holds when String is the number for num(N), or the left text, the operator and the right text joined, with operands parenthesised by the canonical rule.
tree_string(num(N), String) :-
    format(string(String), "~w", [N]).
tree_string(op(Op, L, R), String) :-
    op_prec(Op, Prec),
    operand_string(left, Prec, L, LeftString),
    operand_string(right, Prec, R, RightString),
    format(string(String), "~w~w~w", [LeftString, Op, RightString]).

% operand_string(+Side, +ParentPrec, +Tree, -String): String is the text of an operand, wrapped in parentheses when its position requires it.
% Reads: operand_string(Side, ParentPrec, Tree, String) holds when String is the text of Tree, in parentheses exactly when needs_parens/3 holds for Side, ParentPrec and Tree.
operand_string(Side, ParentPrec, Tree, String) :-
    tree_string(Tree, Inner),
    (   needs_parens(Side, ParentPrec, Tree)
    ->  format(string(String), "(~w)", [Inner])
    ;   String = Inner
    ).

% needs_parens(+Side, +ParentPrec, +Tree): an operand needs parentheses, by the left and right operand rules.
% Reads: needs_parens(Side, ParentPrec, Tree) holds when Tree is an operation whose precedence is lower than ParentPrec on the left side, or lower than or equal to ParentPrec on the right side.
needs_parens(left, ParentPrec, op(Op, _, _)) :-
    op_prec(Op, Prec),
    Prec < ParentPrec.
needs_parens(right, ParentPrec, op(Op, _, _)) :-
    op_prec(Op, Prec),
    Prec =< ParentPrec.

% op_prec(+Op, -Prec): Prec is the binding strength of Op, where a larger number binds tighter.
% Reads: op_prec(Op, Prec) holds when Prec is 1 for + and -, and 2 for * and /.
op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).