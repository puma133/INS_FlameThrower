#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>
#include <sdktools> 

int g_iplayerAttachmentTargetEntityRef[MAXPLAYERS+1] = {-1,...};
int g_iplayerWeaponAttachmentTargetEntityRef[MAXPLAYERS+1] = {-1,...};
int g_iplayerWeaponAttachmentFakeWeaponPropRef[MAXPLAYERS+1] = {-1,...};
int g_iPlayerLastUserID[MAXPLAYERS+1] = {-1,...};
int g_iPlayerLastWeapon[MAXPLAYERS+1] = {-1,...};
char g_iPlayerLastPlayerAttachment[MAXPLAYERS+1][32];
char g_iPlayerLastPlayerWeaponAttachment[MAXPLAYERS+1][32];
EngineVersion g_GameEngine;
char g_cPlayerWeaponAttachment[32];

#define EF_BONEMERGE                (1 << 0)
#define EF_NOSHADOW                 (1 << 4)
#define EF_NORECEIVESHADOW          (1 << 6)
#define EF_PARENT_ANIMATES          (1 << 9)
#define PLUGIN_VERSION              "2.0"
public Plugin myinfo = 
{
	name = "Weapon Attachment API",
	author = "Mitchell | 游而不擊 轉進如風",
	description = "Natives for attachments.",
	version = PLUGIN_VERSION,
	url = "http://mtch.tech"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("WA_GetPlayerAttachmentPos", Native_GetPlayerAttachmentPos);
	CreateNative("WA_GetPlayerWeaponAttachmentPos", Native_GetPlayerWeaponAttachmentPos);
	CreateNative("WA_SetParentToPlayerWeaponAttachment", Native_SetParentToPlayerWeaponAttachment);
	RegPluginLibrary("WeaponAttachmentAPI");
	return APLRes_Success;
}

public OnPluginStart()
{
	CreateConVar("sm_weapon_attachment_api_version", PLUGIN_VERSION, "Weapon Attachment API Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_GameEngine = GetEngineVersion();
	GetGameAttachPoint();
	HookEvent("player_death", Event_Death);
}
public void OnMapStart()
{
	PrecacheModel("models/error.mdl", true);
}

public OnPluginEnd()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			RemovePlayerAttachmentTargetEntity(i);
			RemovePlayerWeaponAttachmentTargetEntity(i);
		}
	}
}
//Do we even really need to remove the entity on death?
public Action Event_Death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientInGame(client)) {
		RemovePlayerAttachmentTargetEntity(client);
		RemovePlayerWeaponAttachmentTargetEntity(client);
	}
}

public GetGameAttachPoint()
{
	switch(g_GameEngine)
	{
		case Engine_CSS: g_cPlayerWeaponAttachment = "muzzle_flash";
		case Engine_TF2, Engine_DODS: g_cPlayerWeaponAttachment = "weapon_bone";
		case Engine_HL2DM: g_cPlayerWeaponAttachment = "chest";
		case Engine_Insurgency: g_cPlayerWeaponAttachment = "primary";
	}
}

