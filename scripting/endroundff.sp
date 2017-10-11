#pragma semicolon 1
#include <sourcemod>

#define PLUGIN_AUTHOR "Sgt. Gremulock"
#define PLUGIN_VERSION "1.3"

#define ENABLED "enabled"
#define DISABLED "disabled"

ConVar hConVars[5];
bool bEnabled, bChat, bCenter, bHint, bFF, bFFPlugin;

public Plugin myinfo = 
{
	name = "[TF2] End Round Friendly Fire",
	author = PLUGIN_AUTHOR,
	description = "Enables friendly fire at the end of the round and disables it on the start of the next round.",
	version = PLUGIN_VERSION,
	url = "sourcemod.net"
};

/* Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

public void OnPluginStart()
{
	CreateCmds();
	CreateCvars();
	HookEvents();

	LoadTranslations("endroundff.phrases");
}

public void Cvar_Update(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	UpdateCvars();
}

public void OnMapStart()
{
	UpdateCvars();
}

/* Commands ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

CreateCmds()
{
	RegAdminCmd("sm_toggle_endroundff", Command_ToggleEndRoundFF, ADMFLAG_GENERIC);
}

public Action Command_ToggleEndRoundFF(int client, int args)
{
	if (bEnabled)
	{
		bEnabled = false;
		ReplyToCommand(client, "[SM] Disabled end of round friendly fire.");

		return Plugin_Handled;
	}
	else if (!bEnabled)
	{
		bEnabled = true;
		ReplyToCommand(client, "[SM] Enabled end of round friendly fire.");

		return Plugin_Handled;
	}

	return Plugin_Handled;
}

/* Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	Announce_Disabled();
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	Announce_Enabled();
}

/* Stocks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

stock CreateCvars()
{
	CreateConVar("sm_endroundff_version", PLUGIN_VERSION, "Plugin's version.", FCVAR_NOTIFY|FCVAR_REPLICATED);
	hConVars[0] = CreateConVar("sm_endroundff_enable", "1", "Enable/disable the plugin.", _, true, 0.0, true, 1.0);
	hConVars[1] = CreateConVar("sm_endroundff_chat", "1", "Announce friendly fire changes in chat.", _, true, 0.0, true, 1.0);
	hConVars[2] = CreateConVar("sm_endroundff_center", "1", "Announce friendly fire changes with center text.", _, true, 0.0, true, 1.0);
	hConVars[3] = CreateConVar("sm_endroundff_hint", "1", "Announce friendly fire changes with hint text.", _, true, 0.0, true, 1.0);
	hConVars[4] = FindConVar("mp_friendlyfire");

	UpdateCvars();
	
	for (int i = 0; i < sizeof(hConVars); i++)
	{
		HookConVarChange(hConVars[i], Cvar_Update);
	}

	AutoExecConfig(true, "endroundff");	
}

stock UpdateCvars()
{
	bEnabled 	= hConVars[0].BoolValue;
	bChat 		= hConVars[1].BoolValue;
	bCenter 	= hConVars[2].BoolValue;
	bHint 		= hConVars[3].BoolValue;
	bFF			= hConVars[4].BoolValue;
}

stock HookEvents()
{
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("teamplay_round_win", Event_RoundEnd);	
}

stock Announce_Enabled()
{
	if (bEnabled)
	{
		if (!bFF)
		{
			bFFPlugin = true;

			if (bChat)
			{
				PrintToChatAll("[SM] %t", "EndRoundFF_Chat", ENABLED);
			}

			if (bCenter)
			{
				PrintCenterTextAll("%t", "EndRoundFF_Center", ENABLED);
			}

			if (bHint)
			{
				PrintHintTextToAll("%t", "EndRoundFF_Hint", ENABLED);
			}

			hConVars[4].SetBool(true);
		}
	}	
}

stock Announce_Disabled()
{
	if (bEnabled)
	{
		if (bFF && bFFPlugin)
		{
			bFFPlugin = false;

			if (bChat)
			{
				PrintToChatAll("[SM] %t", "EndRoundFF_Chat", DISABLED);
			}

			if (bCenter)
			{
				PrintCenterTextAll("%t", "EndRoundFF_Center", DISABLED);
			}

			if (bHint)
			{
				PrintHintTextToAll("%t", "EndRoundFF_Hint", DISABLED);
			}

			hConVars[4].SetBool(false);
		}
	}	
}
