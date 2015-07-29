%% @author Mochi Media <dev@mochimedia.com>
%% @copyright simpl_local_db Mochi Media <dev@mochimedia.com>

%% @doc Callbacks for the simpl_local_db application.

-module(simpl_local_db_app).
-author("Mochi Media <dev@mochimedia.com>").

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for simpl_local_db.
start(_Type, _StartArgs) ->
    simpl_local_db_deps:ensure(),
    simpl_local_db_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for simpl_local_db.
stop(_State) ->
    ok.