public int Native_GetPlayerAttachmentPos(Handle plugin, int args)
{
	int client = GetNativeCell(1);
	bool result = false;
	if (NativeCheck_IsClientValid(client) && IsPlayerAlive(client))
	{
		char cAttachment[32];
		GetNativeString(2, cAttachment, 32);
		float fAngle[3];
		float fPosition[3];
		result = GetPlayerAttachmentPosition(client, cAttachment, fPosition, fAngle);
		SetNativeArray(3, fPosition, 3);
		if (args >= 4)
			SetNativeArray(4, fAngle, 3);
	}
	return result;
}
public bool GetPlayerAttachmentPosition(int client, char[] cAttachment, float fPosition[3], float fAngle[3])
{
	if (StrEqual(cAttachment, ""))
		return false;
	
	int iPlayerAttachmentTargetEntity = GetPlayerAttachmentTargetEntity(client);
	if (iPlayerAttachmentTargetEntity == INVALID_ENT_REFERENCE)
	{
		iPlayerAttachmentTargetEntity = CreatePlayerAttachmentTargetEntity(client);
		if (!IsValidEntity(iPlayerAttachmentTargetEntity))
			return false;
		
		g_iplayerAttachmentTargetEntityRef[client] = EntIndexToEntRef(iPlayerAttachmentTargetEntity);
	}
	
	int userid = GetClientUserId(client);
	if (g_iPlayerLastUserID[client] != userid || !StrEqual(cAttachment, g_iPlayerLastPlayerAttachment[client], false))
	{
		g_iPlayerLastUserID[client] = userid;
		strcopy(g_iPlayerLastPlayerAttachment[client], 32, cAttachment);
		
		AcceptEntityInput(iPlayerAttachmentTargetEntity, "ClearParent");
		SetParent(iPlayerAttachmentTargetEntity, client, cAttachment);
		TeleportEntity(iPlayerAttachmentTargetEntity, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);
	}
	
	GetEntPropVector(iPlayerAttachmentTargetEntity, Prop_Data, "m_vecAbsOrigin", fPosition);
	GetEntPropVector(iPlayerAttachmentTargetEntity, Prop_Data, "m_angAbsRotation", fAngle);
	return true;
}

public int Native_GetPlayerWeaponAttachmentPos(Handle plugin, args)
{
	int client = GetNativeCell(1);
	bool result = false;
	if (NativeCheck_IsClientValid(client) && IsPlayerAlive(client))
	{
		char cWeaponAttachment[32];
		GetNativeString(2, cWeaponAttachment, 32);
		float pos[3];
		result = GetPlayerWeaponAttachmentPosition(client, cWeaponAttachment, pos);
		SetNativeArray(3, pos, 3);
	}
	return result;
}
public bool GetPlayerWeaponAttachmentPosition(client, char[] cWeaponAttachment, float fPosition[3])
{
	if (StrEqual(cWeaponAttachment, ""))
		return false;
	
	int iWeaponAttachmentTargetEntity = GetPlayerWeaponAttachmentTargetEntity(client);
	if (iWeaponAttachmentTargetEntity == INVALID_ENT_REFERENCE)
	{
		iWeaponAttachmentTargetEntity = CreateWeaponAttachmentTargetEntity(client);
		if (!IsValidEntity(iWeaponAttachmentTargetEntity))
			return false;
		
		g_iplayerWeaponAttachmentTargetEntityRef[client] = EntIndexToEntRef(iWeaponAttachmentTargetEntity);
	}

	int iWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (iWeapon <= MaxClients && !IsValidEntity(iWeapon))
		return false;

	if (g_iPlayerLastWeapon[client] != iWeapon || !StrEqual(cWeaponAttachment, g_iPlayerLastPlayerWeaponAttachment[client], false))
	{
		//The position is different, need to relocate the entity.
		g_iPlayerLastWeapon[client] = iWeapon;
		strcopy(g_iPlayerLastPlayerWeaponAttachment[client], 32, cWeaponAttachment);
		AcceptEntityInput(iWeaponAttachmentTargetEntity, "ClearParent");
		
		char modelName[PLATFORM_MAX_PATH];
		//Setting the model's index will not update attachment names..
		findModelString(GetEntProp(iWeapon, Prop_Send, "m_iWorldModelIndex"), modelName, sizeof(modelName));
		int iFakeWeaponProp = GetPlayerWeaponAttachmentFakeWeaponProp(client);
		if (iFakeWeaponProp == INVALID_ENT_REFERENCE)
		{
			iFakeWeaponProp = CreateFakeWeaponProp(client);
			if (!IsValidEntity(iFakeWeaponProp))
				return false;
		}
		AcceptEntityInput(iFakeWeaponProp, "ClearParent");
		SetEntityModel(iFakeWeaponProp, modelName);
		SetParent(iFakeWeaponProp, client, g_cPlayerWeaponAttachment);
		iWeapon = iFakeWeaponProp;
		
		SetParent(iWeaponAttachmentTargetEntity, iWeapon, cWeaponAttachment);
		TeleportEntity(iWeaponAttachmentTargetEntity, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);
	}
	GetEntPropVector(iWeaponAttachmentTargetEntity, Prop_Data, "m_vecAbsOrigin", fPosition);
	return true;
}

