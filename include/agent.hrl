%%	The contents of this file are subject to the Common Public Attribution
%%	License Version 1.0 (the “License”); you may not use this file except
%%	in compliance with the License. You may obtain a copy of the License at
%%	http://opensource.org/licenses/cpal_1.0. The License is based on the
%%	Mozilla Public License Version 1.1 but Sections 14 and 15 have been
%%	added to cover use of software over a computer network and provide for
%%	limited attribution for the Original Developer. In addition, Exhibit A
%%	has been modified to be consistent with Exhibit B.
%%
%%	Software distributed under the License is distributed on an “AS IS”
%%	basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%	License for the specific language governing rights and limitations
%%	under the License.
%%
%%	The Original Code is Spice Telephony.
%%
%%	The Initial Developers of the Original Code is 
%%	Andrew Thompson and Micah Warren.
%%
%%	All portions of the code written by the Initial Developers are Copyright
%%	(c) 2008-2009 SpiceCSM.
%%	All Rights Reserved.
%%
%%	Contributor(s):
%%
%%	Andrew Thompson <athompson at spicecsm dot com>
%%	Micah Warren <mwarren at spicecsm dot com>
%%

%% @hidden
-type(endpoints() :: 'sip_registration' | 'sip' | 'iax2' | 'h323' | 'pstn').

-record(agent, {
	login = erlang:error({undefined, login}) :: string(),
	skills = [english, '_agent', '_node'] :: [atom(), ...],
	connection :: pid(),
	profile = "Default" :: string(),
	password = "" :: string(),
	state = released :: 'idle' | 'ringing' | 'precall' | 'oncall' | 'outgoing' | 'released' | 'warmtransfer' | 'wrapup',	
	statedata = default ::	{} |		% when state is released
						#call{} |	% when state is ringing, oncall, outgoing, or wrapup
						any() |	% state = precall
						{integer(), -1} | {integer(), 0} | {integer(), 1} | default |	% released
						{onhold, #call{}, calling, string()},	% warmtransfer
	queuedrelease :: any(),	% is the current state is to go to released, what is the released type
	lastchangetimestamp = now() :: any(),	% at what time did the last state change occur
	defaultringpath = inband :: 'inband' | 'outband',
	endpointtype = sip_registration :: endpoints(),
	endpointdata = undefined :: 'undefined' | string(),
	start_opts = [] :: [any()],
	log_pid :: 'undefined' | pid()
}).
	
%% 10/10/2008 Micah
%% statedata's structure is dependant on the state atom.
%% proposed structures:
%% idle :: {}
%% ringing :: #call{}
%% precall :: #client{}
%% oncall :: #call{}
%% outgoing :: #call{}
%% released :: {int(), -1 } | {int(), 0} | {int(), 1} | default
%% warmtransfer :: {onhold, #call{}, calling, string()},
%% wrapup :: #call{}

-type(security_level() :: 'agent' | 'supervisor' | 'admin').
-type(statename() :: 'idle' | 'ringing' | 'precall' | 'oncall' | 'outgoing' | 'released' | 'warmtransfer' | 'wrapup').

-record(agent_auth, {
	login :: string(),
	password :: string(),
	skills = [english, '_agent', '_node'] :: [atom()],
	securitylevel = agent :: security_level(),
	integrated :: 'undefined' | pos_integer(),
	profile = "Default" :: string(),
	firstname = "" :: string(),
	lastname = "" :: string(),
	timestamp = util:now() :: pos_integer()
}).

-record(agent_profile, {
	name = erlang:error({undefined, name}) :: string(),
	skills = [] :: [atom()],
	timestamp = util:now() :: pos_integer()
}).

-define(DEFAULT_PROFILE, #agent_profile{name = "Default", timestamp = util:now()}).

-record(release_opt, {
	label :: string(),
	id :: pos_integer(),
	bias = 0 :: -1 | 0 | 1,
	timestamp = util:now() :: pos_integer()
	}).

-record(agent_state, {
	agent :: string(),
	state :: statename(),
	statedata :: any(),
	start :: integer(),
	ended :: 'undefined' | integer(),
	timestamp = util:now() :: integer(),
	nodes :: [atom()]
}).