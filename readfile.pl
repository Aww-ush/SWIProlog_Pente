

read_file_content(File, Content) :-
    open(File, read, Stream),
    read(Stream, Content),
    close(Stream).

% Helper predicate to read lines from the file
read_lines(Stream, []) :-
    at_end_of_stream(Stream).
read_lines(Stream, [Line|Rest]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_string(Stream, LineString),
    atom_chars(Line, LineString),
    read_lines(Stream, Rest).
string_to_color('black', 'b').
string_to_color('white', 'w').
color_to_string('b', 'black').
color_to_string('w', 'white').
% get_player_string('H', "human").
ask_for_file(FileName):-
    write('Please enter the filename to load the game from:'), nl,
    read_line_to_string(user_input, TmpFile),
    exists_file(TmpFile) -> FileName = TmpFile ;
    (
        write('File does not exist. Please try again.'), nl,
        ask_for_file(FileName)
    ).
parse_file(Board, HumanPlayer, ComputerPlayer, NextPlayerChar):-
    ask_for_file(FileName),
    read_file_content(FileName, Content),
    [Board, HumanCapturePoint, HumanScore, ComputerCapturePoint, ComputerScore, NextPlayerString, NextPlayerColorString] = Content,
    process_players(Board, NextPlayerString, NextPlayerColorString, HumanCapturePoint, ComputerCapturePoint, HumanScore, ComputerScore, HumanPlayer, ComputerPlayer, NextPlayerChar),
    write("Here is the loaded game state:"),nl,nl,
    print_current_status(HumanPlayer, ComputerPlayer, Board).


process_players(Board, NextPlayerString, NextPlayerColorString, HumanCP, ComputerCP, HumanScore, ComputerScore, Human, Computer, NextPlayerChar):-
    get_human_computer_color(NextPlayerString, NextPlayerColorString, NextPlayerChar, HumanColor, CompColor),
    traverse_board_for_counting_point(Board, Board, HumanColor, 0,  0, HumanRoundPoint),
    traverse_board_for_counting_point(Board, Board, CompColor, 0,  0, ComputerRoundPoint),
    traverse_board_for_counting_pieces(Board, Board, HumanColor, 0,  0, TmpHumanMove),
    TotalHumanMove is TmpHumanMove + HumanCP * 2,
    traverse_board_for_counting_pieces(Board, Board, CompColor, 0,  0, TmpComputerMove),
    TotalComputerMove is TmpComputerMove + ComputerCP * 2,
    Human = [HumanColor, HumanScore, HumanRoundPoint, HumanCP, TotalHumanMove],
    Computer = [CompColor, ComputerScore, ComputerRoundPoint, ComputerCP, TotalComputerMove].

get_char_from_string('human', 'H').
get_char_from_string('computer', 'C').

get_human_computer_color(NextPlayerString, NextPlayerColorString, NextPlayerChar, HumanColor, ComputerColor):-

    get_char_from_string(NextPlayerString, NextPlayerChar),
    (NextPlayerChar = 'H') ->
    (
        string_to_color(NextPlayerColorString, HumanColor),
        get_opposite_color(HumanColor, ComputerColor)
    )
    ;
    get_char_from_string(NextPlayerString, NextPlayerChar),
    string_to_color(NextPlayerColorString, ComputerColor),
    get_opposite_color(ComputerColor, HumanColor).



traverse_board_for_counting_point(_, [], _, _, TmpPoint1, Point):-
Point is TmpPoint1.

% traverse_board_for_best_point(NewBoard8, NewBoard8, 'b', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
traverse_board_for_counting_point(Board, [Row|RestOfBoard], Color, RowIndex,  TmpPoint1, Point):-    
    row_for_best_counting_point(Board, Color, Row, RowIndex, 0, TmpPoint1, NewPoint, NewBoard1),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_counting_point(NewBoard1, RestOfBoard, Color, NextRowIndex, NewPoint, Point).
    
row_for_best_counting_point(Board, _, [], _, _, TmpPoint, Points, NewBoard):-
    NewBoard = Board,
    Points = TmpPoint.

row_for_best_counting_point(Board, Color, [PieceForCapture|RestOfRow], R, C, TmpPoint, Points, NewBoard):-
    C < 19 ->
    (
       
        PieceForCapture = Color ->
        (
            count_point(Board, R, C, 1, Color, 0, RP),
            insert_piece(Board, R, C, 'o', NewBoard1),
            TmpPoint1 is RP + TmpPoint,
            ColIn2 is C + 1,
            row_for_best_counting_point(NewBoard1, Color, RestOfRow, R, ColIn2, TmpPoint1, Points, NewBoard)
        )
        ;
        ColIn is C + 1,
        row_for_best_counting_point(Board, Color, RestOfRow, R, ColIn, TmpPoint, Points, NewBoard)
    ).
% counting pieces
traverse_board_for_counting_pieces(_, [], _, _, TmpPoint1, Point):-
Point is TmpPoint1.


% traverse_board_for_best_point(NewBoard8, NewBoard8, 'b', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
traverse_board_for_counting_pieces(Board, [Row|RestOfBoard], Color, RowIndex,  TmpPoint1, Point):-    
    row_for_best_counting_pieces(Board, Color, Row, RowIndex, 0, TmpPoint1, Points),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_counting_pieces(Board, RestOfBoard, Color, NextRowIndex, Points, Point).
    
row_for_best_counting_pieces(_, _, [], _, _, TmpPoint, Points):-
    Points is TmpPoint.

row_for_best_counting_pieces(Board, Color, [PieceForCapture|RestOfRow], R, C, TmpPoint, Points):-
    C < 19 ->
    (
        PieceForCapture = Color ->
        (
            TmpPoint1 is 1 + TmpPoint,
            ColIn2 is C + 1,
            row_for_best_counting_pieces(Board, Color, RestOfRow, R, ColIn2, TmpPoint1, Points)
        )
        ;
        ColIn is C + 1,
        row_for_best_counting_pieces(Board, Color, RestOfRow, R, ColIn, TmpPoint, Points)
    ).

writefile(Board, HumanCapturePoint, HumanScore, ComputerCapturePoint, ComputerScore, NextPlayerString, NextPlayerColorString):-
    Output = [Board, HumanCapturePoint, HumanScore, ComputerCapturePoint, ComputerScore, NextPlayerString, NextPlayerColorString],
    open('Game.txt', write, Stream),
    write(Stream, Output),  
    close(Stream).        
