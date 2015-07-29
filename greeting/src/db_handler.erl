%%%-------------------------------------------------------------------
%%% @author rasrivastava
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Jul 2015 12:51 PM
%%%-------------------------------------------------------------------
-module(db_handler).
-author("rasrivastava").

%% API
-export([db_start/0]).
-define(DB_ADDRESS,"http://127.0.0.1:5984").
-define(DB_NAME,"transactions").

init() ->
  inets:start(),
  io:format("Inet module start"),
  create_db().

form_db_name() ->
  ?DB_ADDRESS ++ "/" ++ ?DB_NAME.

form_key(Key) ->
  Url = form_db_name() ++ "/" ++ Key,
  Url.



create_db() ->
  httpc:request(put,{form_db_name(),[],"",""},[],[{sync,true}]).

add_val(Key,Value) ->
  case httpc:request(put,{form_key(Key),[],"application/json",Value},[],[{sync,true}]) of
    {ok,Result} ->
      io:format("Db write returned ok ~p~n",[Result]),
      ok;
    {error,Reason} ->
      error;
    _ ->
      io:format("Default Clause")
  end.

get_val(Key) ->
  case httpc:request(form_key(Key)) of
    {ok,{StatusCode,_,Body}}
      -> {StatusCode,Body};
    {error,Reason}
      ->error
  end.

db_handler() ->
  receive
    {CallerPid,add,Key,Value} ->
      io:format("Db write recieved ~n"),
      Res = add_val(Key,Value),
      CallerPid ! Res,
      db_handler();
    {CallerPid,get,Key} ->
      io:format("Db read recieved ~n"),
      Res = get_val(Key),
      CallerPid ! Res,
      db_handler()
  end.

db_start() ->
  init(),
  db_handler().




