% Άσκηση 6
% Χαρίσης Νικόλαος
% 1115201700187


:- set_flag(print_depth, 1000).

:- lib(ic).
:- lib(ic_global).
:- lib(branch_and_bound).

% Τα αρχεια carseq_data1.pl,carseq_data2.pl,carseq_data3.pl,carseq_data4.pl πρεπει να βρισκονται στον ιδιο φακελο με το carseq.pl
% Για διαφορετικα δεδομένα αρκεί απλώς να σχολιασουμε και να αποσχολιασουμε αντίστοιχα τα παρακατω import.


 :- [carseq_data1].
% :- [carseq_data2].
% :- [carseq_data3].
% :- [carseq_data4].

carseq(S):-
	classes(Configurations),
	TotalCars #= sum(Configurations), % Ολα τα αμαξια που θα φτιαξουμε
	length(Configurations,Total), % Το πληθος των Configurations ειναι Total
	def_vars(XiVariables,TotalCars,Total), % Αντιστοιχουμε σε καθε αμαξι μια μεταβλητη που παιρνει τιμες απο 1 μεχρι και Total
	first_state_constrs(1,Configurations,XiVariables,Total), % Ο 1ος περιορισμός για τις μεταβλητες
	options(Options),
	second_state_constrs(Options,Configurations,XiVariables), % Ο 2ος περιορισμός για τις μεταβλητες
	search(XiVariables,0,input_order,indomain,complete,[]), % search όπως προτεινεται στο βιβλιο,
	append([],XiVariables,S). % Το τελικο αποτέλεσμα



% Ορίζουμε τις μεταβλητές
def_vars(XiVariables,N,Max):-
	length(XiVariables,N),  % Δημιουργουμε Ν μεταβλητες. Στην δική μας περιπτωση το Ν ισουται με το πληθος των αμαξιων προς κατασκευη
	XiVariables #:: 1..Max. % Οι τιμες των μεταβλητών κυμαινονται ο 1 μεχρι και το πληθος ολων των Configurations

% Ο 1ος περιορισμός για τις μεταβλητές
first_state_constrs(I,[App],XiVariables,M) :-
	I =:= M,
	occurrences(M,XiVariables,App).
first_state_constrs(I,[App|RestApp],XiVariables,M) :-
	I < M,
	occurrences(I,XiVariables,App),
	NextI is I + 1,
	first_state_constrs(NextI,RestApp,XiVariables,M).

% Ο 2ος περιορισμός για τις μεταβλητές
second_state_constrs([],_,_).
second_state_constrs([ I/J/List | Rest],Configurations,XiVariables):-
	transcribe(List,Transcribed),              % μεταφραζουμε την λιστα του Option
	product(Configurations,List,Product),     % Με βαση το List , κραταμε ποσα αυτοκινητα απο καθε Config θα κατασκευαστουν
	Total #= sum(Product), % Ποσα αυτοκινητα θα κατασκευαστουν σε ολη την λιστα
	sequence_total(Total,Total,0,J,I,XiVariables,Transcribed), 
	second_state_constrs(Rest,Configurations,XiVariables).


% Πρακτικά η πράξη .* της Matlab. Πολλαπλασιαζει το ι-οστο στοιχειο της 1ης λιστας με το ι-οστο στοιχειο της 2ης λιστας και επιστρεφει το αποτέλεσμα 
%  στην ι-οστη θέση της 3ης λιστας.

product(XiVariables,BinVariables,Result):-
	product(XiVariables,BinVariables,[],Result).

product([],[],ThusFar,Result):-
	append(ThusFar,[],Result).
product([XiHead|XiRest],[BinHead|BinRest],ThusFar,Result):-
	ThusFar == [],
	Prod is XiHead * BinHead,
	append(ThusFar,[Prod],NewThusFar),
	product(XiRest,BinRest,NewThusFar,Result).
product([XiHead|XiRest],[BinHead|BinRest],ThusFar,Result):-
	ThusFar \= [],
	Prod is XiHead * BinHead,
	append(ThusFar,[Prod],NewThusFar),
	product(XiRest,BinRest,NewThusFar,Result).



% Η transcribe της maxclq
transcribe(XiVariables,Clique) :-
  	transcribe(XiVariables,1,Clique). % Ξεκινάμε απο το 1ο στοιχειο της XiVariables

transcribe([],_,[]). % μια κενη λίστα μετατρέπεται στην κενή λιστα
transcribe([Head|Tail],Num,Clique) :-
  	Head == 1,   % αν η κεφαλη ειναι 1
  	Num1 is Num+1,
  	transcribe(Tail,Num1,Clq),
  	append([Num],Clq,Clique), % το Num μπαινει στην λιστα
  	!.
transcribe([_|Tail],Num,Clique) :-
	Num1 is Num+1,
  	transcribe(Tail,Num1,Clique).

