-module(contacts_SUITE).
-include_lib("common_test/include/ct.hrl").
-compile(export_all).


all() ->
    [add_all_contacts, search_basic].

init_per_testcase(_, Config) ->
    mock_io(),
    % ct:print("Wow ~p~n", [4343]),
    {ok, Pid} = contacts_sup:start_link(),
    % ct:print("Wow ~p~n", [Pid]),
    [{pid, Pid} | Config].

end_per_testcase(_, Config) ->
    meck:unload(io),
    Pid = ?config(pid, Config),
    unlink(Pid),
    exit(Pid, shutdown).

mock_io() ->
    %% For this one we mock the IO system so that instead of
    %% printing messages and getting input to and from the user,
    %% we instead have a message-passing interface that will
    %% be inspectable.
    %%
    %% Note that because the `io` module is pre-compiled by the
    %% VM, we have to 'unstick' it first, and be careful to keep
    %% it mocked as little as possible.
    Parent = self(),
    code:unstick_dir(filename:dirname(code:where_is_file("io.beam"))),
    meck:new(io, [passthrough, no_link]),
    meck:expect(io, format, fun(Str) ->
        Parent ! {out, Str},
        ok
    end),
    meck:expect(io, format, fun(Str, Args) ->
        Parent ! {out, lists:flatten(io_lib:format(Str,Args))},
        ok
    end),
    meck:expect(io, get_line, fun(_Prompt) ->
        Parent ! {out, _Prompt},
        Parent ! {in, self()},
        receive {Parent, In} ->
            In
        end
    end).

%%%%%%%%%%%%%%%%%%
%%% TEST CASES %%%
%%%%%%%%%%%%%%%%%%

%% Pressing a given key through the message-passing interface
%% will yield expected output. There should be a prompt waiting
%% for a key.
%% All states can be cycled through using only Y/N answers.


% https://howistart.org/posts/erlang/1 Rocks
add_all_contacts(Config) ->
    out("Add.*"),
    in("1"),
    out("Enter name.*"),
    in("Mohit Munjani"),
    out("Add.*"),
    in("1"),
    out("Enter name.*"),
    in("Mohit HelpShift"),
    out("Add.*"),
    in("1"),
    out("Enter name.*"),
    in("HelpShift"),
    out("Add.*"),
    in("1"),
    out("Enter name.*"),
    in("Mohit CanCodeInErlang").

search_basic(Config) ->
    add_all_contacts(Config),
    out("Add.*"),
    in("2"),
    out("Search name.*"),
    in("Moh"),
    out("Mohit Munjani"),
    out("Mohit HelpShift"),
    out(".*Mohit.*Can").


%%%%%%%%%%%%%%%
%%% HELPERS %%%
%%%%%%%%%%%%%%%

in(Input) ->
    ct:print("Input: ~p~n", [Input]),
    receive
        {in, Pid} -> 
            % ct:print("Recepieved"),
            Pid ! {self(), Input}
    end.

%% fuzzily match the input string, waiting 1s at most
out(Expected) ->
    receive
        {out, Prompt} ->
            ct:print("Expected: ~p~nPrompt: ~p", [Expected, Prompt]),
            {match, _} = re:run(Prompt, Expected, [dotall, caseless, global])
    end.