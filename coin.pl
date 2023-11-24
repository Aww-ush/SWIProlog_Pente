ask_user_for_input(Result) :-
    write('Please choose head or tail? Please enter "H" for head and "T" for tail: '),
    nl, % Newline for better formatting
    read_line_to_string(user_input, Input),
    ( Input = "H" -> Result = "H"
    ; Input = "T" -> Result = "T"
    ; ask_user_for_input(Result)
    ).


% Helper predicate to read a line from the input
read_line(Line) :-
    current_input(Stream),
    read_line_to_string(Stream, Line).

coin_toss_simulate(ResultFromToss) :-
    write('Coin Toss is happening'), nl,
    random(0, 2, RandomNumber), % Generate a random number between 0 and 1
    (RandomNumber =:= 0 -> ResultFromToss = "H"
    ;RandomNumber =:= 1 -> ResultFromToss = "T"
    ;write('Something went wrong while generating random number'), nl
    ).


coin_toss(HumanColor, ComputerColor) :-
    ask_user_for_input(UserInput),
    coin_toss_simulate(ResultFromToss),
    (ResultFromToss = UserInput -> 
        write('You will be white'), nl,
        HumanColor = 'W',
        ComputerColor = 'B'
    ; 
        write('You will be black'), nl,
        HumanColor = 'B',
        ComputerColor = 'W'
    ).
