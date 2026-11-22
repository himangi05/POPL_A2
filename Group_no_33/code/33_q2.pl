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

% generate_equation(+List, -Equation): Equation is a string "L=R" where L and R are expressions over a split of List into two consecutive non-empty parts, with equal values.
% Reads: generate_equation(List, Equation) holds when List splits into non-empty Left and Right, some tree over Left and some tree over Right have the same value, and Equation is the text of the left tree, "=", and the text of the right tree.
generate_equation(List, Equation) :-
    append(Left, Right, List),
    Left = [_|_],
    Right = [_|_],
    expr(Left, LeftTree, Value),
    expr(Right, RightTree, Value),
    tree_string(LeftTree, LeftString),
    tree_string(RightTree, RightString),
    format(string(Equation), "~w=~w", [LeftString, RightString]).

% all_equations(+List, -Equations): Equations is the sorted, duplicate-free list of every valid equation string for List.
% Reads: all_equations(List, Equations) holds when Equations is the sort/2 of all strings E for which generate_equation(List, E) holds, and is [] when there are none.
all_equations(List, Equations) :-
    findall(Equation, generate_equation(List, Equation), Found),
    sort(Found, Equations).

% count_equations(+List, -N): N is the number of distinct valid equations for List.
% Reads: count_equations(List, N) holds when N is the length of the list that all_equations/2 gives for List.
count_equations(List, N) :-
    all_equations(List, Equations),
    length(Equations, N).