generate_random_position(Board, RandomRow, RandomColumn):-
 random(0, 18, RandomRow),
 random(0, 18, RandomColumn),
 get_piece(Board, RandomRow, RandomColumn, Piece),
 (Piece = 'o' -> true)
 ;
 generate_random_position(Board, RandomRow, RandomColumn).


generate_random_second_position(Board, RandomRow, RandomColumn):-
 generate_random_position(Board, RandomRow, RandomColumn),
 is_second_position_valid(RandomRow, RandomColumn) -> 
 (
    get_piece(Board, RandomRow, RandomColumn, Piece),
    (
        Piece = 'o' -> (
            write("This is the best secon position: "), convert_user_position(RandomRow, RandomColumn), nl,
            true
        )
    )
    ;
        generate_random_second_position(Board, RandomRow, RandomColumn)
 )
 ;
 generate_random_second_position(Board, RandomRow, RandomColumn).

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
traverse_board_for_best_capture(_, [], _, _, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-
    Point is BestCurrentPoint,
    ResultRowIndex is BestCurrentRowIndex,
    ResultColumnIndex is BestCurrentColumnIndex.


% traverse_board_for_best_capture(NewBoard8, NewBoard8, 'b', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
traverse_board_for_best_capture(Board, [Row|RestOfBoard], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-  
    row_for_best_capture(Board, Color, Row, RowIndex, 0, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Greatest1, BCRow, BCCol),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_best_capture(Board, RestOfBoard, Color, NextRowIndex, Greatest1,  BCRow, BCCol, Point, ResultRowIndex, ResultColumnIndex).
%row_for_best_capture(Board, Color, [], R, 19, CurrentBestPointTracker,  BestPointCurrent, BestRowT, BestColumnT, BRow, BCol):-
    
row_for_best_capture(_, _, [], _, _, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-
    Greatest is CPoint,
    BCRow is BRow,
    BCCol is BCol.

row_for_best_capture(Board, Color, [_|RestOfRow], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-

    C < 19 ->
    (
        is_place_empty(Board, R, C) ->
        (
            check_capture(Board, R, C, Color, 1, false, 0, TmpCapture, _),
            TmpCapture > CPoint ->
            (
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

check_capture(Board, _, _, _, 9, true, CapturePointCounter, CapturePoint, BoardAfterCapture):-
    BoardAfterCapture = Board,
    CapturePoint is CapturePointCounter.

check_capture(Board, _, _, _, 9, false, CapturePointCounter, CapturePoint, BoardAfterCapture):-
    BoardAfterCapture = Board,
    CapturePoint is CapturePointCounter.

check_capture(Board, Row, Column, Color, CounterIndexForArray, Remove, CapturePointCounter, CapturePoint, BoardAfterCapture):-

   (CounterIndexForArray < 9) ->( 
    is_capture(Board, Row, Column, CounterIndexForArray, Color) -> (
        Remove -> 
        (   direction_array_index(CounterIndexForArray, DirectionCode1),
            get_direction_for_npos(Row, Column, DirectionCode1, 1, RowAtOne, ColumnAtOne),
            get_direction_for_npos(Row, Column, DirectionCode1, 2, RowAtTwo, ColumnAtTwo),
            insert_piece(Board, RowAtOne, ColumnAtOne, 'o', NewBoard),
            insert_piece(NewBoard, RowAtTwo, ColumnAtTwo, 'o', NewBoard1),
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
    check_capture(Board, Row, Column, Color, NewCounterIndexForArray2, Remove, CapturePointCounter, CapturePoint, BoardAfterCapture)
    ).


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



count_point(_, _, _, 9, _, AccumulateResult, ResultOfPointCounter):-
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
traverse_board_for_best_point(_, [], _, _, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-
Point is BestCurrentPoint,
ResultRowIndex is BestCurrentRowIndex,
ResultColumnIndex is BestCurrentColumnIndex.


% traverse_board_for_best_point(NewBoard8, NewBoard8, 'b', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
traverse_board_for_best_point(Board, [Row|RestOfBoard], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-    
    row_for_best_point(Board, Color, Row, RowIndex, 0, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Greatest1, BCRow, BCCol),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_best_point(Board, RestOfBoard, Color, NextRowIndex, Greatest1,  BCRow, BCCol, Point, ResultRowIndex, ResultColumnIndex).
%row_for_best_point(Board, Color, [], R, 19, CurrentBestPointTracker,  BestPointCurrent, BestRowT, BestColumnT, BRow, BCol):-
    
row_for_best_point(_, _, [], _, _, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-
    Greatest is CPoint,
    BCRow is BRow,
    BCCol is BCol.

row_for_best_point(Board, Color, [_|RestOfRow], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-

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
    Piece = 'o'.
%for testing calculate vertical pieces

% BUILDING INITIATIVE


check_building_initiative(_, _, _, _, 9, GreatestDirectionCodeIndex, ResultDirectionCodeIndex, _) :-
    ResultDirectionCodeIndex is GreatestDirectionCodeIndex.

check_building_initiative(Board, Row, Column, Color, CounterIndexForArray, GreatestDirectionCodeIndex, ResultDirectionCodeIndex, TmpEmpty) :-
    CounterIndexForArray < 9 ->(
    direction_array_index(CounterIndexForArray, DirectionCode),
    check_total_number_pieces(Board, Row, Column, 'o', DirectionCode, 0, TotalEmptyPieces),
    TotalEmptyPieces > TmpEmpty ->(
        NextCounterIndexForArray is CounterIndexForArray + 1, 
        check_building_initiative(Board, Row, Column, Color, NextCounterIndexForArray, CounterIndexForArray, ResultDirectionCodeIndex, TotalEmptyPieces)

    )
    ;
      NextCounterIndexForArray1 is CounterIndexForArray + 1, 
    check_building_initiative(Board, Row, Column, Color, NextCounterIndexForArray1, GreatestDirectionCodeIndex, ResultDirectionCodeIndex, TmpEmpty)).


%check_filling_initiative()



traverse_board_for_best_initiative(_, [], _, _, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-
Point is BestCurrentPoint,
ResultRowIndex is BestCurrentRowIndex,
ResultColumnIndex is BestCurrentColumnIndex.


% traverse_board_for_best_point(NewBoard8, NewBoard8, 'b', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
traverse_board_for_best_initiative(Board, [Row|RestOfBoard], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-    
    row_for_best_initiative(Board, Color, Row, RowIndex, 0, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Greatest1, BCRow, BCCol),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_best_initiative(Board, RestOfBoard, Color, NextRowIndex, Greatest1,  BCRow, BCCol, Point, ResultRowIndex, ResultColumnIndex).
%row_for_best_initiative(Board, Color, [], R, 19, CurrentBestPointTracker,  BestPointCurrent, BestRowT, BestColumnT, BRow, BCol):-
    
row_for_best_initiative(_, _, [], _, _, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-
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
    ).



check_for_fill_initiative(_, _, _, _, TmpDirectionCodeIndex, Result, false) :-
    Result is TmpDirectionCodeIndex.

check_for_fill_initiative(Board, Row, Column, Color, TmpDirectionCodeIndex, ResultDirectionsCodeIndex,true) :-
    TmpDirectionCodeIndex < 9 ->(
    direction_array_index(TmpDirectionCodeIndex, DirectionCode),
    get_piece_npos_direction(Board, Row, Column, 3, DirectionCode, ResultPieceForFilling),
    (ResultPieceForFilling == Color ->
        (
            check_total_number_pieces(Board, Row, Column, 'o', DirectionCode, 0, TotalEmptyPieces),
            TotalEmptyPieces =:= 2 ->
            (
                check_for_fill_initiative(Board, Row, Column, Color, TmpDirectionCodeIndex, ResultDirectionsCodeIndex, false)
            )
            ;
            NextTmpDirectionCodeIndex is TmpDirectionCodeIndex + 1,
            check_for_fill_initiative(Board, Row, Column, Color, NextTmpDirectionCodeIndex, ResultDirectionsCodeIndex, true)
        )
        ;
        NextTmpDirectionCodeIndex1 is TmpDirectionCodeIndex + 1,
        check_for_fill_initiative(Board, Row, Column, Color, NextTmpDirectionCodeIndex1, ResultDirectionsCodeIndex, true)
    );
        check_for_fill_initiative(Board, Row, Column, Color, -1, ResultDirectionsCodeIndex, false)).
%the best position for filling
traverse_board_for_best_filling(_, [], _, _, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-
Point is BestCurrentPoint,
ResultRowIndex is BestCurrentRowIndex,
ResultColumnIndex is BestCurrentColumnIndex.


traverse_board_for_best_filling(Board, [Row|RestOfBoard], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-    
    row_for_best_filling(Board, Color, Row, RowIndex, 0, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Greatest1, BCRow, BCCol),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_best_filling(Board, RestOfBoard, Color, NextRowIndex, Greatest1,  BCRow, BCCol, Point, ResultRowIndex, ResultColumnIndex).
%row_for_best_filling(Board, Color, [], R, 19, CurrentBestPointTracker,  BestPointCurrent, BestRowT, BestColumnT, BRow, BCol):-
    
row_for_best_filling(_, _, [], _, _, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-
    Greatest is CPoint,
    BCRow is BRow,
    BCCol is BCol.

row_for_best_filling(Board, Color, [Piece|RestOfRow], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-

    C < 19 ->
    (
        Piece == Color ->
        (
            check_for_fill_initiative(Board, R, C, Color, 1, RP, true),
            RP > CPoint ->
            (
                direction_array_index(RP, DirectionCode2),
                get_direction_for_npos(R, C, DirectionCode2, 1, RowAtO, ColumnAtO),
                ColIn1 is C + 1,
                row_for_best_filling(Board, Color, RestOfRow, R, ColIn1, 9999, RowAtO, ColumnAtO, Greatest, BCRow, BCCol)
            )
            ;
            ColIn2 is C + 1,
            row_for_best_filling(Board, Color, RestOfRow, R, ColIn2, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
        )
        ;
        ColIn is C + 1,
        row_for_best_filling(Board, Color, RestOfRow, R, ColIn, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
    ).




best_move(_, _, _, TmpBestMoveRow, TmpBestMoveColumn, BestMoveRow, BestMoveColumn, false):-
    BestMoveRow is TmpBestMoveRow,
    BestMoveColumn is TmpBestMoveColumn.


best_move(Board, Color, OppositeColor, _, _, BestMoveRow, BestMoveColumn, true):-

    traverse_board_for_best_point(Board, Board, Color, 0, 0, -1, -1, Point1, ResultRowIndex1, ResultColumnIndex1),
    Point1 >= 5 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex1, ResultColumnIndex1), write(" here will help you win the game"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex1, ResultColumnIndex1, BestMoveRow, BestMoveColumn, false)
    )
    ;
    %block 5 in row
    traverse_board_for_best_point(Board, Board, OppositeColor, 0, 0, 0, 0, Point2, ResultRowIndex2, ResultColumnIndex2),
    Point2 >= 5 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex2, ResultColumnIndex2), write(" here will block opponent from winning the game"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex2, ResultColumnIndex2, BestMoveRow, BestMoveColumn, false)
    )
    ;
    traverse_board_for_best_capture(Board, Board, Color, 0, 0, 0, 0, Point3, ResultRowIndex3, ResultColumnIndex3),
    Point3 > 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex3, ResultColumnIndex3), write(" here will capture opponents pieces"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex3, ResultColumnIndex3, BestMoveRow, BestMoveColumn, false)
    )
    ;
    traverse_board_for_best_point(Board, Board, OppositeColor, 0, 0, 0, 0, Point22, ResultRowIndex22, ResultColumnIndex22),
    Point22 > 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex22, ResultColumnIndex22), write(" here will help you block oppenet from scoring "), write(Point22), write(" points"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex22, ResultColumnIndex22, BestMoveRow, BestMoveColumn, false)
    )
    ;
    %score points
    traverse_board_for_best_point(Board, Board, Color, 0, 0, 0, 0, Point21, ResultRowIndex21, ResultColumnIndex21),
    Point21 > 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex21, ResultColumnIndex21), write(" here will help you score "), write(Point21), write(" points"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex21, ResultColumnIndex21, BestMoveRow, BestMoveColumn, false)
    )
    ;
    %blocking from being captured
    traverse_board_for_best_capture(Board, Board, OppositeColor, 0, 0, 0, 0, Point4, ResultRowIndex4, ResultColumnIndex4),
    Point4 > 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex4, ResultColumnIndex4), write(" here will stop the pieces from being captured and make consecutives."), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex4, ResultColumnIndex4, BestMoveRow, BestMoveColumn, false)
    )
    ;
    %block consecutive
    traverse_board_for_consecutive(Board, Board, OppositeColor, 0, 0, -1, -1, ConPoint, ResultRowIndex31, ResultColumnIndex31),
    write(ConPoint),nl,
    ResultRowIndex31 >= 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex31, ResultColumnIndex31), write(" here will block opponent from making consecutive"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex31, ResultColumnIndex31, BestMoveRow, BestMoveColumn, false)
    )
    ;
    %add more to the consecutive
    traverse_board_for_consecutive(Board, Board, Color, 0, 0, -1, -1, ConPoint1, ResultRowIndex32, ResultColumnIndex32),
    write(ConPoint1),nl,
    ResultRowIndex32 >= 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex32, ResultColumnIndex32), write(" here will help you make consecutive"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex32, ResultColumnIndex32, BestMoveRow, BestMoveColumn, false)
    )
    ;
    %block form filling initiative
    traverse_board_for_best_filling(Board, Board, OppositeColor, 0, 0, -1, -1, _, ResultRowIndex5, ResultColumnIndex5),
    ResultRowIndex5 >= 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex5, ResultColumnIndex5), write(" here will block opponent from making 4 in row"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex5, ResultColumnIndex5, BestMoveRow, BestMoveColumn, false)
    )
    ;
    %filling initiative
    traverse_board_for_best_filling(Board, Board, Color, 0, 0, -1, -1, _, ResultRowIndex6, ResultColumnIndex6),
    ResultRowIndex6 >= 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex6, ResultColumnIndex6), write(" here will block opponent from making 4 in row"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex6, ResultColumnIndex6, BestMoveRow, BestMoveColumn, false)
    )
    ;
    %start initiative
    traverse_board_for_best_initiative(Board, Board, Color, 0, 0, -1, -1, _, ResultRowIndex7, ResultColumnIndex7),
    ResultRowIndex7 >= 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex7, ResultColumnIndex7), write(" here will help you start 4 in row"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex7, ResultColumnIndex7, BestMoveRow, BestMoveColumn, false)
    )
    ;
    %block initiative
    traverse_board_for_best_initiative(Board, Board, OppositeColor, 0, 0, -1, -1, _, ResultRowIndex8, ResultColumnIndex8),
    ResultRowIndex8 >= 0 -> 
    (
        write("Placing in " ), convert_user_position(ResultRowIndex8, ResultColumnIndex8), write(" here will help you block the start of 4 in row for opponent"), nl,
        best_move(Board, Color, OppositeColor, ResultRowIndex8, ResultColumnIndex8, BestMoveRow, BestMoveColumn, false)
    )
    ;
    generate_random_position(Board, ResultRowIndex9, ResultColumnIndex9),
    write("Placing in " ), convert_user_position(ResultRowIndex9, ResultColumnIndex9), write(" will be the best move for starting out in the game."), nl,
    best_move(Board, Color, OppositeColor, ResultRowIndex9, ResultColumnIndex9, BestMoveRow, BestMoveColumn, false).

    
convert_user_position(Row, Col):-
    char_code('A', A),
    Code is A + Col,
    char_code(ColumnChar, Code),
    write(ColumnChar),
    NewRow is 19 - Row,
    write(NewRow).


check_consecutive(_, _, _, _, 9, GreatestDirectionCodeIndex, ResultDirectionCodeIndex, TmpEmpty,TotalPiece) :-
    TotalPiece is TmpEmpty,
    ResultDirectionCodeIndex is GreatestDirectionCodeIndex.

check_consecutive(Board, Row, Column, Color, CounterIndexForArray, GreatestDirectionCodeIndex, ResultDirectionCodeIndex, TmpEmpty1, TotalPiece) :-
    CounterIndexForArray < 9 ->(
    direction_array_index(CounterIndexForArray, DirectionCode),
    check_total_number_pieces(Board, Row, Column, Color, DirectionCode, 0, TotalSamePieces),
    TotalSamePieces > TmpEmpty1 ->(
        NextCounterIndexForArray is CounterIndexForArray + 1, 
        check_consecutive(Board, Row, Column, Color, NextCounterIndexForArray, CounterIndexForArray, ResultDirectionCodeIndex, TotalSamePieces, TotalPiece)
    )
    ;
      NextCounterIndexForArray1 is CounterIndexForArray + 1, 
    check_consecutive(Board, Row, Column, Color, NextCounterIndexForArray1, GreatestDirectionCodeIndex, ResultDirectionCodeIndex, TmpEmpty1, TotalPiece)).


traverse_board_for_consecutive(_, [], _, _, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-
Point is BestCurrentPoint,
ResultRowIndex is BestCurrentRowIndex,
ResultColumnIndex is BestCurrentColumnIndex.

% traverse_board_for_best_point(NewBoard8, NewBoard8, 'b', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
traverse_board_for_consecutive(Board, [Row|RestOfBoard], Color, RowIndex, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Point, ResultRowIndex, ResultColumnIndex):-    
    row_for_best_consecutive(Board, Color, Row, RowIndex, 0, BestCurrentPoint, BestCurrentRowIndex, BestCurrentColumnIndex, Greatest1, BCRow, BCCol),
    NextRowIndex is RowIndex + 1,
    traverse_board_for_consecutive(Board, RestOfBoard, Color, NextRowIndex, Greatest1,  BCRow, BCCol, Point, ResultRowIndex, ResultColumnIndex).
%row_for_best_consecutive(Board, Color, [], R, 19, CurrentBestPointTracker,  BestPointCurrent, BestRowT, BestColumnT, BRow, BCol):-
    
row_for_best_consecutive(_, _, [], _, _, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-
    Greatest is CPoint,
    BCRow is BRow,
    BCCol is BCol.

row_for_best_consecutive(Board, Color, [Piece|RestOfRow], R, C, CPoint, BRow, BCol, Greatest, BCRow, BCCol):-

    C < 19 ->
    (
        Piece == 'o' ->
        (
            check_consecutive(Board, R, C, Color, 1, -1, _, -1, TotalPiece1), %check_consecutive(NewBoard10, 18, 9, 'b', 1, -1, ResultDirectionCodeIndex4, -1, TotalPiece1)
            TotalPiece1 > CPoint ->
            (
                ColIn1 is C + 1,
                row_for_best_consecutive(Board, Color, RestOfRow, R, ColIn1, TotalPiece1, R, C, Greatest, BCRow, BCCol)
            )
            ;
            ColIn2 is C + 1,
            row_for_best_consecutive(Board, Color, RestOfRow, R, ColIn2, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
        )
        ;
        ColIn is C + 1,
        row_for_best_consecutive(Board, Color, RestOfRow, R, ColIn, CPoint, BRow, BCol, Greatest, BCRow, BCCol)
    ).