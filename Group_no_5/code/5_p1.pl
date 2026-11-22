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

% Clue 5: The friend whose favorite language is Java works in the design department.
% Reads: clue(5, Sol) holds when the friend with language java is in design.
clue(5, Sol) :-
    member(p(_, design, java, _), Sol).

% Clue 6: Carla's project preference is not embedded, and her department is not development.
% Reads: clue(6, Sol) holds when 'Carla' has a project other than embedded and a department other than development.
clue(6, Sol) :-
    member(p('Carla', Dept, _, Proj), Sol),
    Proj \== embedded,
    Dept \== development.

% Clue 7: Dana's favorite language is not Java, and she works in research or testing.
% Reads: clue(7, Sol) holds when 'Dana' has a language other than java and her department is research or testing.
clue(7, Sol) :-
    member(p('Dana', Dept, Lang, _), Sol),
    Lang \== java,
    ( Dept == research ; Dept == testing ).

% Clue 8: The friend who prefers data projects works in research and does not use JavaScript.
% Reads: clue(8, Sol) holds when the friend with project data is in research and their language is not javascript.
clue(8, Sol) :-
    member(p(_, Dept, Lang, data), Sol),
    Dept == research,
    Lang \== javascript.

% satisfies(+Active, +Sol): Sol satisfies every clue whose number is in Active.
% Reads: satisfies(Active, Sol) holds when clue(N, Sol) holds for each N that is a member of Active.
satisfies(Active, Sol) :-
    forall(member(N, Active), clue(N, Sol)).