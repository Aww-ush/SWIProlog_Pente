

:-include('coin').
:-consult(board).
:-consult(strategy).
:-consult(readfile).

% player contains color, tournamentPoints, RoundPoints, TotalMove

startgame(EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer) :-
   write("Welcome to the Game!"),
   nl,
   write("Do you want to load the game?"),nl,
    boolean_question(UserWantToLoad),nl,
    UserWantToLoad  == "Y"-> (
        parse_file(Board, HumanPlayer, ComputerPlayer, NextPlayerChar),
        start_tournament(HumanPlayer, ComputerPlayer, NextPlayerChar, Board, EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer)
    )
    ;
   write("To pick first player starting coin toss"),
   nl,
   coin_toss(HumanColor, ComputerColor),
   get_first_mover_from_color(HumanColor, ComputerColor, NextMover1),
   get_empty_board(Board),
    start_tournament([HumanColor, 0, 0, 0, 0], [ComputerColor, 0, 0, 0, 0], NextMover1, Board, EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer).


decide_player_color(HumanTP, ComputerTP, HumanColor, CompColor):-

    (HumanTP = ComputerTP) -> (
           write("To pick first player starting coin toss"),
            nl,
            coin_toss(HumanColor, CompColor)
    )
    ;
    (HumanTP > ComputerTP) -> (
           write("Since you had greater overall points you will be going first in next round!"),
            nl,
            HumanColor = 'w',
            CompColor = 'b'
    )
    ;
    (HumanTP < ComputerTP) -> (
           write("Since you had lesser overall points you will be going second in next round!"),
            nl,
            HumanColor = 'b',
            CompColor = 'w'
    ).
main_game_entry():-
    startgame(EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer),
    write("Do you want to save the game?"), nl,
    boolean_question(UserWantToSave),
    after_round_over(EndHumanPlayer, EndComputerPlayer, EndBoard, EndNextPlayer, UserWantToSave).

start_tournament(HumanPlayer, ComputerPlayer, NextPlayer, StartBoard, EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer):-
    write("Starting the Game"),nl,
    play_round(HumanPlayer, ComputerPlayer, StartBoard, NextPlayer, "Y", EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer).

    
after_round_over(HumanPlayer, ComputerPlayer, _, _, "N"):-
    write("According to scores till now, "), nl,
    calculate_total_points(HumanPlayer, ComputerPlayer, NewHumanTP, NewComputerTP),
    show_tournament_winner(NewHumanTP, NewComputerTP),
    write("Thank your for playing"). 

after_round_over(HumanPlayer, ComputerPlayer, FinalBoard, NextPlayer, "Y"):-
    write("According to scores till now, "), nl,
    calculate_total_points(HumanPlayer, ComputerPlayer, NewHumanTP, NewComputerTP),
    show_tournament_winner(NewHumanTP, NewComputerTP),
    write("Saving the game"), nl,
    [HumanColor, HumanTournamentPoint, _, HumanCapturePoint, _] = HumanPlayer,
    [ComputerColor, ComputerTournamentPoint, _, ComputerCapturePoint, _] = ComputerPlayer,
    next_player_color_string(NextPlayer, HumanColor, ComputerColor, NextPlayerString, NextPlayerColorString),
    writefile(FinalBoard, HumanCapturePoint, HumanTournamentPoint, ComputerCapturePoint, ComputerTournamentPoint, NextPlayerString, NextPlayerColorString),
    write("Thank your for playing"),nl.

next_player_color_string(NextPlayer, HumanColor, ComputerColor, NextPlayerString, NextPlayerColorString):-
    
    NextPlayer = 'H' ->(
        get_player_string(NextPlayer, NextPlayerString),
        color_to_string(HumanColor, NextPlayerColorString)
    )
    ;
    get_player_string(NextPlayer, NextPlayerString),
    color_to_string(ComputerColor, NextPlayerColorString).

calculate_total_points(HumanPlayer, ComputerPlayer, NewHumanTP, NewComputerTP):-
    [_, HumanTournamentPoint, HumanRoundPoint, HumanCapturePoint, _] = HumanPlayer,
    [_, ComputerTournamentPoint, ComputerRoundPoint, ComputerCapturePoint, _] = ComputerPlayer,
    NewHumanTP is  HumanTournamentPoint + HumanRoundPoint + HumanCapturePoint,
    NewComputerTP is ComputerTournamentPoint + ComputerRoundPoint + ComputerCapturePoint.
    
play_round(Human, Computer, Board, NextPlayer, "N", EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer) :-
    EndBoard = Board,
    EndHumanPlayer = Human,
    EndComputerPlayer = Computer,
    get_opposite_player_char(NextPlayer, OppoPlayer),
    EndNextPlayer = OppoPlayer.

