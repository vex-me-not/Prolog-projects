% Άσκηση 7
% Χαρίσης Νικόλαος
% 1115201700187


:- set_flag(print_depth, 1000).

:- lib(ic).
:- lib(ic_global).
:- lib(branch_and_bound).

% Flavour text κατα κύριο λόγο
tents([],_,_,[]):- 
  write('The list RowTents is EMPTY. Please give a non-empty list!'),
  nl,
  !.
tents(_,[],_,[]):- 
  write('The list ColumnTents is EMPTY. Please give a non-empty list!'),
  nl,
  !.
tents(_,_,[],[]):- 
  write('The list Trees is EMPTY. Please give a non-empty list!'),
  nl,
  !.    
tents(RowTents,ColumnTents,Trees,Tents) :-
  length(RowTents,RowNum),
  length(ColumnTents,ColNum),
  AllVariables is RowNum*ColNum,
  def_vars(XiVariables,AllVariables), % οι μεταβλητες που θα χρησιμοποιήσουμε για να βρουμε μια λύση ελαχίστου κόστους
  state_constrs(RowTents,RowNum,ColumnTents,ColNum,Trees,XiVariables), % Οι περιορισμοι που θα εφαρμοστούν σε αυτές τις μεταβλητες
  Cost #= sum(XiVariables), % Σαν κοστος θεωρούμε το αθροισμα
  !,
  bb_min(search(XiVariables,0,input_order,indomain,complete,[]),Cost,_), % κανουμε branch_and_bound
  other_def_vars(OtherXi,AllVariables),                     % Οριζουμε τις μεταβλητες που θα χρησιμοποησουμε για να βρουμε τις υπολοιπες λυσεις
  state_constrs(RowTents,RowNum,ColumnTents,ColNum,Trees,OtherXi), % Ιδιοι περιορισμοι με τους αρχικους
  Cost #= sum(OtherXi),  % Ιδια συναρτηση κοστους απλα για τις μεταβλητες OtherXi
  !,
  search(OtherXi,0,input_order,indomain,complete,[]), % Ξεκιναμε την αναζητηση
  transcribe(OtherXi,ColNum,Tents).  % Μετασχηματιζουμε την λυση μας

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Μεταβλητές %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Οι μεταβλητές
def_vars(XiVariables,N) :-
  length(XiVariables,N),    % λίστα με n Χi μεταβλητές
  XiVariables #:: [0,1].    % ορισμός του domain των Xi

% Οι μεταβλητες που χρησιμοποιουνται για την αναζητηση των αλλων λυσεων
other_def_vars(XiVariables,N) :-
  length(XiVariables,N),    % λίστα με n Χi μεταβλητές
  XiVariables #:: [0,1].    % ορισμός του domain των Xi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Περιορισμοι %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Οι περιορισμοι του προβληματος
state_constrs(RowTents,RowNum,ColumnTents,ColNum,Trees,XiVariables) :-
  rows_state_constrs(RowTents,ColNum,1,XiVariables), % περιορισμοι για τις γραμμες
  columns_state_constrs(ColumnTents,ColNum,RowNum,1,XiVariables), % περιορισμοι για τις στηλες
  trees_state_constrs(RowNum,ColNum,Trees,XiVariables), % περιορισμοι απο τα δεντρα
  tents_state_constrs(RowNum,ColNum,1,XiVariables,XiVariables). % περιορισμοι για τις τεντες

% Ο περιορισμος για μια σειρα
rows_state_constrs([],_,_,_).
rows_state_constrs([HeadRow|TailRow],ColNum,Pos,XiVariables) :-
  HeadRow >= 0,       % οι περιορισμοι ισχυουν αν ο αριθμος αυτος δεν ειναι αρνητικος
  ith_row_values(Pos,ColNum,XiVariables,Values),
  HeadRow #>= sum(Values),
  NewPos is Pos+1,
  rows_state_constrs(TailRow,ColNum,NewPos,XiVariables).
