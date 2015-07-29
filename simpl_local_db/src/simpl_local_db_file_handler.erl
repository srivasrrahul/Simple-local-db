%%%-------------------------------------------------------------------
%%% @author Rahul
%%% @copyright (C) 2015, Self
%%% @doc
%%%
%%% @end
%%% Created : 28. Jul 2015 11:40 AM
%%%-------------------------------------------------------------------
-module(simpl_local_db_file_handler).
-author("Rahul").

%% API
-export([]).

-export([get/1,put/2,ensure_path/1]).


get_temp_file_name(Key) ->
  {A,B,C} = erlang:now(),
  TempFileName = Key ++ integer_to_list(A) ++ integer_to_list(B) ++ integer_to_list(C) ++ "_temp",
  TempFileName.

write_to_file(FileName,Value) ->
  case file:write_file(FileName,Value) of
    ok ->
      ok;
    {error,Reason} ->
      throw("Failed to open the file " ++ Reason)
  end.

move_file(Source,Destination) ->
  case file:rename(Source,Destination) of
    {error,Reason} ->
      error_logger:error_msg("Rename Error is ~p",[Reason]),
      error_logger:error_msg("Rename FileName is ~p",[Source,Destination]),
      throw("Failed to rename the file" ++ Reason);
    _ ->
      ok

  end.

read_file(FileName) ->
  case file:read_file(FileName) of
    {ok,Contents} ->
      binary_to_list(Contents);
    {error,Reason} ->
      throw("Failed to Read from the file " ++ Reason)

  end.

ensure_path(FileName) ->
  filelib:ensure_dir(FileName).

put(Key,Value) ->
  TempFileName = get_temp_file_name(Key),
  write_to_file(TempFileName,Value),
  move_file(TempFileName,Key).

get(Key) ->
  read_file(Key).



