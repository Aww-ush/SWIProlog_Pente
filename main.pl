

:-include('coin').
:-include('board').
:-include('strategy').

% player contains color, tournamentPoints, RoundPoints, TotalMove

startgame() :-
   write("Welcome to the Game!"),
   nl,
   write("To pick first player starting coin toss"),
   nl,
   %coin_toss(HumanColor, ComputerColor),
   get_empty_board(Board),
   %start_tournament([HumanColor, 0, 0, 0, 0], [ComputerColor, 0, 0, 0, 0], Board).
   start_tournament(['W', 0, 0, 0, 0], ['B', 0, 0, 0, 0], Board). % for testing


start_tournament(HumanPlayer, ComputerPlayer, NewBoard):-
    write("Starting new Tournament"),nl,
    play_round(HumanPlayer, ComputerPlayer, NewBoard, 'H', "Y", ResultBoard).

play_round(Human, Computer, Board, NextPlayer, "N", ResultBoard) :-
    ResultBoard = Board.

play_round(Human, Computer, Board, NextPlayer, "Y", ResultBoard) :-
    (NextPlayer = 'H') ->
    (
        make_move(Human, Board, 'H', DidWin, ResultBoard, NewPlayer),
        print_current_status(NewPlayer, Computer, ResultBoard),
         write("Next Mover is: Computer"),nl,
        write("Do you want to continue? "),
        boolean_question(Result),
        play_round(NewPlayer, Computer, ResultBoard, 'C', Result, NewResultBoard)
    )
    ;
    (NextPlayer = 'C') ->
    (
        [PlayerColor | _] = Computer,
        insert_piece(Board, 0, 0, PlayerColor, NewBoard),
        print_current_status(Human, Computer, NewBoard),
        write("Next Mover is: Human"),nl,
        write("Do you want to continue? "),
        boolean_question(Result),
        play_round(Human, Computer, NewBoard, 'H', Result, FinalResultBoard)
    ).


make_move(Player, Board, PlayerType, DidWin, NewBoard, NewPlayer) :-
    [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, PlayerTotalMove] = Player,
    (PlayerType = 'H') ->(
         write(Player),
         write("Human`s move"),nl,
        (PlayerColor = 'W', PlayerTotalMove = 0) ->
            write("Since this is the first move, inserting it in the center!"), nl,
            insert_piece(Board, 9, 9, PlayerColor, NewBoard),
            NewPlayerMove is (PlayerTotalMove + 1),
            NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, NewPlayerMove]
        ;

        (PlayerColor = 'W', PlayerTotalMove = 1) ->
            write("Here is the second move"),nl,
            ask_user_for_second_move(Board, UserRowInput, UserColumnInput),  
            insert_piece(Board, UserRowInput, UserColumnInput, PlayerColor, NewBoard),
            NewPlayerMove1 is (PlayerTotalMove + 1),
            NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, NewPlayerMove1]
        ;
       
        ask_user_for_move(Board, UserRow, UserColumn),
        insert_piece(Board, UserRow, UserColumn, PlayerColor, NewBoard),
         NewPlayerMove2 is (PlayerTotalMove + 1),
         NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, NewPlayerMove2]

    );
    (PlayerType == 'C') -> (
         write("Computer`s move"),nl,
         (PlayerColor = 'W', PlayerTotalMove = 0) ->
            write("Since this is the first move, inserting it in the center!"), nl,
            insert_piece(Board, 9, 9, PlayerColor, NewBoard),
            NewPlayerMove is (PlayerTotalMove + 1),
            NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, NewPlayerMove]
        ;

        (PlayerColor = 'W', PlayerTotalMove = 1) ->
            write("Here is the second move"),nl,
            ask_user_for_second_move(Board, UserRowInput, UserColumnInput),
            
            insert_piece(Board,  UserRowInput, UserColumnInput, PlayerColor, NewBoard),
            NewPlayerMove is (PlayerTotalMove + 1),
            NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, NewPlayerMove]
        ;
       
        ask_user_for_move(Board, UserRow, UserColumn),
        insert_piece(Board, UserRow, UserColumn, PlayerColor, NewBoard),
         NewPlayerMove is (PlayerTotalMove + 1),
         NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint, PlayerCapturePoint, NewPlayerMove]
    ).


