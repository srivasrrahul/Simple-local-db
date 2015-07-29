%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc simpl_local_db.

-module(simpl_local_db).
-author("Mochi Media <dev@mochimedia.com>").
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.


%% @spec start() -> ok
%% @doc Start the simpl_local_db server.
start() ->
    simpl_local_db_deps:ensure(),
    ensure_started(crypto),
    application:start(simpl_local_db).


%% @spec stop() -> ok
%% @doc Stop the simpl_local_db server.
stop() ->
    application:stop(simpl_local_db).