public Native_SetParentToPlayerWeaponAttachment(Handle plugin, args)
{
	int client = GetNativeCell(1);
	bool result = false;
	if (NativeCheck_IsClientValid(client) && IsPlayerAlive(client))
	{
		int iEntity = GetNativeCell(2);
		if (iEntity > MaxClients && IsValidEntity(iEntity))
		{
			char cWeaponAttachment[32];
			GetNativeString(3, cWeaponAttachment, 32);
			SetParentToPlayerWeaponAttachment(client, iEntity, cWeaponAttachment);
		}
	}
	return result;
}
public bool SetParentToPlayerWeaponAttachment(int client, int iEntity, char[] cWeaponAttachment)
{
	if (StrEqual(cWeaponAttachment, ""))
		return false;
	
	AcceptEntityInput(iEntity, "ClearParent");

	int iWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (g_GameEngine == Engine_CSGO)
	{
		iWeapon = GetEntPropEnt(iWeapon, Prop_Send, "m_hWeaponWorldModel");
	}
	else
	{
		//Games other than CSGO, what a hassle.
		char cModelName[PLATFORM_MAX_PATH];
		//Setting the model's index will not update attachment names..
		findModelString(GetEntProp(iWeapon, Prop_Send, "m_iWorldModelIndex"), cModelName, sizeof(cModelName));
		int iFakeWeaponProp = GetPlayerWeaponAttachmentFakeWeaponProp(client);
		if (iFakeWeaponProp == INVALID_ENT_REFERENCE) 
		{
			iFakeWeaponProp = CreateFakeWeaponProp(client);
			if (!IsValidEntity(iFakeWeaponProp))
				return false;
		}
		AcceptEntityInput(iFakeWeaponProp, "ClearParent");
		SetEntityModel(iFakeWeaponProp, cModelName);
		SetParent(iFakeWeaponProp, client, g_cPlayerWeaponAttachment);
		iWeapon = iFakeWeaponProp;
	}
	SetParent(iEntity, iWeapon, cWeaponAttachment);
	TeleportEntity(iEntity, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);
	
	return true;
}

public CreatePlayerAttachmentTargetEntity(int client)
{
	RemovePlayerAttachmentTargetEntity(client);
	int iPlayerAttachmentTargetEntity = CreateEntityByName("info_target");
	DispatchSpawn(iPlayerAttachmentTargetEntity);
	return iPlayerAttachmentTargetEntity;
}
public CreateWeaponAttachmentTargetEntity(int client)
{
	RemovePlayerWeaponAttachmentTargetEntity(client);
	int iWeaponAttachmentTargetEntity = CreateEntityByName("info_target");
	DispatchSpawn(iWeaponAttachmentTargetEntity);
	g_iPlayerLastWeapon[client] = INVALID_ENT_REFERENCE;
	g_iPlayerLastPlayerWeaponAttachment[client] = "";
	if (g_GameEngine != Engine_CSGO)
	{
		int iFakeWeaponProp = CreateFakeWeaponProp(client);
		if (!IsValidEntity(iFakeWeaponProp))
			return false;
		g_iplayerWeaponAttachmentFakeWeaponPropRef[client] = EntIndexToEntRef(iFakeWeaponProp);
	}
	return iWeaponAttachmentTargetEntity;
}
public CreateFakeWeaponProp(int client)
{
	RemovePlayerWeaponAttachmentFakeWeaponProp(client);
	int iFakeWeaponProp = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(iFakeWeaponProp, "model", "models/error.mdl");
	DispatchKeyValue(iFakeWeaponProp, "disablereceiveshadows", "1");
	DispatchKeyValue(iFakeWeaponProp, "disableshadows", "1");
	DispatchKeyValue(iFakeWeaponProp, "solid", "0");
	DispatchKeyValue(iFakeWeaponProp, "spawnflags", "256");
	DispatchSpawn(iFakeWeaponProp);
	SetEntProp(iFakeWeaponProp, Prop_Send, "m_fEffects", 32|EF_BONEMERGE|EF_NOSHADOW|EF_NORECEIVESHADOW|EF_PARENT_ANIMATES);
	return iFakeWeaponProp;
}

