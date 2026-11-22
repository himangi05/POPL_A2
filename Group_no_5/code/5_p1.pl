% candidate(-Sol): generates every assignment of departments, languages and projects to the four friends.
% Reads: Sol is a list [p('Alex',D1,L1,P1), p('Ben',D2,L2,P2), p('Carla',D3,L3,P3), p('Dana',D4,L4,P4)]
% where [D1,D2,D3,D4] is a permutation of the departments, [L1,L2,L3,L4] a permutation of the
% languages and [P1,P2,P3,P4] a permutation of the projects, so each value is used exactly once.
candidate([p('Alex',D1,L1,P1), p('Ben',D2,L2,P2), p('Carla',D3,L3,P3), p('Dana',D4,L4,P4)]) :-
    permutation([research,development,design,testing], [D1,D2,D3,D4]),
    permutation([python,java,'c++',javascript], [L1,L2,L3,L4]),
    permutation(['AI',web,embedded,data], [P1,P2,P3,P4]).

% Clue 1: The friend who prefers the AI project does not work in research and is not Dana.
% Reads: clue(1, Sol) holds when the friend with project 'AI' is not in research and is not 'Dana'.
clue(1, Sol) :-
    member(p(Name, Dept, _, 'AI'), Sol),
    Dept \== research,
    Name \== 'Dana'.

% Clue 2: Alex does not work in development and does not prefer C++.
% Reads: clue(2, Sol) holds when 'Alex' is not in development and his language is not 'c++'.
clue(2, Sol) :-
    member(p('Alex', Dept, Lang, _), Sol),
    Dept \== development,
    Lang \== 'c++'.

% Clue 3: The friend working in the testing department likes Python.
% Reads: clue(3, Sol) holds when the friend in testing has language python.
clue(3, Sol) :-
    member(p(_, testing, python, _), Sol).

% Clue 4: Ben prefers web projects and does not work in testing.
% Reads: clue(4, Sol) holds when 'Ben' has project web and his department is not testing.
clue(4, Sol) :-
    member(p('Ben', Dept, _, web), Sol),
    Dept \== testing.