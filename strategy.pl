generate_random_position(Board, RandomRow, RandomColumn):-
 random(0, 18, RandomRow),
 random(0, 18, RandomColumn),
 get_piece(Board, RandomRow, RandomColumn, Piece),
 (Piece = 'O' -> true)
 ;
 generate_random_position(Board, RandomRow1, RandomColumn2).


generate_random_second_position(Board, RandomRow, RandomColumn):-
 generate_random_position(Board, RandomRow, RandomColumn),
 get_piece(Board, RandomRow1, RandomColumn1, Piece),
 (Piece = 'O' -> true)
 ;
 generate_random_second_position(Board, RandomRow1, RandomColumn2).

 %directional predicates
direction(right_diagonal_up, [-1, 1]).
direction(right_diagonal_down, [1, -1]).
direction(left_diagonal_up, [-1, -1]).
direction(left_diagonal_down, [1, 1]).
direction(vertical_up, [-1, 0]).
direction(vertical_down, [1, 0]).
direction(horizontal_left, [0, -1]).
direction(horizontal_right, [0, 1]).
% Direction array indices
direction_array_index(1, right_diagonal_up).
direction_array_index(2, right_diagonal_down).
direction_array_index(3, left_diagonal_up).
direction_array_index(4, left_diagonal_down).
direction_array_index(5, vertical_up).
direction_array_index(6, vertical_down).
direction_array_index(7, horizontal_left).
direction_array_index(8, horizontal_right).

total_piece_right_diagonal(Board, Row, Column, Color, TotalPiece):-
    check_total_number_pieces(Board, Row, Column, Color, right_diagonal_up, 0, TotalPiece1),
    check_total_number_pieces(Board, Row, Column, Color, right_diagonal_down, 0, TotalPiece2),
    TotalPiece is TotalPiece1 + TotalPiece2.

total_piece_vertical(Board, Row, Column, Color, Result):-
    check_total_number_pieces(Board, Row, Column, Color, vertical_up, 0, TotalPiece1),
    check_total_number_pieces(Board, Row, Column, Color, vertical_down, 0, TotalPiece2),
    Result is TotalPiece1 + TotalPiece2.