rows_state_constrs([HeadRow|TailRow],ColNum,Pos,XiVariables) :-
  HeadRow < 0, % αν εχουμε αρνητικο αριθμο δεν υπαρχει περιορισμος και συνεχιζουμε στην επομενη σειρα
  NewPos is Pos+1,
  rows_state_constrs(TailRow,ColNum,NewPos,XiVariables).


% Ο περιορισμος για μια στηλη
columns_state_constrs([],_,_,_,_).
columns_state_constrs([HeadCol|TailCol],ColNum,RowNum,Pos,XiVariables) :-
  HeadCol >= 0,     % για να υπαρχουν περιορισμοι πρεπει να ειναι θετικο
  ith_col_values(Pos,ColNum,RowNum,XiVariables,Values),
  HeadCol #>= sum(Values),
  NewPos is Pos+1,
  columns_state_constrs(TailCol,ColNum,RowNum,NewPos,XiVariables).
columns_state_constrs([HeadCol|TailCol],ColNum,RowNum,Pos,XiVariables) :-
  HeadCol < 0,     % αν εχουμε αρνητικο αριθμο δεν υπαρχει περιορισμος και συνεχιζουμε στην επομενη στηλη
  NewPos is Pos+1,
  columns_state_constrs(TailCol,ColNum,RowNum,NewPos,XiVariables).


% Ο περιορισμος για τις τεντες
tents_state_constrs(_,_,_,[_],_).  % σταματαμε αν ειμαστε στο τελευταιο στοιχειο
tents_state_constrs(RowNum,ColNum,Pos,[HeadTents|TailTents],XiVariables) :-
  ith_tent_neighbours(Pos,ColNum,RowNum,XiVariables,TentNeighboursList),
  1 #>= sum(TentNeighboursList)+HeadTents, % 2 τέντες δεν πρέπει να βρισκονται σε γειτονικές θέσεις
  NewPos is Pos+1,
  tents_state_constrs(RowNum,ColNum,NewPos,TailTents,XiVariables).


% Ο περιορισμος για το δεντρα
trees_state_constrs(_,_,[],_).
trees_state_constrs(RowNum,ColNum, [TreeX - TreeY|RestTrees], XiVariables) :-
  Pos is (ColNum*(TreeX-1))+TreeY,  %  Η θεση του δεντρου
  n_th(Pos,XiVariables,Value),
  Value #= 0,        % δεν μπορει να υπαρχει τεντα σε θεση που υπαρχει δεντρο
  ith_tree_neighbours(Pos,ColNum,RowNum,XiVariables,TreeNeighboursList),
  1 #=< sum(TreeNeighboursList), % Ενα δεντρο πρεπει να γειτνιαζει με τουλαχιστον μια τεντα
  trees_state_constrs(RowNum,ColNum,RestTrees,XiVariables).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Στοιχεια Γραμμων και Στηλων %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% παιρνουμε τα στοιχεια μιας γραμμης
ith_row_values(Pos,ColNum,XiVariables,Values) :-
  Low is ((Pos-1)*ColNum)+1,
  High is Low+(ColNum-1),
  ith_row_values(Low,High,Low,XiVariables,Values).
ith_row_values(_,High,High,XiVariables,[Value]) :-
  n_th(High,XiVariables,Value).
ith_row_values(Low,High,Pos,XiVariables,[Value|RestValues]) :-
  n_th(Pos,XiVariables,Value),
  NewPos is Pos+1,
  ith_row_values(Low,High,NewPos,XiVariables,RestValues).


% παιρνουμε τα στοιχεια μιας στηλης
ith_col_values(Pos,ColNum,RowNum,XiVariables,Values) :-
  Low is Pos,
  High is Low+((RowNum-1)*ColNum),
  ith_col_values(ColNum,Low,High,Low,XiVariables,Values).
ith_col_values(_,_,High,High,XiVariables,[Value]) :-
  n_th(High,XiVariables,Value).
ith_col_values(ColNum,Low,High,Pos,XiVariables,[Value|RestValues]) :-
  n_th(Pos,XiVariables,Value),
  NewPos is Pos+ColNum,
  ith_col_values(ColNum,Low,High,NewPos,XiVariables,RestValues).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Γείτονες %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tα *_neighbour επιστρεφουν μια λιστα με ενα μονο στοιχειο το οποιο ειναι ο * γειτονας του Pos
