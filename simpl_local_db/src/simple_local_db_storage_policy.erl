%%%-------------------------------------------------------------------
%%% @author Rahul
%%% @copyright (C) 2015, Self
%%% @doc
%%%
%%% @end
%%% Created : 29. Jul 2015 10:28 AM
%%%-------------------------------------------------------------------
-module(simple_local_db_storage_policy).
-author("Rahul").

%% API
-export([get_path_from_key/1]).

get_levels() -> 10.

get_record_size_each_directory() -> 10001.

get_storage_file_path() ->
  "/Users/rasrivastava/DB_FILES".

get_hashed_val_level([],_,H) ->
  H;
get_hashed_val_level([X|Y],Level,H) ->
  get_hashed_val_level(Y,Level,H*Level + X).

%%based on bernestein hash
get_hash_val(_,MaxLevel,MaxLevel,PathTillNow) ->
  PathTillNow;
get_hash_val(Key,CurrentLevel,MaxLevel,PathTillNow) ->
  CurrentHash = get_hashed_val_level(Key,33-CurrentLevel,0),
  LookupVal = CurrentHash rem get_record_size_each_directory(),
  get_hash_val(Key,CurrentLevel+1,MaxLevel,PathTillNow++"/"++integer_to_list(LookupVal)).

get_path_from_key(Key) ->
  get_hash_val(Key,0,get_levels(),get_storage_file_path()) ++ "/" ++ Key.








