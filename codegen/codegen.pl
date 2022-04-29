% Askisi 2
% A.M. : 1115201700187
% Χαρίσης Νικόλαος

% Η codegen θα δοκιμασει να λυσει το προβλημα με τη χρηση της solve για ολα τα βαθη (MaxDepth) απο 1 μεχρι και Ν, με αρχικο βαθος (Depth) 0
% Το ! εξασφαλιζει την ευρεση μιας μονο τετοιας λυσης.
codegen(Initial,Final,Result):-
    length(Initial,Size),
    between(1,Size,MaxDepth),
    solve(Initial,Final,Result,0,MaxDepth,Size),
    !.	


% Δεδομενης μιας αρχικης καταστασης (Initial) και μιας τελικης καταστασης (Final) επιστρφει στο Result τα βηματα που απαιτουνται
% Για την μεταπιδηση απο μιας κατασταση σε μια αλλη η solve θα χρησιμοποιησει ειτε την move ειτε την swap.
% Επειδη η solve πρακτικα εκτελει iddfs, το Depth αντιστοιχει στο τρεχον βαθος της αναζητησης ενω το MaxDepth στο μεγιστο επιτρεπτο βαθος
% Επισης, χρησιμοποιει το Size για να διαλεξει I και J που βρισκονται εντος της αρχικης καταστασης αλλα και των επιτρεπτων καταστασεων.
% Λογω του between εχει την δυνατοτητα να επιλεγει ολα τα στοιχεια της λιστας/καταστασης και να δοκιμαζει τις πιθανες κινησεις.
% Για τον τερματισμο γινεται ελεγχος αν μια κατασταση ειναι ιδια με την ζητουμενη τελικη, οποτε και μπαινει στο αποτελεσμα Result η κενη λιστα,
% που δηλωνει το τελος.

solve(Potential,Final,Result,_,_,_):-
	same(Potential,Final),
	append([],[],Result).
solve(Initial,Final,Result,Depth,MaxDepth,Size):-
    NewDepth is Depth+1,                        % θα συνεχιζουμε με μεγαλυτερο βαθος απο οτι στην προηγουμενη κληση
    NewDepth < MaxDepth+1,                      % οσο δεν εχουμε ξεπερασει το επιτρεπτο οριο
    (											% θα κανουμε ειτε swap
    	(between(1,Size,J),						% διαλεγουμε J
    	Size1 is Size-1,
    	between(1,Size1,I),                     % διαλεγουμε Ι
    	I < J,                                  % το swap επιτρεπεται μονο αν I < J
    	swap(I,J,Initial,After),
    	append([swap(I,J)],ThusFar,Result),
    	solve(After,Final,ThusFar,NewDepth,MaxDepth,Size)  % συνεχιζουμε με νεο βαθος μεταφεροντας τα αποτελεσματα που εχουμε ηδη βρει(After/ThusFar)
    	) 
    ;   % ζευξη για να γινει ειτε move(i) ειτε swap(Ι,J)
												% ειτε move    
    	(between(1,Size,I),                     % διαλεγουμε Ι
    	move(I,Initial,After),
    	append([move(I)],ThusFar,Result),
    	solve(After,Final,ThusFar,NewDepth,MaxDepth,Size) % συνεχιζουμε με νεο βαθος μεταφεροντας τα αποτελεσματα που εχουμε ηδη βρει(After/ThusFar)
    	)
    ).