% O λόγος που επιστρέφουν τον γείτονα σε λιστα οφειλεται στο γεγονός οτι με αυτόν τον τρόπο εκφράζονται πιο ευκολα οι edge cases
% (π.χ. Tα στοιχεια που βρίσκονται στην 1η γραμμή δεν έχουν upper left,upper right και upper γειτονες, οποτε θα παρουμε την κενη λιστα)  

% Παιρνουμε τους "γειτονες" του ι-οστου δεντρου ξεκινοντας απο την πανω αριστερα γωνια και συνεχίζουμε δεξιοστροφα
ith_tree_neighbours(Pos,ColNum,RowNum,XiVariables,TreeNeighboursList) :-
  ul_neighbour(Pos,ColNum,XiVariables,Ul), % upper left neighbour
  append([],Ul,Temp1),
  u_neighbour(Pos,ColNum,XiVariables,U), % upper neighbour
  append(Temp1,U,Temp2),
  ur_neighbour(Pos,ColNum,XiVariables,Ur), % upper right neighbour
  append(Temp2,Ur,Temp3),
  r_neighbour(Pos,ColNum,XiVariables,R), % right neighbour
  append(Temp3,R,Temp4),
  lr_neighbour(Pos,ColNum,RowNum,XiVariables,Lr), % lower right neighbour
  append(Temp4,Lr,Temp5),
  lo_neighbour(Pos,ColNum,RowNum,XiVariables,Lo), % lower neighbour
  append(Temp5,Lo,Temp6),
  ll_neighbour(Pos,ColNum,RowNum,XiVariables,Ll), % lower left neighbour
  append(Temp6,Ll,Temp7),
  le_neighbour(Pos,ColNum,XiVariables,Le), % left neighbour
  append(Temp7,Le,TreeNeighboursList). % Η λιστα με ολους τους γειτονες


% Παιρνουμε τους "γειτονες" της  ι-οστης σκηνης
ith_tent_neighbours(Pos,ColNum,RowNum,XiVariables,TentNeighboursList) :-
  r_neighbour(Pos,ColNum,XiVariables,R), % right neighbour
  append([],R,Temp1),
  lr_neighbour(Pos,ColNum,RowNum,XiVariables,Lr), % lower right neighbour
  append(Temp1,Lr,Temp2),
  lo_neighbour(Pos,ColNum,RowNum,XiVariables,Lo), % lower neighbour
  append(Temp2,Lo,TentNeighboursList). % Η λιστα με ολους τους γειτονες


% left neighbour του στοιχειου Pos
le_neighbour(Pos,ColNum,_,[]) :-
  1 is mod(Pos,ColNum).  % τα στοιχεια της πρωτης στηλης δεν εχουν left neighbour
le_neighbour(Pos,_,XiVariables,Le) :-
  NeighPos is Pos-1, 
  n_th(NeighPos, XiVariables, Value),
  append([], [Value], Le).


% right neighbour του στοιχειου Pos
r_neighbour(Pos,ColNum,_,[]) :-
  0 is mod(Pos,ColNum).   % τα στοιχεια της τελευταιας στηλης δεν εχουν right neighbour
r_neighbour(Pos,_,XiVariables,R) :- % εδω χρεαιζομαστε μονο το Pos για να βρουμε τη θεση του γειτονα
  NeighPos is Pos+1,
  n_th(NeighPos,XiVariables,Value),
  append([],[Value],R).


% upper neighbour του στοιχειου Pos
u_neighbour(Pos,ColNum,_,[]) :-
  Pos =< ColNum.  % τα στοιχεια της πρωτης γραμμης δεν εχουν upper neighbour
u_neighbour(Pos,ColNum,XiVariables,U) :-
  NeighPos is Pos-ColNum,
  n_th(NeighPos,XiVariables,Value),
  append([],[Value],U).


% lower neighbour του στοιχειου Pos
lo_neighbour(Pos,ColNum,RowNum,_,[]) :-
  Pos > (ColNum*RowNum)-ColNum.  % τα στοιχεια της τελευταιας γραμμης δεν εχουν lower  neighbour
