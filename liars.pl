% Άσκηση 5
% Χαρίσης Νικόλαος
% 1115201700187
% To genrand.pl πρέπει να είναι στον ίδιο φάκελο με το liars.pl

:- set_flag(print_depth, 1000).

:- [genrand].
:- lib(ic).
:- lib(branch_and_bound).

liars([],[]):-   % μια κενη λιστα απο φιλους πρεπει να επιστρεφει μια κενη λιστα
	write('Empty list of friends was given! Please try a different list!'),
	write('\n'),
	!. 
liars(Friends,Liars):-
	length(Friends,Total),		% το πληθος των φιλων,το χρειαζομαστε για τις Xi μεταβλητές
	def_vars(XiVariables,Total), % οριζουμε τις μεταβλητες
	state_constrs(XiVariables,Friends), % οριζουμε τους περιορισμους
	search(XiVariables,0,input_order,indomain,complete,[]), % search όπως προτεινεται στο βιβλιο
	append([],XiVariables,Liars).       % επιστρεφουμε την λυση στο Liars

 
% Οι μεταβλητές
def_vars(XiVariables,N):-
	length(XiVariables,N), 		% λίστα με n Χi μεταβλητές
	XiVariables #:: [0,1]. 		% ορισμός του domain των Xi

% Οι περιορισμοι
state_constrs(XiVariables,Friends) :-
	Liars #= sum(XiVariables), % Το συνολο των ψευτων ισουται με το αθροισμα των Xi
	constrs(Friends,XiVariables,Liars).  % Οι περιορισμοι που πρεπει να εχουν τα Xi με βαση το τι ειπε καθε φιλος και το πληθος των ψευτων

constrs([],[],_).
constrs([HeadFriend|TailFriend],[HeadXi|TailXi],Liars):-
	HeadXi #= (HeadFriend #> Liars),  	% Αν ο Ι-οστος φιλος λεει ψεματα, τοτε οι ψευτες ειναι λιγοτεροι απο αυτους που δηλωνει
	constrs(TailFriend,TailXi,Liars).	% Συνεχιζουμε με τους υπολοιπους