%%%-------------------------------------------------------------------
%%% @author rasrivastava
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Jul 2015 5:11 PM
%%%-------------------------------------------------------------------
-module(rules).
-author("rasrivastava").

%% API
-export([start_all_rules/0,test/0,create_processes_for_all_rules/2,name_basic_check/0]).
-define(CUSTOMER_NAME,customer_name).

create_processes_for_all_rules([Rule|RulesTable],Lst) ->
  Pid = spawn(Rule),
  create_processes_for_all_rules(RulesTable,[Pid|Lst]);

create_processes_for_all_rules([],Lst) ->
  Lst.

start_all_rules() ->
  Rules = get_all_stored_rules(),
  RulesPids = create_processes_for_all_rules(Rules,[]),
  RulesPids.

get_all_stored_rules() ->
  Rule = [],
  Rule1 = add_name_based_check(Rule),
  Rule1.

name_basic_check() ->
  receive
    {Caller,Context} ->
      case proplists:get_value(<<"Name">>,Context,undefined) of
        undefined ->
          Caller ! -1;
        _ ->
          error_logger:error_msg("Name recieved"),
          Caller ! 1

      end,
      name_basic_check()
  end.

  %No name present is problem



add_name_based_check(Lst) ->
  UpdatedLst = lists:append(Lst,[fun rules:name_basic_check/0]),
  UpdatedLst.


test() ->
  Rules = start_all_rules().
%%   D = dict:new(),
%%   D1 = dict:append(?CUSTOMER_NAME,rahul,D),
%%   lists:map(fun(X) -> X(D1) end , Rules).
