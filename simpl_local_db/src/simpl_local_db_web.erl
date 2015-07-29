%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc Web server for simpl_local_db.

-module(simpl_local_db_web).
-author("Mochi Media <dev@mochimedia.com>").

-export([start/1, stop/0, loop/2]).

%% External API

start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

get_key(ParsedUriArgs) ->

  case proplists:get_value("key",ParsedUriArgs) of
    undefined ->
      throw("Invalid Request in url");
    Value ->
      Value
  end.


get_value(ParsedUriArgs) ->
  case proplists:get_value("value",ParsedUriArgs) of
    undefined ->
      throw("Invalid Request in url");
    Value ->
      Value
  end.


get_key_value(ParsedUriArgs) ->
  Key = get_key(ParsedUriArgs),
  Val = get_value(ParsedUriArgs),
  {Key,Val}.

loop(Req, DocRoot) ->
    "/" ++ Path = Req:get(path),
    error_logger:error_msg("Path is  ~p",[Path]),
    try
      case Req:get(method) of
        'GET' ->
          QueryStringData = Req:parse_qs(),
          Key = get_key(QueryStringData),
          FilePath = simple_local_db_storage_policy:get_path_from_key(Key),
          error_logger:error_msg("QueryString data is ~p",[QueryStringData]),
          Value = simpl_local_db_file_handler:get(FilePath),
          Req:respond({200, [{"Content-Type", "text/plain"}], Value});
        'POST' ->
          QueryStringData = Req:parse_qs(),
          {Key,Value} = get_key_value(QueryStringData),
          FilePath = simple_local_db_storage_policy:get_path_from_key(Key),
          error_logger:error_msg("Path is ~p",[FilePath]),
          simpl_local_db_file_handler:ensure_path(FilePath),
          simpl_local_db_file_handler:put(FilePath,Value),
          Req:respond({200, [{"Content-Type", "text/plain"}], "Value updated successfully"});
        _ ->
          Req:respond({501, [], []})
      end
    catch
      Type:What ->
        Report = ["web request failed",
          {path, Path},
          {type, Type}, {what, What},
          {trace, erlang:get_stacktrace()}],
        error_logger:error_report(Report),
        Req:respond({503, [{"Content-Type", "text/plain"}],
          "request failed, sorry\n"})
    end.





get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.

%%
%% Tests
%%
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

you_should_write_a_test() ->
    ?assertEqual(
       "No, but I will!",
       "Have you written any tests?"),
    ok.

-endif.
