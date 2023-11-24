play_round(Human, Computer, Board, NextPlayer, WantToContinue):-



make_move(Player, Board, PlayerType, DidWin);-
    [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, PlayerTotalMove] = Player,
    ((PlayerColor = 'W', PlayerTotalMove = 0) ->
        write("Since this is the first move inserting it in the center!"), nl,
       insert_piece(Board, Row, Column, Color, NewBoard),
       set
    )
    ;((PlayerType = 'H' , TotalMove = 1)->
         
    )
    ;(

    )

ask_user_for_move(UserRow, UserColumn) :-
    write("Where do you want to move? Type A1 where A is column and 1 is the row."), nl,
    write("Please make sure that column is capital!"), nl,
    read_line_to_string(user_input, UsrInput), nl,
    % Extracting Row and Column from UsrInput
    convert_row_col(UsrInput, UserRow, UserColumn),
    (
        is_row_column_valid(UserRow, UserColumn, IsValid),
        (
            IsValid = false ->
                write("That place is not valid"), nl,
                ask_user_for_move(UserRow, UserColumn)
            ;
            get_piece(Board, UserRow, UserColumn, BoardItem),
            (
                BoardItem = 'O' ->
                    write("The board is not empty"), nl,
                    ask_user_for_move(UserRow, UserColumn)
                ;
                true
            )
        )
    ).

convert_row_col(UsrInput, UserRow, UserColumn):-
    atom_chars(UsrInput, [ColumnChar | RowChars]),
    char_type(ColumnChar, upper),
    atom_chars(RowAtom, RowChars),
    atom_number(RowAtom, UserRow),
    char_code('A', A),
    char_code(ColumnChar, ColumnCode),
    UserColumn is ColumnCode - A.

ask_user_for_second_move(UserRow, UserColumn) :-
    write("Since this is the second, you must enter 3 intersections away from the center"), nl,
    write("Where do you want to move? Type A1 where A is the column and 1 is the row."), nl,
    write("Please make sure that the column is capitalized!"), nl,
    read_line_to_string(user_input, UsrInput), nl,
    % Extracting Row and Column from UsrInput
    convert_row_col(UsrInput, UserRow, UserColumn),
    (
        is_row_column_valid(UserRow, UserColumn, IsValid),
        (
            IsValid = false ->
                write("That place is not valid"), nl,
                ask_user_for_second_move(UserRow, UserColumn)
            ;
            get_piece(Board, UserRow, UserColumn, BoardItem),
            (
                BoardItem >= 'O' ->
                    write("The board is not empty"), nl,
                    ask_user_for_second_move(UserRow, UserColumn)
                ;
                is_second_position_valid(UserRow, UserColumn, IsSecondPositionValid),
                (
                    IsSecondPositionValid = false ->
                        write("Second position is not valid"), nl,
                        ask_user_for_second_move(UserRow, UserColumn)
                    ;
                    true
                )
            )
        )
    ).

is_second_position_valid(Row, Column, IsSecondPositionValid) :-
    ((Row >= 6, Row =< 12, Column >= 6, Column =< 12) -> IsSecondPositionValid = false;
    IsSecondPositionValid = true).



is_row_column_valid(Row, Column, IsValid) :-
    (Row >= 0, Row < 19, Column >= 0, Column < 19) -> IsValid = true;
    IsValid = false.

setNextPlayer(CurrentPlayer, NewPlayer):-
    (CurrentPlayer = 'H'-> NewPlayer = 'C', true)
    ;
    (NewPlayer = 'H'), true.