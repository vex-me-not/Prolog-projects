

genrand(N, List) :-
	length(List, N),
	make_list(N, List).


make_list(_, []).
make_list(N, [X|List]) :-
	random(R),
	X is R mod (N+1),
	make_list(N, List).