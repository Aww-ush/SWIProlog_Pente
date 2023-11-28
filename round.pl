play_round(Human, Computer, Board, NextPlayer, "N", ResultBoard) :-
    ResultBoard = Board.

play_round(Human, Computer, Board, NextPlayer, "Y", ResultBoard) :-
    (NextPlayer = "H") ->
    (
        make_move(Human, Board, "H", DidWin, ResultBoard, NewPlayer),
        print_current_status(NewPlayer, Computer, ResultBoard),
        does_user_want_to_continue(Result),
        write(NewPlayer),nl,
        play_round(NewPlayer, Computer, ResultBoard, "C", "Y", NewResultBoard)
    )
    ;
    (NextPlayer = "C") ->
    (
        [PlayerColor | _] = Computer,
        insert_piece(Board, 0, 0, PlayerColor, NewBoard),
        print_current_status(Human, Computer, NewBoard),
        write("Do you want to continue?"),
        boolean_question(Result),
        play_round(Human, Computer, NewBoard, "H", Result, FinalResultBoard)
    ).


make_move(Player, Board, PlayerType, DidWin, NewBoard, NewPlayer) :-
    Player = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, PlayerTotalMove],
    (PlayerType == "H") ->(
         write("Human`s move"),nl,
        (PlayerColor == 'W', PlayerTotalMove = 0) ->
            write("Since this is the first move, inserting it in the center!"), nl,
            insert_piece(Board, 9, 9, PlayerColor, NewBoard),
            NewPlayerMove is (PlayerTotalMove + 1),
            NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, NewPlayerMove]
        ;

        (PlayerColor == 'W', PlayerTotalMove = 1) ->
            ask_user_for_second_move(UserRow, UserColumn),
            insert_piece(Board, UserRow, UserColumn, PlayerColor, NewBoard),
            NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, PlayerTotalMove + 1]

        ;
       
        ask_user_for_move(UserRow, UserColumn),
        insert_piece(Board, UserRow, UserColumn, PlayerColor, NewBoard),
        NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, PlayerTotalMove + 1]

    );
    (PlayerType == "C") -> (
         write("Computer`s move"),nl,
         (PlayerColor = 'W', PlayerTotalMove = 0) ->
            write("Since this is the first move, inserting it in the center!"), nl,
            insert_piece(Board, 9, 9, PlayerColor, NewBoard),
            NewPlayerMove is (PlayerTotalMove + 1),
            NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, NewPlayerMove]
        ;

        (PlayerColor = 'W', PlayerTotalMove = 1) ->
            ask_user_for_second_move(UserRow, UserColumn),
            insert_piece(Board, UserRow, UserColumn, PlayerColor, NewBoard),
            NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, PlayerTotalMove + 1]

        ;
       
        ask_user_for_move(UserRow, UserColumn),
        insert_piece(Board, UserRow, UserColumn, PlayerColor, NewBoard),
        NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, PlayerTotalMove + 1]
    ).



ask_user_for_move(UserRow, UserColumn) :-
    write("Where do you want to move? Type A1 where A is column and 1 is the row."), nl,
    write("Please make sure that the column is capitalized!"), nl,
    read_line_to_string(user_input, UsrInput), nl,
    string_length(UsrInput, Length),
    (Length > 3 -> ask_user_for_move(UserRow, UserColumn) )
    ;
    (Length < 2 -> ask_user_for_move(UserRow, UserColumn) )
    ;
    % Extracting Row and Column from UsrInput
    upcase_conversion(UsrInput, UpCaseUsrInput),
    convert_row_col(UpCaseUsrInput, UserRow, UserColumn),
    (
        is_row_column_valid(UserRow, UserColumn, IsValid),
        (
            IsValid = false ->
                write("That place is not valid"), nl,
                ask_user_for_move(UserRow, UserColumn)
            ;
            get_piece(Board, UserRow, UserColumn, BoardItem),
            (
                BoardItem \= 'O' ->
                    write("The board is not empty"), nl,
                    ask_user_for_move(UserRow, UserColumn)
                ;
                true
            )
        )
    ).

% convert user input to upper case
upcase_conversion(Inpt, UpcaseResult):-
    atom_codes(Atom, Inpt), upcase_atom(Atom, UpcaseResult).

ask_user_for_second_move(UserRow, UserColumn) :-
    write("Since this is the second move, you must enter 3 intersections away from the center"), nl,
    ask_user_for_input(UserRow1, UserColumn1),
    is_second_position_valid(UserRow1, UserColumn1, IsSecondPositionValid),
    (
        IsSecondPositionValid = false ->
            write("Second position is not valid"), nl,
            ask_user_for_second_move(UserRow1, UserColumn1)
        ;
        UserRow is UserRow1, 
        UserColumn is UserColumn1
    ). 
convert_row_col(UsrInput, UserRow, UserColumn):-
    atom_chars(UsrInput, [ColumnChar | RowChars]),
    % Ensure ColumnChar is a capital letter
    char_type(ColumnChar, upper),
    atom_chars(RowAtom, RowChars),
    atom_number(RowAtom, UserRow),
    char_code('A', A),
    char_code(ColumnChar, ColumnCode),
    UserColumn is ColumnCode - A.


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

boolean_question(Result):-
    write("Please enter \"N\" for 'No' and \"Y\" for 'Yes': "), nl,
    read_line_to_string(user_input, UserInput),
    upcase_conversion(UserInput, Result)
    (
        (UpCaseResult = "N"; UpCaseResult = "Y") ->
        true
        ;
        does_user_want_to_continue(Result1)
    ).





print_current_status(HumanPlayer, ComputerPlayer, NewBoard):-
    [HumanColor, HumanTournamentPoint, HumanRoundPoint, HumanCapturePoint, HumanTotalMove] = HumanPlayer,
    [ComputerColor, ComputerTournamentPoint, ComputerRoundPoint, ComputerCapturePoint, ComputerTotalMove] = ComputerPlayer,
    write('Board:'),nl,
    print_board_with_index(NewBoard, 19),nl,
    write('Human:'),nl,
    write('HumanColor: '), write(HumanColor),nl,
    write('HumanCapturePoint: '), write(HumanCapturePoint),nl,
    write('HumanRoundPoint: '), write(HumanRoundPoint),nl,
    write('HumanTournamentPoint: '), write(HumanTournamentPoint),nl,nl,
    write('Computer: '),nl,
    write('ComputerColor: '), write(ComputerColor),nl,
    write('ComputerCapturePoint: '), write(ComputerCapturePoint),nl,
    write('ComputerRoundPoint: '), write(ComputerRoundPoint),nl,
    write('ComputerTournamentPoint: '), write(ComputerTournamentPoint),nl.