% Εναλλασσει τα στοιχεια I,J που βρισκονται στην ListBefore και επιστρεφει το αποτελεσμα στην ListAfter
% Το συγκεκριμενο swap ειναι πιο γενικου σκοπου μιας και ο ελεγχος για το αν I < J γινεται κατα τη χρηση του απο την
% solve.Θεωρησα αχρηστο να γινεται και στην swap ελεγχος και παρατηρησα οτι για το τελευταιο ερωτημα ειναι ελαφρως πιο γρηγορο να γινεται 
% ελεγχος κατα την κληση της solve απο to να γινεται στην swap.
swap(I,J,ListBefore,ListAfter):-
	get_el_at_pos(I,ListBefore,Xi),         % βρισκει το στοιχειο που αντιστοιχει στην I-οστη θεση (Χi)
	get_el_at_pos(J,ListBefore,Xj),			% βρισκει το στοιχειο που αντιστοιχει στην J-οστη θεση (Χj)
	replace_kth_el(Xi,J,ListBefore,TempList),    % βαζει στην θεση J το Χi
	replace_kth_el(Xj,I,TempList,ListAfter).     % βαζει στην θεση I το Χj


% Μετακινει(συμφωνα με την εκφωνηση) το Ι-οστο στοιχειο της λιστας [Head1|Tail1]  και επιστρεφει το αποτελεσμα στην νεα λιστα [Head2|Tail2]
move(1,[Head,_|Tail],[Head,Head|Tail]).  % η μετακινηση του 1ου στοιχειου (νεα λιστα ιδια με την αρχικη εκτος απο το 2ο στοιχειο)
move(I,[Head1|Tail1],[Head2|Tail2]):-    % η μετακινηση οποιουδηποτε αλλου στοιχειου (στην νεα λιστα τα στοιχεια μεχρι και το Ι θα ειναι ιδια)
	length([Head1|Tail1],Size),
	I < Size,                            
	I1 is I-1,
	Head2=Head1,						% Η νεα λιστα εχει την ιδα κεφαλη
	move(I1,Tail1,Tail2).               % move για Ι-1 στην υπολιστα Tail
move(I,[_|Tail1],[Head|Tail2]):-        % η μετακινηση του τελευταιου στοιχειου (η νεα λιστα θα εχει την ιδια ουρα αλλα διαφορετικη κεφαλη)
	length([_|Tail1],Size),
	I==Size,							% Το Ι ειναι το τελευταιο στοιχειο αν ειναι ισο με το μεγεθος της λιστας/καταστασης 
	Tail2=Tail1,	
	Moved=Head,                         % η νεα κεφαλη ειναι το "μεταφερομενο" στοιχειο
	append(_,[_|[Moved]],Tail1).


% Ελεχγει αν 2 λιστες/καταστασεις ειναι ιδιες λαμβανοντας υπόψιν και την ειδικη σημασια του '*'
same([],[]).                                % 2 κενες λιστες ειναι ιδιες
same([Head1|Tail1],[Head2|Tail2]):-
	(Head2=Head1 ; (Head1=_ , Head2== '*')), % ειτε οι κεφαλες των 2 λιστων πρεπει να ειναι ιδιες ειτε η 2η κεφαλη να ειναι το '*'
	same(Tail1,Tail2).                      % Η ιδια διαδικασια για τις ουρες


% Εκτυπωνει εναν αριθμο αναμεσα στα LBound και RBound. Με more εκτυπωνει ολους αυτους τους αριθμους
between(LBound, RBound, LBound) :-
    LBound =< RBound. 
between(LBound, RBound, Result) :-
    LBound < RBound,
    NextLBound is LBound + 1,
    between(NextLBound, RBound, Result).  


% Επιστρέφει στο Element το στοιχειο που βρισκετατ στην θεση Ι
get_el_at_pos(1,[Element|_],Element).
get_el_at_pos(I,[_|Tail],Element) :- 
	get_el_at_pos(I1,Tail,Element),
	I is I1 + 1 .

% Αντικαθιστα με το Rep το K-οστο στοιχειο της Λιστας [Head|Tail1] και επιστρεφει το αποτελεσμα στην νεα λιστα [Head|Tail1]
replace_kth_el(Rep,1,[_|Tail1],[Rep|Tail1]).
replace_kth_el(Rep,K,[Head|Tail1],[Head|Tail2]):-
	K1 is K-1,
	replace_kth_el(Rep,K1,Tail1,Tail2).

