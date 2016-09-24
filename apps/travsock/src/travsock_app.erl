%%%-------------------------------------------------------------------
%% @doc travsock public API
%% @end
%%%-------------------------------------------------------------------

-module(travsock_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
        {'_', [
                {"/", travsock_handler, []}
        ]}
    ]),
    PrivDir = code:priv_dir(travsock),
    {ok, _} = cowboy:start_clear(http, 100, [{port, 8442}], #{
            env => #{dispatch => Dispatch}
    }),
    io:format("Start http Server : http://localhost:8442/~n",[]),
    {ok, _} = cowboy:start_tls(https, 100, [
		{port, 8443},
		{cacertfile, PrivDir ++ "/ssl/cowboy-ca.crt"},
		{certfile, PrivDir ++ "/ssl/server.crt"},
		{keyfile, PrivDir ++ "/ssl/server.key"}
	], #{env => #{dispatch => Dispatch}}),
    io:format("Start https Server : https://localhost:8443/~n",[]),
    travsock_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