% this should calculate the total number of points for each and give out the max point if > 0
traverse_board_for_best_capture(Board, [], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-
Point is BestCurrentPoint,
ResultRowIndex is BestCurrentRowIndex,
ResultColumnIndex is BestCurrentColumnIndex.


% traverse_board_for_best_capture(NewBoard8, NewBoard8, 'B', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
traverse_board_for_best_capture(Board, [Row|RestOfBoard], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-  
    row_for_best_capture(Board, Color, Row, RowIndex, 0, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Greatest1, BCRow, BCCol),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_best_capture(Board, RestOfBoard, Color, NextRowIndex, Greatest1,  BCRow, BCCol, Point, ResultRowIndex, ResultColumnIndex).
%row_for_best_capture(Board, Color, [], R, 19, CurrentBestPointTracker,  BestPointCurrent, BestRowT, BestColumnT, BRow, BCol):-
    
row_for_best_capture(Board, Color, [], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-
    Greatest is CPoint,
    BCRow is BRow,
    BCCol is BCol.

row_for_best_capture(Board, Color, [PieceForCapture|RestOfRow], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-

    C < 19 ->
    (
        is_place_empty(Board, R, C) ->
        (
            check_capture(Board, R, C, Color, 1, false, 0, TmpCapture, X),
            TmpCapture > CPoint ->
            (
                write("Row "), write(R),write(" Column "), write(C), nl,
                ColIn1 is C + 1,
                row_for_best_capture(Board, Color, RestOfRow, R, ColIn1, TmpCapture, R, C, Greatest, BCRow, BCCol)
            )
            ;
            ColIn2 is C + 1,
            row_for_best_capture(Board, Color, RestOfRow, R, ColIn2, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
        )
        ;
        ColIn is C + 1,
        row_for_best_capture(Board, Color, RestOfRow, R, ColIn, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
    ).

check_capture(Board, Row, Column, Color, 9, true, CapturePointCounter, CapturePoint, BoardAfterCapture):-
    BoardAfterCapture = Board,
    CapturePoint = CapturePointCounter.
check_capture(Board, Row, Column, Color, 9, false, CapturePointCounter, CapturePoint, BoardAfterCapture):-
    CapturePoint = CapturePointCounter.

check_capture(Board, Row, Column, Color, CounterIndexForArray, Remove, CapturePointCounter, CapturePoint, BoardAfterCapture):-

   (CounterIndexForArray < 9) ->( is_capture(Board, Row, Column, CounterIndexForArray, Color) -> (
        Remove -> 
        (   direction_array_index(CounterIndexForArray, DirectionCode1),
            get_direction_for_npos(Row, Column, DirectionCode1, 1, RowAtOne, ColumnAtOne),
            get_direction_for_npos(Row, Column, DirectionCode1, 2, RowAtTwo, ColumnAtTwo),
            insert_piece(Board, RowAtOne, ColumnAtOne, 'O', NewBoard),
            insert_piece(NewBoard, RowAtTwo, ColumnAtTwo, 'O', NewBoard1),
            NewCapturePointCounter is CapturePointCounter + 1,
            NewCounterIndexForArray is CounterIndexForArray + 1,
            check_capture(NewBoard1, Row, Column, Color, NewCounterIndexForArray, Remove, NewCapturePointCounter, CapturePoint, BoardAfterCapture)
        )
        ;
        Remove = false -> ( 
            NewCapturePointCounter1 is CapturePointCounter + 1,
            NewCounterIndexForArray1 is CounterIndexForArray + 1,
            check_capture(Board, Row, Column, Color, NewCounterIndexForArray1, Remove, NewCapturePointCounter1, CapturePoint, BoardAfterCapture)
        )
    )
    ; 
    NewCounterIndexForArray2 is CounterIndexForArray + 1, 
    check_capture(Board, Row, Column, Color, NewCounterIndexForArray2, Remove, CapturePointCounter, CapturePoint, BoardAfterCapture)).


is_capture(Board, Row, Column, DirectionIndex, Color):-
    direction_array_index(DirectionIndex, DirectionCode),
    get_opposite_color(Color, OpColor),
    check_total_number_pieces(Board, Row, Column, OpColor, DirectionCode, 0, TotalPiecesCapture),
    (TotalPiecesCapture == 2 ) -> 
    (get_piece_npos_direction(Board, Row, Column, 3, DirectionCode, ResultPieceForCapture),
        (ResultPieceForCapture ==  Color) -> true 
        ; false
    )
    ;
    false.


get_direction_for_npos(Row, Column, MultiplierCode, Mulitplier, X, Y):-
   Row < 19,
   Column < 19,
   direction(MultiplierCode, [RowCode, ColumnCode]),
   X is Row + RowCode * Mulitplier,
   Y is Column + ColumnCode * Mulitplier.



count_point(Board, Row, Column, 9, Color, AccumulateResult, ResultOfPointCounter):-
    ResultOfPointCounter is AccumulateResult.
count_point(Board, Row, Column, Index, Color, AccumulateResult, ResultOfPointCounter):-
    ( Index < 9) -> ( Row < 19,
    Column < 19, 
    direction_array_index(Index, DirectionCode),
    Index1 is Index + 1,
    direction_array_index(Index1, DirectionCode1),
    check_total_number_pieces(Board, Row, Column, Color, DirectionCode, 0, OperationResult1),
    check_total_number_pieces(Board, Row, Column, Color, DirectionCode1, 0, OperationResult2),
    TotalPieces is OperationResult1 + OperationResult2 + 1,
    TotalPieces >= 4 -> (
        AccumulateResult1 is AccumulateResult + ((5 * (TotalPieces // 5)) + (TotalPieces mod 5) // 4),
        Index2 is Index + 2,
        count_point(Board, Row, Column, Index2, Color, AccumulateResult1, ResultOfPointCounter)
    )
    ;
    Index3 is Index + 2,
    count_point(Board, Row, Column, Index3, Color, AccumulateResult, ResultOfPointCounter)).


% this should calculate the total number of points for each and give out the max point if > 0
traverse_board_for_best_point(Board, [], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-
Point is BestCurrentPoint,
ResultRowIndex is BestCurrentRowIndex,
ResultColumnIndex is BestCurrentColumnIndex.


% traverse_board_for_best_point(NewBoard8, NewBoard8, 'B', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
traverse_board_for_best_point(Board, [Row|RestOfBoard], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-    
    row_for_best_point(Board, Color, Row, RowIndex, 0, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Greatest1, BCRow, BCCol),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_best_point(Board, RestOfBoard, Color, NextRowIndex, Greatest1,  BCRow, BCCol, Point, ResultRowIndex, ResultColumnIndex).
%row_for_best_point(Board, Color, [], R, 19, CurrentBestPointTracker,  BestPointCurrent, BestRowT, BestColumnT, BRow, BCol):-
    
row_for_best_point(Board, Color, [], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-
    Greatest is CPoint,
    BCRow is BRow,
    BCCol is BCol.

row_for_best_point(Board, Color, [PieceForCapture|RestOfRow], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-

    C < 19 ->
    (
        is_place_empty(Board, R, C) ->
        (
            count_point(Board, R, C, 1, Color, 0, RP),
            RP > CPoint ->
            (
                ColIn1 is C + 1,
                row_for_best_point(Board, Color, RestOfRow, R, ColIn1, RP, R, C, Greatest, BCRow, BCCol)
            )
            ;
            ColIn2 is C + 1,
            row_for_best_point(Board, Color, RestOfRow, R, ColIn2, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
        )
        ;
        ColIn is C + 1,
        row_for_best_point(Board, Color, RestOfRow, R, ColIn, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
    ).





check_total_number_pieces(Board, Row, Column, Color, MultiplierCode, AccumulatedCount, OperationResult):-
    direction(MultiplierCode, [RowCode, ColumnCode]),
    NewRowIndex is Row + RowCode,
    NewColumnIndex is Column + ColumnCode,
    NewRowIndex >= 0,
    NewRowIndex < 19,
    NewColumnIndex >= 0,
    NewColumnIndex < 19,
    get_piece(Board, NewRowIndex, NewColumnIndex, Piece),
    (
        Piece == Color -> 
        TotalPieceCounting is AccumulatedCount + 1,
        check_total_number_pieces(Board, NewRowIndex, NewColumnIndex, Color, MultiplierCode, TotalPieceCounting, OperationResult)
    ; 
        OperationResult is AccumulatedCount
    );
        OperationResult is AccumulatedCount
    .



% get piece n pos awar in Direction
get_piece_npos_direction(Board, Row, Column, N, DirectionCode, Piece):-
    direction(DirectionCode, [RowDirCode, ColumnDirCode]),
    NewRowDirection is Row + RowDirCode * N,
    NewColDirection is Column + ColumnDirCode * N,
    NewRowDirection >= 0,
    NewRowDirection < 19,
    NewColDirection >= 0,
    NewColDirection < 19,
    get_piece(Board, NewRowDirection, NewColDirection, Piece)
    ;
    Piece = 'O'.
%for testing calculate vertical pieces

% BUILDING INITIATIVE


check_building_initiative(Board, Row, Column, Color, 9, GreatestDirectionCodeIndex, ResultDirectionCodeIndex, TmpEmpty) :-
    ResultDirectionCodeIndex is GreatestDirectionCodeIndex.

check_building_initiative(Board, Row, Column, Color, CounterIndexForArray, GreatestDirectionCodeIndex, ResultDirectionCodeIndex, TmpEmpty) :-
    CounterIndexForArray < 9 ->(
    direction_array_index(CounterIndexForArray, DirectionCode),
    check_total_number_pieces(Board, Row, Column, 'O', DirectionCode, 0, TotalEmptyPieces),
    TotalEmptyPieces > TmpEmpty ->(
        NextCounterIndexForArray is CounterIndexForArray + 1, 
        check_building_initiative(Board, Row, Column, Color, NextCounterIndexForArray, CounterIndexForArray, ResultDirectionCodeIndex, TotalEmptyPieces)

    )
    ;
      NextCounterIndexForArray1 is CounterIndexForArray + 1, 
    check_building_initiative(Board, Row, Column, Color, NextCounterIndexForArray1, GreatestDirectionCodeIndex, ResultDirectionCodeIndex, TmpEmpty)).


%check_filling_initiative()



traverse_board_for_best_initiative(Board, [], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-
Point is BestCurrentPoint,
ResultRowIndex is BestCurrentRowIndex,
ResultColumnIndex is BestCurrentColumnIndex.


% traverse_board_for_best_point(NewBoard8, NewBoard8, 'B', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
traverse_board_for_best_initiative(Board, [Row|RestOfBoard], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-    
    row_for_best_initiative(Board, Color, Row, RowIndex, 0, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Greatest1, BCRow, BCCol),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_best_initiative(Board, RestOfBoard, Color, NextRowIndex, Greatest1,  BCRow, BCCol, Point, ResultRowIndex, ResultColumnIndex).
%row_for_best_initiative(Board, Color, [], R, 19, CurrentBestPointTracker,  BestPointCurrent, BestRowT, BestColumnT, BRow, BCol):-
    
row_for_best_initiative(Board, Color, [], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-
    Greatest is CPoint,
    BCRow is BRow,
    BCCol is BCol.

row_for_best_initiative(Board, Color, [Piece|RestOfRow], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-

    C < 19 ->
    (
        Piece == Color ->
        (
            check_building_initiative(Board, R, C, Color, 1, 0, RP, 0),
            write(RP),nl,
            write(CPoint),nl,
             RP > CPoint ->
            (

                write(RP),nl,
                direction_array_index(RP, DirectionCode2),
                write(DirectionCode2),nl,
                get_direction_for_npos(R, C, DirectionCode2, 3, RowAtThree, ColumnAtThree),
                ColIn1 is C + 1,
                row_for_best_initiative(Board, Color, RestOfRow, R, ColIn1, 100, RowAtThree, ColumnAtThree, Greatest, BCRow, BCCol)
            )
            ;
            ColIn2 is C + 1,
            row_for_best_initiative(Board, Color, RestOfRow, R, ColIn2, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
        )
        ;
        ColIn is C + 1,
        row_for_best_initiative(Board, Color, RestOfRow, R, ColIn, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
    ); write("End"),nl.









testing():-
    get_empty_board(Board), 
    insert_piece(Board, 1, 1, 'B', NewBoard),
    insert_piece(NewBoard, 2, 2, 'B', NewBoard1),
    insert_piece(NewBoard1, 3, 3, 'B', NewBoard2),
    insert_piece(NewBoard2, 4, 4, 'B', NewBoard3),
    insert_piece(NewBoard3, 5, 5, 'B', NewBoard4),
    insert_piece(NewBoard4, 6, 6, 'B', NewBoard5),
    insert_piece(NewBoard5, 7, 7, 'W', NewBoard6),
    insert_piece(NewBoard6, 8, 8, 'B', NewBoard7),
    insert_piece(NewBoard7, 9, 9, 'B', NewBoard8),
    total_piece_vertical(NewBoard8, 5, 1, 'B', ResultCount),
    get_piece_npos_direction(NewBoard8, 4, 1, 3, vertical_up, ResultPiece),
    count_point(NewBoard8, 1, 1, 1, 'B', 0, Result),
    % write("Form testing "),
    % write(Result),nl,
    % traverse_board_for_best_point(NewBoard8, NewBoard8, 'B', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
    % traverse_board_for_best_capture(NewBoard8, NewBoard8, 'W', 0, 0, 0, 0, Point2, ResultRowIndex2, ResultColumnIndex2),
    % check_capture(NewBoard8, 10, 10, 'W', 1, false, 0, CapturePoint, BoardAfterCapture),
    % % write(CapturePoint),nl,
    % write("The best row is "), write(ResultRowIndex1), write(" and the best column is "), write(ResultColumnIndex1), write(" the point is "), write(Point1), nl,
    % write("The best capture row is "), write(ResultRowIndex2), write(" and the best column is "), write(ResultColumnIndex2), write(" the point is "), write(Point2), nl,

    write("Checking for best initiative"),nl,
    insert_piece(NewBoard8, 1, 0, 'W', NewBoard9),
    insert_piece(NewBoard9, 0, 1, 'W', NewBoard10),

    
     
    %check_building_initiative(NewBoard10, 0, 0, 'B', 1, 0, ResultDirectionCodeIndex, 0),

    %write("the directional code is "), write(ResultDirectionCodeIndex),nl,
     traverse_board_for_best_initiative(NewBoard9, NewBoard9, 'B', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
    write("This is the direction to use "), write( ResultRowIndex1),write(" "), write(ResultColumnIndex1), nl,
    print_board_with_index(NewBoard10, 19).


% is_capture(NewBoard3, 5, 1, 5, 'W') -> write("Yes"),nl
% ; write("No"),
% insert_piece(NewBoard3, 5, 1, 'W', NewBoard4),
% check_capture(NewBoard4, 5, 1, 'W', 1, false, 0, CapturePoint, BoardAfterCapture),
% write(CapturePoint),nl,