play_round(Human, Computer, Board, NextPlayer, "Y", EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer) :-
    (NextPlayer = 'H') ->
    (
        [HumanColor, HumanTournamentPoint, HumanRoundPoint, HumanCapturePoint, HumanTotalMove] = Human,
        make_move(HumanColor, HumanTournamentPoint, HumanRoundPoint, HumanCapturePoint, HumanTotalMove, Board, 'H', DidWin, ResultBoard1, NewPlayer),
        after_make_move(NewPlayer, Computer, ResultBoard1, 'H', DidWin, EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer)

    )
    ;
    (NextPlayer = 'C') ->
    (
        [ComputerColor, ComputerTournamentPoint, ComputerRoundPoint, ComputerCapturePoint, ComputerTotalMove] = Computer,
        make_move(ComputerColor, ComputerTournamentPoint, ComputerRoundPoint, ComputerCapturePoint, ComputerTotalMove, Board, 'C', DidWin, ResultBoard1, NewPlayer),
        after_make_move(Human, NewPlayer, ResultBoard1, 'C', DidWin, EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer)
    ).

get_player_string('H', "human").
get_player_string('C', "computer").
get_opposite_player_char('H', 'C').
get_opposite_player_char('C', 'H').
% this is human, computer, next mover
get_first_mover_from_color('w', 'b', 'H').
get_first_mover_from_color('b', 'w', 'C').

after_make_move(Human, Computer, Board, PlayerChar, true, EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer):-
       
        get_player_string(PlayerChar, PlayerString),
        write(PlayerString), write(" won this round"),nl,
        print_current_status(Human, Computer, Board), nl,
        write("Do you want to continue with new tournament? "),
        boolean_question(Result1),
        Result1 == "Y" ->( 
            calculate_total_points(Human, Computer, NewHumanTP, NewComputerTP),
            get_empty_board(NewEmptyBoard),
            decide_player_color(NewHumanTP, NewComputerTP, HumanColor1, CompColor1),
            get_first_mover_from_color(HumanColor1, CompColor1, NextMover),
            start_tournament([HumanColor1, NewHumanTP, 0, 0, 0], [CompColor1, NewComputerTP, 0, 0, 0], NextMover, NewEmptyBoard, EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer)
        )
        ;
        get_opposite_player_char(PlayerChar, OppoPlayer),
        EndBoard = Board, EndHumanPlayer = Human, EndComputerPlayer = Computer, EndNextPlayer = OppoPlayer,
        calculate_total_points(Human, Computer, NewHumanTP1, NewComputerTP1),
        show_tournament_winner(NewHumanTP1, NewComputerTP1).

after_make_move(Human, Computer, Board, PlayerChar, false, EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer):-
        print_current_status(Human, Computer, Board),
        get_opposite_player_char(PlayerChar, OppoPlayer),
        get_player_string(OppoPlayer, PlayerString),
        write("Next Mover is: "), write(PlayerString), nl,
        write("Do you want to continue? "),
        boolean_question(Result),
        play_round(Human, Computer, Board, OppoPlayer, Result, EndBoard, EndHumanPlayer, EndComputerPlayer, EndNextPlayer).


show_tournament_winner(NewHumanTP, NewComputerTP):-
    NewHumanTP > NewComputerTP -> (
        write("Congratulations you won this tornament with "), write(NewHumanTP), write(" points."),nl
    )
    ;
    NewHumanTP < NewComputerTP -> (
        write("Oh no! you lost this torunament with. Computer won with "), write(NewHumanTP), write(" points."),nl
    )
    ;
    write("There was a tie torunament with "), write(NewHumanTP), write(" points."),nl.

check_if_win(RPoint, CPoint, Win):-
        RPoint >= 5 -> (
            Win = true
        )
        ;
        CPoint >= 10 -> (
            Win = true
        )
        ; 
        Win = false.