lo_neighbour(Pos,ColNum,_,XiVariables,Lo) :-
  NeighPos is Pos+ColNum,
  n_th(NeighPos,XiVariables,Value),
  append([],[Value],Lo).


% upper right neighbour του στοιχειου Pos
ur_neighbour(Pos,ColNum,_,[]) :-
  Pos =< ColNum.  % τα στοιχεια της πρωτης γραμμης δεν εχουν upper right neighbour
ur_neighbour(Pos,ColNum,_,[]) :-
  0 is mod(Pos,ColNum).   % τα στοιχεια της τελευταιας στηλης δεν εχουν upper right neighbour
ur_neighbour(Pos,ColNum,XiVariables,Ur) :-
  NeighPos is Pos-ColNum+1,
  n_th(NeighPos,XiVariables,Value),
  append([],[Value],Ur).


% lower right neighbour του στοιχειου Pos
lr_neighbour(Pos,ColNum,RowNum,_,[]) :-
  Pos > (RowNum*ColNum)-ColNum. % τα στοιχεια της τελευταιας γραμμης δεν εχουν lower right neighbour
lr_neighbour(Pos,ColNum,_,_,[]) :-
  0 is mod(Pos,ColNum).   % τα στοιχεια της τελευταιας στηλης δεν εχουν lower right neighbour
lr_neighbour(Pos,ColNum,_,XiVariables,Lr) :-
  NeighPos is Pos+ColNum+1,
  n_th(NeighPos,XiVariables,Value),
  append([],[Value],Lr).


% upper left neighbour του στοιχειου Pos
ul_neighbour(Pos,ColNum,_,[]) :- % isos thelei allagi an den doyleyei
  Pos =< ColNum.  % τα στοιχεια της πρωτης γραμμης δεν εχουν upper left neighbour
ul_neighbour(Pos,ColNum,_,[]) :-
  1 is mod(Pos,ColNum).  % τα στοιχεια της πρωτης στηλης δεν εχουν upper left neighbour
ul_neighbour(Pos,ColNum,XiVariables,Ul) :-
  NeighPos is Pos-ColNum-1, % η θεση του upper left neighbour
  n_th(NeighPos,XiVariables,Value),
  append([],[Value],Ul).


% lower left neighbour του στοιχειου Pos
ll_neighbour(Pos,ColNum,_,_,[]) :-
  1 is mod(Pos,ColNum).  % τα στοιχεια της πρωτης στηλης δεν εχουν lower left neighbour
ll_neighbour(Pos,ColNum,RowNum,_,[]) :-
  Pos > (ColNum*RowNum)-ColNum.  % τα στοιχεια της τελευταιας γραμμης δεν εχουν lower left neighbour
ll_neighbour(Pos,ColNum,_,XiVariables,Ll) :-
  NeighPos is Pos+ColNum-1,
  n_th(NeighPos,XiVariables,Value),
  append([],[Value],Ll).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Γενικά %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Μετατρεπουμε τη λιστα των μεταβλητων Xi
transcribe(XiVariables,ColNum,Tents) :-
  transcribe(XiVariables,1,ColNum,Tents).
transcribe([],_,_,[]).
transcribe([Head|Tail],Pos,ColNum,Tents) :-
  Head =:= 1,
  Column is mod(Pos-1,ColNum) + 1,
  Row is div(Pos-1,ColNum) + 1,
  NewPos is Pos +1,
  transcribe(Tail,NewPos,ColNum,TailTents),
  append([Row - Column],TailTents, Tents).
transcribe([Head|Tail],Pos,ColNum,Tents) :-
  Head =:= 0,
  NewPos is Pos + 1,
  transcribe(Tail,NewPos,ColNum,Tents).  

% Επιστρεφει στο Node το ν-οστο στειχειο της λιστας(απο προηγουμενες ασκήσεις)
n_th(1,[Node| _],Node).
n_th(N,[_| Nodes],Node) :-
  N \= 1,
  N1 is N - 1,
  n_th(N1,Nodes,Node). 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