public GetPlayerAttachmentTargetEntity(int client)
{
	if (IsValidEntity(EntRefToEntIndex(g_iplayerAttachmentTargetEntityRef[client])))
		return g_iplayerAttachmentTargetEntityRef[client];
	return INVALID_ENT_REFERENCE;
}
public GetPlayerWeaponAttachmentTargetEntity(int client)
{
	if (IsValidEntity(EntRefToEntIndex(g_iplayerWeaponAttachmentTargetEntityRef[client])))
		return g_iplayerWeaponAttachmentTargetEntityRef[client];
	return INVALID_ENT_REFERENCE;
}
public GetPlayerWeaponAttachmentFakeWeaponProp(int client)
{
	if (IsValidEntity(EntRefToEntIndex(g_iplayerWeaponAttachmentFakeWeaponPropRef[client])))
		return g_iplayerWeaponAttachmentFakeWeaponPropRef[client];
	return INVALID_ENT_REFERENCE;
}

public RemovePlayerAttachmentTargetEntity(int client)
{
	if (IsValidEntity(EntRefToEntIndex(g_iplayerAttachmentTargetEntityRef[client])))
		AcceptEntityInput(g_iplayerAttachmentTargetEntityRef[client], "Kill");
	
	g_iPlayerLastUserID[client] = -1;
}
public RemovePlayerWeaponAttachmentTargetEntity(int client)
{
	if (IsValidEntity(EntRefToEntIndex(g_iplayerWeaponAttachmentTargetEntityRef[client])))
		AcceptEntityInput(g_iplayerWeaponAttachmentTargetEntityRef[client], "Kill");
	RemovePlayerWeaponAttachmentFakeWeaponProp(client);
	g_iplayerWeaponAttachmentTargetEntityRef[client] = INVALID_ENT_REFERENCE;
	g_iPlayerLastWeapon[client] = INVALID_ENT_REFERENCE;
	g_iPlayerLastPlayerWeaponAttachment[client] = "";
}
public RemovePlayerWeaponAttachmentFakeWeaponProp(int client)
{
	if (IsValidEntity(EntRefToEntIndex(g_iplayerWeaponAttachmentFakeWeaponPropRef[client])))
		AcceptEntityInput(g_iplayerWeaponAttachmentFakeWeaponPropRef[client], "Kill");
	g_iplayerWeaponAttachmentFakeWeaponPropRef[client] = INVALID_ENT_REFERENCE;
}

public NativeCheck_IsClientValid(int client)
{
	if (client <= 0 || client > MaxClients)
		return ThrowNativeError(SP_ERROR_NATIVE, "Client index %i is invalid", client);
	if (!IsClientInGame(client))
		return ThrowNativeError(SP_ERROR_NATIVE, "Client %i is not in game", client);
	return true;
}

public SetParent(int child, int parent, char[] attachment)
{
	SetVariantString("!activator");
	AcceptEntityInput(child, "SetParent", parent, child, 0);
	if (!StrEqual(attachment, ""))
	{
		SetVariantString(attachment);
		AcceptEntityInput(child, "SetParentAttachment", child, child, 0);
	}
}

public int findModelString(int modelIndex, char[] modelString, int string_size)
{
	static int stringTable = INVALID_STRING_TABLE;
	if (stringTable == INVALID_STRING_TABLE)
	{
		stringTable = FindStringTable("modelprecache");
	}
	return ReadStringTable(stringTable, modelIndex, modelString, string_size);
}