make_move(PlayerColor, PlayerTournamentPoint, PlayerRoundpoint, PlayerCapturePoint, PlayerTotalMove, Board, PlayerType, DidWin, NewBoard, NewPlayer):-
    (PlayerType = 'H') ->(
        write("Human`s move"),nl,
        (PlayerColor = 'w' -> (
                (PlayerTotalMove = 0) ->(
                    write("Since this is the first move, inserting it in the center!"), nl,
                    insert_piece(Board, 9, 9, PlayerColor, NewBoard),
                    NewPlayerTotalMove is PlayerTotalMove + 1,
                    NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundpoint, PlayerCapturePoint, NewPlayerTotalMove],
                    DidWin = false                        
                )
                ;
                (PlayerTotalMove = 1) ->(
                    ask_user_for_second_move(Board, PlayerColor, _, _, UserRowInput, UserColumnInput),  
                    insert_piece(Board, UserRowInput, UserColumnInput, PlayerColor, NewBoard),
                    NewPlayerTotalMove is PlayerTotalMove + 1,
                    NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundpoint, PlayerCapturePoint, NewPlayerTotalMove],
                    DidWin = false
                )
            )
        )
        ;
        ask_user_for_move(Board, PlayerColor, _, _, UserRow, UserColumn),
        insert_piece(Board, UserRow, UserColumn, PlayerColor, NewBoard1),
        NewPlayerTotalMove is PlayerTotalMove + 1,
        point_checker(NewBoard1, PlayerColor,  UserRow, UserColumn, RoundPoint, CapturePoint, NewBoard),
        PlayerRoundPoint1 is PlayerRoundpoint + RoundPoint,
        PlayerCapturePoint1 is PlayerCapturePoint + CapturePoint,
        NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint1, PlayerCapturePoint1, NewPlayerTotalMove],
        check_if_win(RoundPoint, PlayerCapturePoint1, DidWin)

    )
    ;
    (PlayerType == 'C') -> (
        write("Computer`s move"),nl,
        (PlayerColor = 'w' -> (
                (PlayerTotalMove = 0) ->(
                    write("Since this is the first move, inserting it in the center!"), nl,
                    insert_piece(Board, 9, 9, PlayerColor, NewBoard),
                    NewPlayerTotalMove is PlayerTotalMove + 1,
                    NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundpoint, PlayerCapturePoint, NewPlayerTotalMove],
                    DidWin = false                        
                )
                ;
                (PlayerTotalMove = 1) ->(
                    generate_random_second_position(Board, RandomRow, RandomColumn),
                    insert_piece(Board,  RandomRow, RandomColumn, PlayerColor, NewBoard),
                    NewPlayerTotalMove is PlayerTotalMove + 1,
                    NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundpoint, PlayerCapturePoint, NewPlayerTotalMove],
                    DidWin = false
                )
            )
        )
        ;
        get_opposite_color(PlayerColor, OpColor),

        best_move(Board, PlayerColor, OpColor, -1, -1, BestMoveRow, BestMoveColumn, true),

        insert_piece(Board, BestMoveRow, BestMoveColumn, PlayerColor, NewBoard1),

        NewPlayerTotalMove is PlayerTotalMove + 1,
        point_checker(NewBoard1, PlayerColor,  BestMoveRow, BestMoveColumn, RoundPoint, CapturePoint, NewBoard2),
        NewBoard = NewBoard2,
        PlayerRoundPoint1 is PlayerRoundpoint + RoundPoint,
        PlayerCapturePoint1 is PlayerCapturePoint + CapturePoint,
        NewPlayer = [PlayerColor, PlayerTournamentPoint, PlayerRoundPoint1, PlayerCapturePoint1, NewPlayerTotalMove],
        check_if_win(RoundPoint, PlayerCapturePoint1, DidWin)
    ).

point_checker(Board, Color, InsertRow, InsertColumn, RoundPoint, CapturePoint, NewBoard):-
    count_point(Board, InsertRow, InsertColumn, 1, Color, 0, RoundPoint),
    check_capture(Board, InsertRow, InsertColumn, Color, 1, true, 0, CapturePoint, NewBoard).

convert_row_col(UsrInput, UserRow, UserColumn):-
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

generating_help_second_move(Board, _, BestMoveRow, BestMoveColumn, UserChoice):-
    write("Do you want help with deciding where to move?"),nl,
    boolean_question(Result),
    Result == "Y" -> (
        generate_random_second_position(Board, BestMoveRow, BestMoveColumn),
        BestMoveRow >= 0 ->(
            write("Do you want to move here ?"),nl,
            boolean_question(Result1),
                Result1 == "Y" -> ( UserChoice = true)

            )
            ;
            UserChoice = false

        ;
        write("Something went wrong while generating move"), nl,
        UserChoice = false
    )
    ;
    UserChoice = false.

generating_help(Board, Color, BestMoveRow, BestMoveColumn, UserChoice):-
    write("Do you want help with deciding where to move?"),nl,
    boolean_question(Result),
    Result = "Y" -> (
        get_opposite_color(Color, OpColor),
        best_move(Board, Color, OpColor, -1, -1, BestMoveRow, BestMoveColumn, true),
        BestMoveRow >= 0 ->(
            write("Do you want to move here ?"),nl,
            boolean_question(Result1),
                Result1 = "Y" -> ( UserChoice = true)

            )
            ;
            UserChoice = false

        ;
        write("Something went wrong while generating move"), nl,
        UserChoice = false
    );
    UserChoice = false.