convert_row_col(UsrInput, UserRow, UserColumn) :-
    atom_chars(UsrInput, [ColumnChar | RowChars]),
    char_type(ColumnChar, upper),
    atom_chars(RowAtom, RowChars),
    atom_number(RowAtom, RowNum),
    UserRow is 19 - RowNum,
    char_code('A', A),
    char_code(ColumnChar, ColumnCode),
    UserColumn is ColumnCode - A.


% convert user input to upper case
upcase_conversion(Inpt, UpcaseResult) :-
    atom_chars(Inpt, InputChars),  
    string_chars(UpperChars, InputChars),  
    string_upper(UpperChars, UpcaseResult). 

ask_user_for_move(Board, UserRow, UserColumn) :-
    write("Where do you want to move? Type A1 where A is column and 1 is the row."), nl,
    read_line_to_string(user_input, UsrInput),
    string_length(UsrInput, Length),
    (
        Length > 3 -> 
            write("User input too long!"), nl,
            ask_user_for_move(Board, UserRow1, UserColumn1)
        ;
        Length < 2 -> 
            write("User input too short!"), nl,
            ask_user_for_move(Board, UserRow4, UserColumn4)
        ;
        upcase_conversion(UsrInput, UpCaseUsrInput),
        convert_row_col(UpCaseUsrInput, UserRow, UserColumn),
        (
            is_row_column_valid(UserRow, UserColumn) ->
                (
                    is_place_empty(Board, UserRow, UserColumn) ->
                        true
                    ;
                    write("The board is not empty. Please choose another spot."), nl,
                    ask_user_for_move(Board, UserRow5, UserColumn5)
                )
            ;
            write("Invalid row or column input"), nl,
            ask_user_for_move(Board, UserRow6, UserColumn6)
        )
    ).

ask_user_for_second_move(Board, UserRowSecond, UserColumnSecond) :-
    write("Since this is the second move, you must enter 3 intersections away from the center"), nl,
    write("Where do you want to move? Type A1 where A is column and 1 is the row."), nl,
    read_line_to_string(user_input, UsrInput),
    string_length(UsrInput, Length),
    (
        Length > 3 -> 
            write("User input too long!"), nl,
            ask_user_for_second_move(Board, UserRowSecond, UserColumnSecond)
        ;
        Length < 2 -> 
            write("User input too short!"), nl,
            ask_user_for_second_move(Board, UserRowSecond, UserColumnSecond)
        ;
        upcase_conversion(UsrInput, UpCaseUsrInput),
        convert_row_col(UpCaseUsrInput, UserRow, UserColumn),
        (
            is_row_column_valid(UserRow, UserColumn) ->
                (
                    is_place_empty(Board, UserRow, UserColumn) ->
                        (
                            is_second_position_valid(UserRow, UserColumn) ->
                                UserRowSecond = UserRow,
                                UserColumnSecond = UserColumn
                                ;
                                write("Second position is not valid. Please enter a position 3 intersections away from the center."), nl,
                                ask_user_for_second_move(Board, UserRowSecond, UserColumnSecond)
                        )
                        ;
                        write("The board is not empty. Please choose another spot."), nl,
                        ask_user_for_second_move(Board, UserRowSecond, UserColumnSecond)
                )
            ;
            write("Invalid row or column input"), nl,
            ask_user_for_second_move(Board, UserRowSecond, UserColumnSecond)
        )
    ).


is_second_position_valid(Row, Column) :-
    (Row > 6 , Row < 13) -> (Column > 6 , Column < 13), false
    ; true.

is_row_column_valid(Row, Column) :-
    Row >= 0, Row < 19, Column >= 0, Column < 19.



setNextPlayer(CurrentPlayer, NewPlayer):-
    (CurrentPlayer = 'H'-> NewPlayer = 'C', true)
    ;
    (NewPlayer = 'H'), true.

boolean_question(Result) :-
    write("Please enter \"N\" for 'No' and \"Y\" for 'Yes': "), nl,
    read_line_to_string(user_input, UserInput),
    string_length(UserInput, Length),
    (
        Length > 1 ->
            write("User input too long!"), nl,
            boolean_question(Result)
        ;
        upcase_conversion(UserInput, UpCaseResult),
        (
            (UpCaseResult = "N"; UpCaseResult = "Y") ->
                Result = UpCaseResult
            ;
                boolean_question(Result)
        )
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



