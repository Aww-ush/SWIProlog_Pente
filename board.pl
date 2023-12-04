% Predicates for board creation

create_row(0, []).
create_row(N, ['o' | Rest]) :-
    N > 0,
    N1 is N - 1,
    create_row(N1, Rest).

create_board_row(0, []).
create_board_row(N, [Row | Rest]) :-
    N > 0,
    N1 is N - 1,
    create_row(19, Row),
    create_board_row(N1, Rest).

get_empty_board(Board) :-
    create_board_row(19, Board).

print_row([]) :-
    nl. % Newline for the end of row
print_row([X | Rest]) :-
    write(X), % Print the element
    write(' '), % Space between elements for better readability
    print_row(Rest).

print_column_index(0).
print_column_index(N) :-
    N > 0,
    char_code('A', A),
    Code is A + 19 - N,
    char_code(ColumnChar, Code),
    write(ColumnChar),
    write(' '),
    N1 is N - 1,
    print_column_index(N1).

print_board([], 0).
print_board([Row | Rest], N) :-
    N > 0,
    write(N), % Print the row number
    (N < 10 -> write('   '); write('  ')), % Adjust spacing for single-digit row numbers
    print_row(Row),
    nl, % Newline for the end of row
    N1 is N - 1,
    print_board(Rest, N1).
print_board_with_index(Board1, N):-
    write('    '),
    print_column_index(19),
    nl,
    print_board(Board1, N).


get_piece(Board, Row, Column, Piece) :-

    nth0(Row, Board, RequiredRow),
    nth0(Column, RequiredRow, Piece).
   
insert_piece(Board, Row, Column, Color, InserBoard):-
    nth0(Row, Board, OldRow),
    replace_column(OldRow, Column, Color, NewRow),
    replace_row(Board, Row, NewRow, InserBoard).

replace_column(OldRow, Index, Value, NewRow):-
    nth0(Index, OldRow, _, Temp),
    nth0(Index, NewRow, Value, Temp).

replace_row(Board, Index, NewRow, NewBoard) :-
    nth0(Index, Board, _, Temp),
    nth0(Index, NewBoard, NewRow, Temp).

is_place_empty(Board, Row, Column):-
    get_piece(Board, Row, Column, Piece),
    (Piece = 'o' ->
        true
    ;
        false
    ).
get_opposite_color(Color, OppositeColor):-
    (Color == 'w' -> OppositeColor = 'b');
    OppositeColor = 'w'.
