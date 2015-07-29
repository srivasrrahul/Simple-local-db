%% @author Mochi Media <dev@mochimedia.com>
%% @copyright 2010 Mochi Media <dev@mochimedia.com>

%% @doc Web server for greeting.

-module(greeting_web).
-author("Mochi Media <dev@mochimedia.com>").

-export([start/1, stop/0, loop/3]).

%% External API

start(Options) ->
    PidLst = init_rules(),
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot,PidLst)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

%% start all rules processes
init_rules() ->
  PidLst = rules:start_all_rules(),
  PidLst.

get_response(OldVal,_,_,0) ->
  OldVal;
get_response(OldVal,StartTime,TotalTime,PendingResponses) ->
  T1 = os:timestamp(),
  Diff = round(timer:now_diff(T1,StartTime)/1000),
  error_logger:error_msg("Diff is ~p",[Diff]),
  case Diff of
    X when TotalTime > X ->
      OldVal
  end,

  TimeAllowedToWait = round(TotalTime - (timer:now_diff(T1,StartTime)/1000)),
  error_logger:error_msg("Diff is ~p",[TimeAllowedToWait]),
  receive
    Val ->
      UpdatedVal = OldVal + Val,
      UpdatedResponseCount = PendingResponses-1,
      get_response(UpdatedVal,StartTime,TotalTime,UpdatedResponseCount)
  after TimeAllowedToWait->
    OldVal
  end.



process_request(Body,PidLst) ->
  {struct,JsonData} = mochijson2:decode(Body),
  %%error_logger:error_msg("Json Data is ~p",[JsonData]),
  %%Name = proplists:get_value(<<"Name">>,JsonData),
  %%error_logger:error_msg("Message is ~p",[Name]).
  lists:map(fun (Pid) ->
                 Pid ! {self(),JsonData}
            end,
            PidLst),

  %%Reply in 1 second

  ResponseCoeffecient = get_response(0,os:timestamp(),1000,length(PidLst)),
  ResponseCoeffecient/length(PidLst).

handle_message(Req,Body,PidList) ->
  RequestCoeffecient = process_request(Body,PidList),

  ResponseJson = mochijson2:encode({struct,[{<<"Coeff">>,RequestCoeffecient}]}),
  error_logger:error_msg("Response is ~p",[ResponseJson]),
  Req:ok({"application/json",[],[ResponseJson]}).
  %%send response

loop(Req, DocRoot,PidLst) ->
    "/" ++ Path = Req:get(path),
    try
        case Req:get(method) of
            Method when Method =:= 'GET'; Method =:= 'HEAD' ->

                case Path of
                    _ ->
                        Req:serve_file(Path, DocRoot)
                end;
            'POST' ->
              Body = Req:recv_body(),
              handle_message(Req,Body,PidLst),

                case Path of
                    _ ->
                        Req:not_found()
                end;
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
            Req:respond({500, [{"Content-Type", "text/plain"}],
                         "request failed, sorry\n"})
    end.

%% Internal API

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
