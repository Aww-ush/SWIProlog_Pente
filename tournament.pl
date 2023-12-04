

testing():-
    get_empty_board(Board), 
    insert_piece(Board, 1, 1, 'b', NewBoard),
    insert_piece(NewBoard, 2, 2, 'b', NewBoard1),
    insert_piece(NewBoard1, 3, 3, 'b', NewBoard2),
    insert_piece(NewBoard2, 4, 4, 'b', NewBoard3),
    insert_piece(NewBoard3, 5, 5, 'b', NewBoard4),
    insert_piece(NewBoard4, 6, 6, 'b', NewBoard5),
    insert_piece(NewBoard5, 7, 7, 'w', NewBoard6),
    insert_piece(NewBoard6, 8, 8, 'b', NewBoard7),
    insert_piece(NewBoard7, 9, 9, 'b', NewBoard8),
    total_piece_vertical(NewBoard8, 5, 1, 'b', ResultCount),
    get_piece_npos_direction(NewBoard8, 4, 1, 3, vertical_up, ResultPiece),
    count_point(NewBoard8, 1, 1, 1, 'b', 0, Result),
    % write("Form testing "),
    % write(Result),nl,
    traverse_board_for_best_point(NewBoard8, NewBoard8, 'b', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
    % traverse_board_for_best_capture(NewBoard8, NewBoard8, 'w', 0, 0, 0, 0, Point2, ResultRowIndex2, ResultColumnIndex2),
    % check_capture(NewBoard8, 10, 10, 'w', 1, false, 0, CapturePoint, BoardAfterCapture),
    % % write(CapturePoint),nl,
    % write("The best row is "), write(ResultRowIndex1), write(" and the best column is "), write(ResultColumnIndex1), write(" the point is "), write(Point1), nl,
    % write("The best capture row is "), write(ResultRowIndex2), write(" and the best column is "), write(ResultColumnIndex2), write(" the point is "), write(Point2), nl,

    % write("Checking for best initiative"),nl,
    insert_piece(NewBoard8, 1, 0, 'w', NewBoard9),

    
     
    %check_building_initiative(NewBoard10, 0, 0, 'b', 1, 0, ResultDirectionCodeIndex, 0),

    %write("the directional code is "), write(ResultDirectionCodeIndex),nl,
    %  traverse_board_for_best_initiative(NewBoard9, NewBoard9, 'w', 0, 0, 0, 0, Point1, ResultRowIndex1, ResultColumnIndex1),
    % write("This is the direction to use "), write( ResultRowIndex1),write(" "), write(ResultColumnIndex1), nl,
    insert_piece(NewBoard9, ResultRowIndex1, ResultColumnIndex1, 'w', NewBoard10),
    %check_for_fill_initiative(NewBoard10, ResultRowIndex1, ResultRowIndex1, 'b', 1, ResultDirectionsCodeIndex1, true),
    traverse_board_for_best_filling(NewBoard10, NewBoard10, 'w', 0, 0, -1, -1, Point2, ResultRowIndex2, ResultColumnIndex2),
    
    % write("This is the direction to use "), write( ResultRowIndex2),write(" "), write(ResultColumnIndex2), nl,
    insert_piece(NewBoard10, 0, 0, 'w', NewBoard11),
    % check_consecutive(NewBoard10, 18, 9, 'b', 1, -1, ResultDirectionCodeIndex4, -1, TotalPiece1),
    % traverse_board_for_consecutive(NewBoard11, NewBoard11, 'b', 0, 0, -1, -1, TP, ResultRowIndex5, ResultColumnIndex5),
    % write("Result row is "), write(ResultRowIndex5),  write(" Result col is "), write(ResultColumnIndex5), nl,
    % write("total pieces "), write(TP),nl,
    best_move(NewBoard11, 'b', -1, -1, BestMoveRow1, BestMoveColumn1, true),
    write("This is the direction to use "), write( BestMoveRow1),write(" "), write(BestMoveColumn1), nl,
    print_board_with_index(NewBoard11, 19).


% is_capture(NewBoard3, 5, 1, 5, 'w') -> write("Yes"),nl
% ; write("No"),
% insert_piece(NewBoard3, 5, 1, 'w', NewBoard4),
% check_capture(NewBoard4, 5, 1, 'w', 1, false, 0, CapturePoint, BoardAfterCapture),
% write(CapturePoint),nl,