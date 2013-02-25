%% Copyright (c) 2013 eZuce, Inc. All rights reserved.
%% Contributed to SIPfoundry under a Contributor Agreement
%%
%% This software is free software; you can redistribute it and/or modify it under
%% the terms of the Affero General Public License (AGPL) as published by the
%% Free Software Foundation; either version 3 of the License, or (at your option)
%% any later version.
%%
%% This software is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
%% FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
%% details.

-module(oacd_dialplan_listener).

-behaviour(gen_server).

-include("oadp_internal.hrl").

%% api
-export([
	start/0,
	start_link/0,
	stop/0,

	get_timeout/0,
	set_timeout/1
]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
	timeout_ms :: non_neg_integer()
}).

%% api

start() ->
	gen_server:start({local, ?MODULE}, ?MODULE, [], []).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
	gen_server:call(?MODULE, stop).

get_timeout() ->
	gen_server:call(?MODULE, get_timeout).

set_timeout(TMs) ->
	gen_server:cast(?MODULE, {set_timeout, TMs}).

%% gen_server callbacks

init([]) ->
	TMs = p_as_timeout_ms(p_get_env(timeout_ms, ?DEFAULT_TIMEOUT_MS)),
	{ok, #state{timeout_ms=TMs}}.

handle_call(stop, _From, State) ->
	{stop, normal, ok, State};
handle_call(get_timeout, _From, State) ->
	{reply, State#state.timeout_ms, State};
handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast({set_timeout, TMs}, State) ->
	{noreply, State#state{timeout_ms=p_as_timeout_ms(TMs)}};
handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info({freeswitch_sendmsg, "agent_login " ++ Login}, State) ->
	lager:info("Login request from fs: ~p", [Login]),
	case agent_manager:start_agent_by_login(Login) of
		{ok, P} ->
			{ok, Conn} = oadp_conn:start([{timeout_ms, State#state.timeout_ms}]),
			agent:set_connection(P, Conn),
			agent:go_available(P);
		{exists, P} ->
			agent:go_available(P);
		_ ->
			ok
	end,
	{noreply, State};
handle_info({freeswitch_sendmsg, "agent_logout " ++ Login}, State) ->
	lager:info("Logout request from fs: ~p", [Login]),
	case agent_manager:query_agent(Login) of
		{true, P} ->
			agent:stop(P);
		_ ->
			ok
	end,
	{noreply, State};
handle_info(_Msg, State) ->
	lager:debug("Unexpected msg: ~p", [_Msg]),
	{noreply, State}.


terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% internal

p_get_env(K, Def) ->
	case application:get_env(oacd_dialplan, K) of
		{ok, V} -> V;
		_ -> Def
	end.

p_as_timeout_ms(N) when is_integer(N), N > 0 -> N;
p_as_timeout_ms(_) -> none.