ask_user_for_move(AskUserMoveBoard, Color, TmpUserRow, TmpUserColumn, UserRow, UserColumn) :-
    generating_help(AskUserMoveBoard, Color, BestMoveRow1, BestMoveColumn1, UserChoice1),
    UserChoice1 = true ->(
        UserRow is BestMoveRow1,
        UserColumn is BestMoveColumn1
    )
    ;
    write("Where do you want to move? Type A1 where A is column and 1 is the row."), nl,
    read_line_to_string(user_input, UsrInput),
    string_length(UsrInput, Length),
        Length =< 3 -> (
            Length >= 2 -> (
                upcase_conversion(UsrInput, UpCaseUsrInput),
                convert_row_col(UpCaseUsrInput, TmpUserRow, TmpUserColumn),
                is_row_column_valid(TmpUserRow, TmpUserColumn) ->
                (
                    is_place_empty(AskUserMoveBoard, TmpUserRow, TmpUserColumn) ->
                        UserRow is TmpUserRow,
                        UserColumn is TmpUserColumn
                    ;
                    write("The board is not empty. Please choose another spot."), nl,
                    ask_user_for_move(AskUserMoveBoard, Color, _, _, UserRow, UserColumn)
                )
                ;
                write("Invalid row or column input"), nl,
                ask_user_for_move(AskUserMoveBoard, Color, _, _,  UserRow, UserColumn)
            )
            ;
            write("User input too short!"), nl,
            ask_user_for_move(AskUserMoveBoard, Color, _, _,  UserRow, UserColumn)
        )
        ;
        write("User input too long!"), nl,
        ask_user_for_move(AskUserMoveBoard, Color, _, _,  UserRow, UserColumn).
        

ask_user_for_second_move(Board, Color, TmpUserRow, TmpUserColumn, UserRowSecond, UserColumnSecond) :-
    write("Since this is the second move, you must enter 3 intersections away from the center"), nl,
    generating_help_second_move(Board, Color, BestMoveRow1, BestMoveColumn1, UserChoice1),
    UserChoice1 == true ->(
        UserRowSecond is BestMoveRow1, UserColumnSecond is BestMoveColumn1
    )
    ;
    write("Where do you want to move? Type A1 where A is column and 1 is the row."), nl,
    read_line_to_string(user_input, UsrInput),
    string_length(UsrInput, Length),
        Length =< 3 -> (
            Length >= 2 -> (
                upcase_conversion(UsrInput, UpCaseUsrInput),
                convert_row_col(UpCaseUsrInput, TmpUserRow, TmpUserColumn),
                is_row_column_valid(TmpUserRow, TmpUserColumn) ->
                (
                    is_place_empty(Board, TmpUserRow, TmpUserColumn) ->(
                        is_second_position_valid(TmpUserRow, TmpUserColumn) ->(
                            UserRowSecond is TmpUserRow,
                            UserColumnSecond is TmpUserColumn
                        )
                        ;
                        write("Second position is not valid. Please enter a position 3 intersections away from the center."), nl,
                       ask_user_for_second_move(Board, Color, _, _, UserRowSecond, UserColumnSecond)
                    )
                    ;
                    write("The board is not empty. Please choose another spot."), nl,
                    ask_user_for_second_move(Board, Color, _, _, UserRowSecond, UserColumnSecond) 
                )
                ;
                write("Invalid row or column input"), nl,
               ask_user_for_second_move(Board, Color, _, _, UserRowSecond, UserColumnSecond) 
            )
            ;
            write("User input too short!"), nl,
            ask_user_for_second_move(Board, Color, _, _, UserRowSecond, UserColumnSecond) 
        )
        ;
        write("User input too long!"), nl,
        ask_user_for_second_move(Board, Color, _, _, UserRowSecond, UserColumnSecond).
    


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

print_current_status(HP, CP, Board1):-
    [HumanColor, HumanTournamentPoint, HumanRoundPoint, HumanCapturePoint, _] = HP,
    [ComputerColor, ComputerTournamentPoint, ComputerRoundPoint, ComputerCapturePoint, _] = CP,
    write('Board:'),nl,
    print_board_with_index(Board1, 19),nl,
    write('Human:'),nl,
    color_to_string(HumanColor, HumanColorString),
    write('HumanColor: '), write(HumanColorString),nl,
    write('HumanCapturePoint: '), write(HumanCapturePoint),nl,
    write('HumanRoundPoint: '), write(HumanRoundPoint),nl,
    write('HumanTournamentPoint: '), write(HumanTournamentPoint),nl,nl,
    write('Computer: '),nl,
    color_to_string(ComputerColor, ComputerColorString),
    write('ComputerColor: '), write(ComputerColorString),nl,
    write('ComputerCapturePoint: '), write(ComputerCapturePoint),nl,
    write('ComputerRoundPoint: '), write(ComputerRoundPoint),nl,
    write('ComputerTournamentPoint: '), write(ComputerTournamentPoint),nl.



