-module(contacts).

-export([start_link/0, my_print/1, show_options/1]).
-export([get_response1/0, get_name/0, get_search_term/0]).

start_link() ->
    start().

start() ->
    % case Response of
    %   "1" ->
    %     {ok, [N]} = io:fread("Enter name:\n", "~d")
    % end
    % {ok,lol,lol}.
    {ok, ok, show_options([""])}.

get_response1() ->
  A = io:get_line("1) Add contact 2) Search 3) Exit\n"),
  string:strip(A, right, $\n).

get_name() ->
  B = io:get_line("Enter Name: "),
  string:strip(B, right, $\n).

get_search_term() ->
  C = io:get_line("Search Name: "),
  string:strip(C, right, $\n).

% show_options([]) ->
%   Response = get_response1(),
%   case Response of
%     "1" ->
%       Name = get_name(),
%       show_options([[Name]]);
%     "2" ->
%       Q = get_search_term(),
%       my_search(Q,[]),
%       show_options([]);

%     "3" ->
%       ok;
%     _ ->
%       io:fwrite("Please enter valid input"),
%       show_options([]),
%       ok
%   end;

show_options([H|T]) ->
  Response = get_response1(),
  A = H ++ T,
  my_print(A),
  case Response of
    "1" ->
      Name1 = get_name(),
      show_options([A|[Name1]]);
    "2" ->
      Q = get_search_term(),
      my_search(Q, A),
      show_options([A]);
    "3" ->
      ok;
    _ ->
      io:fwrite("Please enter valid input\n"),
      show_options([A]),
      ok
  end.

my_print([]) ->
  ok;

my_print([H1 | T1]) ->
  io:format("printing: ~p~n", [H1]),
  my_print(T1).

my_search(Q1,[]) ->
  ok;

my_search(Q2, [H2 | T2]) ->
  % Index = string:str(H1, Q1),
  % Lets count occurances
  H1 = string:to_lower(H2),
  T1 = string:to_lower(T2),
  Q1 = string:to_lower(Q2),
  Index = match(H1, Q1, Q1, 0),
  % io:format("searching:  index:~s term:~s  index ~n", [integer_to_list(Index), H1]),
  if Index =/= 0 ->
    io:format("~s occurances:~p~n", [H2,Index]);
    true -> ok
  end,
  my_search(Q1,T1).

% https://www.rosettacode.org/wiki/Count_occurrences_of_a_substring#Erlang
%% String and Sub exhausted, count a match and present result
match([], [], _OrigSub, Acc) ->
  Acc+1;

%% String exhausted, present result
match([], _Sub, _OrigSub, Acc) ->
  Acc;

%% Sub exhausted, count a match
match(String, [], Sub, Acc) ->
  match(String, Sub, Sub, Acc+1);

%% First character matches, advance
match([X|MainTail], [X|SubTail], Sub, Acc) ->
  match(MainTail, SubTail, Sub, Acc);

%% First characters do not match. Keep scanning for sub in remainder of string
match([_X|MainTail], [_Y|_SubTail], Sub, Acc)->
  match(MainTail, Sub, Sub, Acc).
