public Plugin myinfo = 
{
    name = "FlameThrower",
    author = "游而不擊 轉進如風",
    description = "FlameThrower for insurgency",
    version = "public 1.0",
    url = "https://github.com/gandor233"
};

#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <WeaponAttachmentAPI>

// Team
#define NO_TEAM 0
#define TEAM_SPEC 1
#define TEAM_1_SEC 2
#define TEAM_2_INS 3
#define TEAM_ALL 4
#define MAX_TEAM 5
// Game mode
#define MAX_GAME_MODE_CLASS 	2
#define MAX_GAME_MODE 			20
#define GAME_MODE_CLASS_DISABLE -1
#define GAME_MODE_CLASS_PVE 	0
#define GAME_MODE_CLASS_PVP 	1
#define GAME_MODE_CHECKPOINT 	0
#define GAME_MODE_HUNT 			1
#define GAME_MODE_CONQUER 		2
#define GAME_MODE_OUTPOST 		3
#define GAME_MODE_SURVIVAL 		4
#define GAME_MODE_PUSH	 		5
#define GAME_MODE_AMBUSH 		6
#define GAME_MODE_BATTLE 		7
#define GAME_MODE_ELIMINATION 	8
#define GAME_MODE_FIREFIGHT 	9
#define GAME_MODE_FLASHPOINT 	10
#define GAME_MODE_INVASION 		11
#define GAME_MODE_INFILTRATE 	12
#define GAME_MODE_OCCUPY 		13
#define GAME_MODE_SKIRMISH 		14
#define GAME_MODE_STRIKE 		15
#define GAME_MODE_VENDETTA 		16
#define GAME_MODE_ARMSRACE 		17
#define GAME_MODE_DEATHMATCH 	18
#define GAME_MODE_DEMOLITION 	19
// Player input
#define MAX_BUTTONS 		32
#define INPUT_ATTACK 		(1 << 0)     //  (鼠左)		开火
#define INPUT_JUMP 			(1 << 1)     //  (空格)		跳
#define INPUT_DUCK 			(1 << 2)     //  (CTRL)		蹲下
#define INPUT_PRONE 		(1 << 3)     //  (Z)		趴下 prostrate
#define INPUT_FORWARD 		(1 << 4)     //  (W)		向前移动
#define INPUT_BACKWARD 		(1 << 5)     //  (S)		向后移动
#define INPUT_USE 			(1 << 6)     //  (F)		使用
#define INPUT_MOVELEFT 		(1 << 9)     //  (A)		向左移动
#define INPUT_MOVERIGHT 	(1 << 10)    //  (D)		向右移动
#define INPUT_RELOAD 		(1 << 11)    //  (R)		换弹
#define INPUT_FIREMODE 		(1 << 12)    //  (X)		开火模式
#define INPUT_LEANLEFT 		(1 << 13)    //  (Q)		左侧身
#define INPUT_LEANRIGHT 	(1 << 14)    //  (E)		右侧身
#define INPUT_SPRINT 		(1 << 15)    //  (SHIFT)	屏息、冲刺跑（按住）
#define INPUT_WALK 			(1 << 16)    //  (ALT)		静步（按住）
#define INPUT_MOUSE3 		(1 << 17)    //  (鼠中)		特殊开火
#define INPUT_AIM 			(1 << 18)    //  (鼠右)		瞄准（按住）
#define INPUT_TAB 			(1 << 19)    //  (TAB)		排名
#define INPUT_BULLRUSH 		(1 << 22)    //  (G)		手电筒、激光
#define INPUT_WALK_L 		(1 << 25)    //  (ALT)		静步（切换）
#define INPUT_SPRINT_L 		(1 << 26)    //  (SHIFT)	屏息、冲刺跑（切换）
#define INPUT_AIM_L 		(1 << 27)    //  (鼠右)		瞄准（切换）
#define INPUT_ACCESSORY 	(1 << 28)    //  (B)		使用配件(夜视仪)
#define INPUT_ATTITUDE 		(1 << 29)    //  ()	        改变姿态
// Player Flags
#define INS_PF_AIM	 			(1 << 0)		// 0瞄准				// 1		// Force to zoom
#define INS_PF_BIPOD 			(1 << 1)		// 1脚架				// 2		// It could be ducking but massive buggy to use
#define INS_PF_RUN 				(1 << 2)		// 2跑步				// 4		// Force to run if keep setting this, player cant normal walk or slow walk
#define INS_PF_WALK 			(1 << 3)		// 3静步				// 8		// Force to walk only but player still can run just cannot normal walking
#define INS_PF_4 				(1 << 4)		// 4					// 16		//
#define INS_PF_FOCUS 			(1 << 5)		// 5屏息				// 32		// Zoom Focus (Buggy)
#define INS_PF_SLIDE 			(1 << 6)		// 6滑行				// 64		// Force to sliding, if you keep setting this, player forever sliding lol
#define INS_PF_BUYZONE 			(1 << 7)		// 7购买区				// 128		// Buyzone, Resupply everywhere! (Note: Buyzone makes no friendlyfire damage)
#define INS_PF_8 				(1 << 8)		// 8出生并离开过出生区域// 256		//
#define INS_PF_BLOCKZONE 		(1 << 9)		// 9禁区				// 512		// Restricted Zone, Player will be restricted, (Note: This flag applied with INS_PF_LOWERZONE)
#define INS_PF_PUTDOWNWEAPON 	(1 << 10)		// 10强制放下武器		// 1024		// Weapon Lower Zone
#define INS_PF_SPAWNZONE 		(1 << 11)		// 11出生区				// 2048		// ENTER SPAWN ZONE (Also can resupply)
#define INS_PF_12 				(1 << 12)		// 12					// 4096		//

ConVar DEBUG = null;
ConVar sm_flamethrower_range;
ConVar sm_flamethrower_angle;
ConVar sm_flamethrower_burn_time;
int g_iPlayerFireEntityRef[MAXPLAYERS+1];
public void OnPluginStart()
{
    DEBUG = CreateConVar("sm_flamethrower_debug", "0", "");
    sm_flamethrower_range = CreateConVar("sm_flamethrower_range", "700.0", "");
    sm_flamethrower_angle = CreateConVar("sm_flamethrower_angle", "36.0", "");
    sm_flamethrower_burn_time = CreateConVar("sm_flamethrower_burn_time", "5.0", "");
    HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Post);
    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    RemoveAllClientFlamethrowerFire();

    MoreFire_OnPluginStart();
    return;
}
public void OnAllPluginsLoaded()
{
    PrecacheFile();
    return;
}
public void OnPluginEnd()
{
    RemoveAllClientFlamethrowerFire();
    return;
}
public void OnClientPutInServer(int client) 
{
    MoreFire_OnClientPutInServer(client);
    return;
}
public void OnClientDisconnect(int client)
{
    RemoveClientFlamethrowerFire(client);
    return;
}
public void OnMapStart()
{
    PrecacheFile();
    
    // CreateTimer(2.0, CheckPlayerWeapon_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    CreateTimer(0.3, CheckPlayerFlamethrowerFire_Timer, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    
    GameMode_OnMapStart();
    return;
}
public void OnMapEnd()
{
    GameMode_OnMapEnd();
    return;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client))
    {
        RemoveClientFlamethrowerFire(client);
    }
    
    return;
}
public void Event_WeaponFire(Event event, char[] name, bool Broadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client) && (IsFakeClient(client) || !IsClientTimingOut(client)))
    {
        if (!IsClientFlamethrowerFireActive(client))
        {
            int iWeaponID = GetPlayerActiveWeapon(client);
            if (iWeaponID > MaxClients && IsValidEntity(iWeaponID))
            {
                char cWeaponName[256];
                GetEntityClassname(iWeaponID, cWeaponName, sizeof(cWeaponName));
                if (StrContains(cWeaponName, "weapon_flamethrower", false) > -1)
                {
                    if (DEBUG.BoolValue)
                        PrintToServer("RequestFrame client %d | StartClientFlamethrowerFire", client);
                    RequestFrame(StartClientFlamethrowerFire, GetClientUserId(client));
                }
            }
        }
    }
    
    return;
}
public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
    if (client <= 0 || client > MaxClients)
        return;
    
    if (IsClientFlamethrowerFireActive(client))
    {
        if (!(buttons & INPUT_ATTACK) || !IsClientInGame(client) || !IsPlayerAlive(client) || !IsClientInPlayerTeam(client)
        || IsPlayerDeploying(client) || IsPlayerForcedToPuttingDownWeapon(client) || (!IsFakeClient(client) && IsClientTimingOut(client)))
        {
            StopClientFlamethrowerFire(client);
            return;
        }
        
        int iWeaponID = GetPlayerActiveWeapon(client);
        if (iWeaponID <= MaxClients || !IsValidEntity(iWeaponID))
        {
            StopClientFlamethrowerFire(client);
            return;
        }
        
        if (GetClipCount(client, iWeaponID) <= 0)
        {
            StopClientFlamethrowerFire(client);
            return;
        }
        
        char cWeaponName[256];
        GetEntityClassname(iWeaponID, cWeaponName, sizeof(cWeaponName));
        if (StrContains(cWeaponName, "weapon_flamethrower", false) < 0)
        {
            RemoveClientFlamethrowerFire(client);
            return;
        }
    }
    
    // else
    // {
    // 	if (bIsFlamethrower && GetClipCount(client, iWeaponID) > 0)
    // 	{
    // 		iFireEntity = CreateClientFlamethrowerFire(client);
    // 		g_iPlayerFireEntityRef[client] = EntIndexToEntRef(iFireEntity);
    // 	}
    // }
    
    return;
}
// public Action CheckPlayerWeapon_Timer(Handle timer, any data)
// {
// 	for (int client = 1; client <= MaxClients; client++)
// 	{
// 		if (IsClientInGame(client))
// 		{
// 			if (IsPlayerHaveWeaponName(client, "weapon_flamethrower_"))
// 				SetClientSpeed(client, 0.8);
// 			else
// 				SetClientSpeed(client, 1.0);
// 		}
// 	}
// 	return Plugin_Continue;
// }
public Action CheckPlayerFlamethrowerFire_Timer(Handle timer, any data)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client))
        {
            int iFireEntity = EntRefToEntIndex(g_iPlayerFireEntityRef[client]);
            if (iFireEntity > MaxClients && IsValidEntity(iFireEntity) && IsClientFlamethrowerFireActive(client))
            {
                float fClientPosition[3];
                GetClientAbsOrigin(client, fClientPosition);
                
                if (GetGameModeClass() == GAME_MODE_CLASS_PVE)
                {
                    for (int clients = 1; clients <= MaxClients; clients++)
                    {
                        if (IsClientInGame(clients) && clients != client)
                        {
                            if (CanClientBurnClient(client, clients))
                            {
                                float fDistance = GetDistance_ClientToPosition(clients, fClientPosition);
                                if (fDistance < 200)
                                    CreateHurt(client, clients, 80, iFireEntity, "entityflame_flamethrower", DMG_BURN|DMG_BLAST);
                                else if (fDistance < 400)
                                    CreateHurt(client, clients, 30, iFireEntity, "entityflame_flamethrower", DMG_BURN|DMG_BLAST);
                                else
                                    CreateHurt(client, clients, 15, iFireEntity, "entityflame_flamethrower", DMG_BURN|DMG_BLAST);
                                BurnPlayer(client, clients, sm_flamethrower_burn_time.FloatValue); 
                            }
                        }
                    }
                }
                else
                {
                    for (int clients = 1; clients <= MaxClients; clients++)
                    {
                        if (IsClientInGame(clients) && clients != client)
                        {
                            if (CanClientBurnClient(client, clients))
                            {
                                float fDistance = GetDistance_ClientToPosition(clients, fClientPosition);
                                if (fDistance < 200)
                                    CreateHurt(client, clients, 90, iFireEntity, "entityflame_flamethrower", DMG_BURN|DMG_BLAST);
                                else if (fDistance < 400)
                                    CreateHurt(client, clients, 60, iFireEntity, "entityflame_flamethrower", DMG_BURN|DMG_BLAST);
                                else
                                    CreateHurt(client, clients, 30, iFireEntity, "entityflame_flamethrower", DMG_BURN|DMG_BLAST);
                                BurnPlayer(client, clients, sm_flamethrower_burn_time.FloatValue); 
                            }
                        }
                    }
                }

                int iEntityID;
                float fClientEyeAngles[3];
                float fClientEyePosition[3];
                GetClientEyeAngles(client, fClientEyeAngles);
                GetClientEyePosition(client, fClientEyePosition);
                Handle trace = TR_TraceRayFilterEx(fClientEyePosition, fClientEyeAngles, CONTENTS_SOLID|CONTENTS_MOVEABLE , RayType_Infinite, TraceEntityFilter_ExceptClientAndSelf, client);
                if (TR_DidHit(trace))
                {
                    iEntityID = TR_GetEntityIndex(trace);
                }
                CloseHandle(trace);
                
                if (iEntityID > MaxClients && IsValidEntityEx(iEntityID) && GetEntitiesDistance(client, iEntityID) < 500.0)
                {
                    // char cEntityName[128];
                    // GetEdictClassname(iEntityID, cEntityName, sizeof(cEntityName));
                    // PrintToChatAll("entity %d %s", iEntityID, cEntityName);
                    CreateHurt(client, iEntityID, 60, iFireEntity, "entityflame_flamethrower", DMG_BURN|DMG_BLAST);
                }
                
                float fClientAimingPosition[3];
                trace = TR_TraceRayFilterEx(fClientEyePosition, fClientEyeAngles, CONTENTS_SOLID|CONTENTS_MOVEABLE , RayType_Infinite, TraceEntityFilter_OnlyWorld, client);
                if (TR_DidHit(trace))
                {
                    TR_GetEndPosition(fClientAimingPosition, trace);
                }
                CloseHandle(trace);

                float iClientAimTargetDistance = GetVectorDistance(fClientEyePosition, fClientAimingPosition);
                if (iClientAimTargetDistance < 50.0)
                {
                    // if (!StrEqual(cEntityName, "ins_foliage", false)) // 用了 TraceEntityFilter_OnlyWorld 就不需要了
                    // {
                    CreateHurt(client, client, 20, iFireEntity, "entityflame_flamethrower", DMG_BURN|DMG_BLAST);
                    BurnPlayer(client, client, sm_flamethrower_burn_time.FloatValue); 
                    // }
                }
            }
        }
    }

    return Plugin_Continue;
}

public void GiveClientFlamethrowerFire(int userid)
{
    int client = GetClientOfUserId(userid);
    if (IsValidClient(client))
    {
        RemoveClientFlamethrowerFire(client);
        int iFireEntity = CreateClientFlamethrowerFire(client);
        g_iPlayerFireEntityRef[client] = EntIndexToEntRef(iFireEntity);
        
        if (DEBUG.BoolValue)
            PrintToServer("GiveClientFlamethrowerFire info_particle_system %d", iFireEntity);
    }
    return;
}
public void RemoveAllClientFlamethrowerFire()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        RemoveClientFlamethrowerFire(client);
    }
    return;
}
public void RemoveClientFlamethrowerFire(int client)
{
    int iFireEntity = EntRefToEntIndex(g_iPlayerFireEntityRef[client]);
    if (iFireEntity > MaxClients && IsValidEntity(iFireEntity))
    {
        if (DEBUG.BoolValue)
            PrintToServer("KillEntityEx info_particle_system %d | m_hOwnerEntity %d", iFireEntity, client);
        KillEntityEx(EntRefToEntIndex(g_iPlayerFireEntityRef[client]));
    }
    
    char cClassname[256];
    for (int iEntityID = MaxClients; iEntityID <= GetMaxEntities(); iEntityID++)
    {
        if (IsValidEntity(iEntityID))
        {
            GetEntityClassname(iEntityID, cClassname, sizeof(cClassname));
            if (StrContains(cClassname, "info_particle_system", false) > -1)
            {
                if (GetEntPropEnt(iEntityID, Prop_Data, "m_hOwnerEntity") == client)
                {
                    if (DEBUG.BoolValue)
                        PrintToServer("KillEntityEx info_particle_system %d | m_hOwnerEntity %d", iEntityID, client);
                    KillEntityEx(EntRefToEntIndex(g_iPlayerFireEntityRef[client]));
                }
            }
        }
    }
    
    return;
}
public void StartClientFlamethrowerFire(int userid)
{
    int client = GetClientOfUserId(userid);
    if (IsValidClient(client))
    {
        int iFireEntity = EntRefToEntIndex(g_iPlayerFireEntityRef[client]);
        if (iFireEntity > MaxClients && IsValidEntity(iFireEntity))
        {
            if (DEBUG.BoolValue)
                PrintToServer("StartClientFlamethrowerFire info_particle_system %d | Start", iFireEntity);
            AcceptEntityInput(iFireEntity, "Start");
        }
        else
        {
            GiveClientFlamethrowerFire(userid);
        }
    }
    return;
}
public void StopClientFlamethrowerFire(int client)
{
    int iFireEntity = EntRefToEntIndex(g_iPlayerFireEntityRef[client]);
    if (iFireEntity > MaxClients && IsValidEntity(iFireEntity))
    {
        if (DEBUG.BoolValue)
            PrintToServer("StartClientFlamethrowerFire info_particle_system %d | StopPlayEndCap", iFireEntity);
        AcceptEntityInput(iFireEntity, "StopPlayEndCap");
    }
    
    return;
}
public bool IsClientFlamethrowerFireActive(int client)
{
    int iFireEntity = EntRefToEntIndex(g_iPlayerFireEntityRef[client]);
    if (iFireEntity > MaxClients && IsValidEntity(iFireEntity))
    {
        // if (DEBUG.BoolValue)
        // 	PrintToServer("StartClientFlamethrowerFire info_particle_system %d | m_bActive %d", iFireEntity, GetEntProp(iFireEntity, Prop_Data, "m_bActive"));
        return view_as<bool>(GetEntProp(iFireEntity, Prop_Data, "m_bActive"));
    }
    
    return false;
}

public int CreateClientFlamethrowerFire(int client)
{
    int info_particle_system = CreateEntityByName("info_particle_system");
    if (IsValidEntityEx(info_particle_system))
    {
        DispatchKeyValue(info_particle_system, "effect_name", "flamethrower");
        AcceptEntityInput(info_particle_system, "start");
        
        // if (IsFakeClient(client))
        // {
        WA_SetParentToPlayerWeaponAttachment(client, info_particle_system, "muzzle");
        DispatchSpawn(info_particle_system);
        ActivateEntity(info_particle_system);
        // }
        // else
        // {
        // 	int iWeapon = GetPlayerActiveWeapon(client);
        // 	if (IsValidWeapon(iWeapon))
        // 	{
        // 		SetVariantString("!activator");
        // 		AcceptEntityInput(info_particle_system, "SetParent", client);
                
        // 		SetVariantString("eyes");
        // 		AcceptEntityInput(info_particle_system, "SetParentAttachment");
                
        // 		char cEntityName[256];
        // 		GetEntityClassname(iWeapon, cEntityName, sizeof(cEntityName));
                
        // 		//前, 左, 上  // 下, 左
        // 		if (StrContains(cEntityName, "weapon_flamethrower_british", false) > -1)
        // 			TeleportEntity(info_particle_system, view_as<float>({18.0, -5.0, -4.0}), view_as<float>({-12.5, 8.0, 0.0}), NULL_VECTOR);
        // 		else if (StrContains(cEntityName, "weapon_flamethrower_american", false) > -1)
        // 			TeleportEntity(info_particle_system, view_as<float>({28.0, -2.0, -2.0}), view_as<float>({-12.5, 12.0, 0.0}), NULL_VECTOR);
        // 		else if (StrContains(cEntityName, "weapon_flamethrower_german", false) > -1)
        // 			TeleportEntity(info_particle_system, view_as<float>({28.0, -5.0, -2.0}), view_as<float>({-12.5, 8.0, 0.0}), NULL_VECTOR);
                
        // 		DispatchSpawn(info_particle_system);
        // 		ActivateEntity(info_particle_system);
        // 	}
        // }
        
        // SetVariantString("mouth");
        // AcceptEntityInput(info_particle_system, "SetParentAttachment");
        // TeleportEntity(info_particle_system, view_as<float>({5.0, 20.0, -5.0}), view_as<float>({-15.0, 95.0, 0.0}), NULL_VECTOR);

        // SetVariantString("L Finger1");
        // AcceptEntityInput(info_particle_system, "SetParentAttachmentMaintainOffset");
        // }
        
        SetEntPropEnt(info_particle_system, Prop_Send, "m_hOwnerEntity", client);
        SetEntPropEnt(info_particle_system, Prop_Data, "m_hOwnerEntity", client);
    }
    
    return info_particle_system;
}
stock bool CanClientBurnClient(int client, int iTargetClient)
{
    float fClientEyePosition[3];
    float fTargetClientEyePosition[3];
    GetClientEyePosition(client, fClientEyePosition);
    GetClientEyePosition(iTargetClient, fTargetClientEyePosition);
    if (GetVectorDistance(fClientEyePosition, fTargetClientEyePosition) > sm_flamethrower_range.FloatValue)
        return false;
    
    float fClientEyeAngles[3];
    float fClientEyeAnglesVector[3];
    GetClientEyeAngles(client, fClientEyeAngles);
    GetAngleVectors(fClientEyeAngles, fClientEyeAnglesVector, NULL_VECTOR, NULL_VECTOR);
    
    float fClientEyeAnglesNegateVector[3];
    fClientEyeAnglesNegateVector = fClientEyeAnglesVector;
    NegateVector(fClientEyeAnglesNegateVector);
    ScaleVector(fClientEyeAnglesNegateVector, 20.0);
    AddVectors(fClientEyePosition, fClientEyeAnglesNegateVector, fClientEyePosition);
    
    float fDirection[3];
    SubtractVectors(fTargetClientEyePosition, fClientEyePosition, fDirection);
    NormalizeVector(fDirection, fDirection);
    if (GetVectorDotProduct(fClientEyeAnglesVector, fDirection) < Cosine(DegToRad(sm_flamethrower_angle.FloatValue/2.0))) // cosθ < horizon
        return false;
    
    Handle trace = TR_TraceRayFilterEx(fClientEyePosition, fTargetClientEyePosition, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_EndPoint, TraceEntityFilter_OnlyWorld, client);
    if (TR_DidHit(trace))
    {
        CloseHandle(trace);
        
        float fTargetClientPosition[3];
        GetClientAbsOrigin(iTargetClient, fTargetClientPosition);
        trace = TR_TraceRayFilterEx(fClientEyePosition, fTargetClientPosition, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_EndPoint, TraceEntityFilter_OnlyWorld, client);
        if (TR_DidHit(trace))
        {
            CloseHandle(trace);
            return false;
        }
    }
    
    CloseHandle(trace);
    return true;
}

public void PrecacheFile()
{
    AddFileToDownloadsTable("custom/Gandor233_Particles_000.vpk");
    AddFileToDownloadsTable("custom/Gandor233_Particles_dir.vpk");
    PrecacheParticleFile("particles/mnb_flamethrower.pcf");
    PrecacheParticleEffect("flamethrower");
    return;
}


///////////////////////////////////// MoreFire
int g_iPlayerFireAttacker[MAXPLAYERS+1];
float g_fPlayerEndFireTime[MAXPLAYERS+1];
public void MoreFire_OnPluginStart()
{
    HookEvent("player_spawn", MoreFire_Event_PlayerSpawnOrDeath, EventHookMode_Pre);
    HookEvent("player_death", MoreFire_Event_PlayerSpawnOrDeath, EventHookMode_Pre);
}
public void MoreFire_OnClientPutInServer(int client) 
{
    g_fPlayerEndFireTime[client] = 0.0;
    
    if (IsValidClient(client))
    {
        ExtinguishEntityEx(client);
        SDKHook(client, SDKHook_OnTakeDamage, MoreFire_OnTakeDamage_CallBack);
    }
    
    return;
}
public Action MoreFire_OnTakeDamage_CallBack(int victim, int& attacker, int& inflictor, float& damage, int& damagetype, int& weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
    if (IsValidClient(victim))
    {
        if ((damagetype & DMG_BURN) && (damagetype & DMG_DIRECT))
        {
            if (!IsPlayerAlive(victim))
            {
                char cInflictorName[256];
                GetEntityClassname(attacker, cInflictorName, sizeof(cInflictorName));
                if (StrEqual(cInflictorName, "entityflame", false))
                {
                    SetEntPropFloat(inflictor, Prop_Data, "m_flLifetime", 0.0);
                    AcceptEntityInput(inflictor, "Kill");
                }
            }
            
            // 使用createhurt代替火焰伤害
            if (damage < 1.0)
                CreateHurt(g_iPlayerFireAttacker[victim], victim, 1, inflictor, "entityflame", DMG_BURN);
            else
                CreateHurt(g_iPlayerFireAttacker[victim], victim, RoundFloat(damage), inflictor, "entityflame", DMG_BURN);
            
            if (DEBUG.BoolValue)
                PrintToServer("attacker %d | victim %d | inflictor %d | damage %0.1f = %d", g_iPlayerFireAttacker[victim], victim, inflictor, damage, RoundFloat(damage));
            
            damage = 0.0;
            return Plugin_Changed;
        }
    }
    
    return Plugin_Continue;
}
public void MoreFire_Event_PlayerSpawnOrDeath(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (IsValidClient(client))
    {
        g_fPlayerEndFireTime[client] = 0.0;
        if (IsEntityOnFire(client))
            ExtinguishEntityEx(client);
    }

    return;
}
public Action CheckPlayerFire_Timer(Handle timer, any data)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsValidClient(client))
        {
            int iPlayerWaterLevel = GetEntProp(client, Prop_Send, "m_nWaterLevel");
            // PrintCenterText(client, "iPlayerWaterLevel %d | Time to fire %d | Player on fire %d", 
            // iPlayerWaterLevel, (iPlayerWaterLevel == 0 && g_fPlayerEndFireTime[client] > GetEngineTime() && IsPlayerAlive(client) && !IsCoopEnemy(client, g_iGameModeClass, g_iGameMode)), IsEntityOnFire(client));
            if (iPlayerWaterLevel == 0 && g_fPlayerEndFireTime[client] > GetEngineTime() && IsPlayerAlive(client))
            {
                if (!IsEntityOnFire(client))
                    IgniteEntity(client, g_fPlayerEndFireTime[client] - GetEngineTime() + 5.0);
            }
            else
            {
                if (IsEntityOnFire(client))
                    ExtinguishEntityEx(client);
                
                g_fPlayerEndFireTime[client] = 0.0;
            }
        }
    }
    
    return Plugin_Continue;
}
public int BurnPlayer(int attacker, int victim, float time)
{
    if (victim < 0 || victim > MaxClients)
        return 0;
    
    g_iPlayerFireAttacker[victim] = attacker;
    g_fPlayerEndFireTime[victim] = GetEngineTime() + time;
    return RoundFloat(g_fPlayerEndFireTime[victim]);
}
///////////////////////////////////// MoreFire


///////////////////////////////////// Function
stock bool IsValidEntityEx(int entity)
{
    if (entity > 0 && IsValidEdict(entity) && IsValidEntity(entity))
        return true;
    
    return false;
}
stock bool IsValidClient(int client)
{
    if (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
        return true;
    
    return false;
}
stock bool IsPlayerTeam(int team)
{
    if (team == TEAM_1_SEC || team == TEAM_2_INS)
        return true;
    
    return false;
}
stock bool IsClientInPlayerTeam(int client)
{
    if (IsPlayerTeam(GetClientTeam(client)))
        return true;
    
    return false;
}
stock bool IsCoopEnemy(int client, int iGameModeClass, int iGameMode)
{
    if (iGameModeClass == GAME_MODE_CLASS_PVE)
    {
        int iClientTeam = GetClientTeam(client);
        if (iGameMode == GAME_MODE_SURVIVAL)
        {
            if (iClientTeam == TEAM_1_SEC)
                return true;
        }
        else
        {
            if (iClientTeam == TEAM_2_INS)
                return true;
        }
    }

    return false;
}
public int GetPlayerActiveWeapon(int client)
{
    return GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
}
stock bool IsPlayerDeploying(int client)
{
    int iActiveWeapon = GetPlayerActiveWeapon(client);
    if (iActiveWeapon > MaxClients && IsValidEntity(iActiveWeapon) && HasEntProp(iActiveWeapon, Prop_Send, "m_timestamp") && GetEntPropFloat(iActiveWeapon, Prop_Send, "m_timestamp") > 0)
        return true;
    
    return false;
}
stock int GetPlayerFlags(int client)
{
    return GetEntProp(client, Prop_Send, "m_iPlayerFlags");
}
stock bool IsPlayerForcedToPuttingDownWeapon(int client)
{
    return view_as<bool>((GetPlayerFlags(client) & INS_PF_PUTDOWNWEAPON));
}
public int GetClipType(int client, int iWeaponID)
{
    return GetEntProp(iWeaponID, Prop_Data, "m_iPrimaryAmmoType");
}
public int GetClipCount(int client, int iWeaponID)
{
    int clipType = GetClipType(client, iWeaponID);
    if (clipType < 0 || clipType > 255)
        return 1;

    return GetEntProp(client, Prop_Data, "m_iAmmo", _, clipType);
}
stock float GetEntitiesDistance(EntityId1, EntityId2)
{
    float Entity1PositionVector[3];
    GetEntPropVector(EntityId1, Prop_Data, "m_vecOrigin", Entity1PositionVector);

    float Entity2PositionVector[3];
    GetEntPropVector(EntityId2, Prop_Data, "m_vecOrigin", Entity2PositionVector);

    return GetVectorDistance(Entity1PositionVector, Entity2PositionVector);
}
stock float GetDistance_ClientToPosition(int client, const float fPositionVector[3])
{
    if (!IsValidClient(client))
        return 0.0;
        
    float fClientPosition[3];
    GetClientAbsOrigin(client, fClientPosition);
    return GetVectorDistance(fPositionVector, fClientPosition);
}
public bool TraceEntityFilter_ExceptClientAndSelf(int entity, int mask, int date)
{
    if (entity == 0 || (entity != date && entity > MaxClients))
        return true;
    else
        return false;
}
public bool TraceEntityFilter_OnlyWorld(int entity, int mask, int date)
{
    if (entity == 0)
        return true;
    else
        return false;
}
stock void KillEntityEx(int entity)
{
    if (IsValidEntityEx(entity))
    {
        int IHammerID = GetEntProp(entity, Prop_Data, "m_iHammerID");
        if (IHammerID > 0)
            return;
        
        AcceptEntityInput(entity, "Kill");
    }
    return;
}
public void PrecacheParticleFile(const char[] cParticleFile)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("ExtraParticleFilesTable");
    }
    
    if (FindStringIndex(table, cParticleFile) == INVALID_STRING_INDEX)
    {
        bool save = LockStringTables(false);
        AddToStringTable(table, cParticleFile);
        LockStringTables(save);
    }
    
    return;
}
public void PrecacheParticleEffect(const char[] cEffectName)
{
    static int table = INVALID_STRING_TABLE;
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("ParticleEffectNames");
    }
    
    if (FindStringIndex(table, cEffectName) == INVALID_STRING_INDEX)
    {
        bool save = LockStringTables(false);
        AddToStringTable(table, cEffectName);
        LockStringTables(save);
    }
    
    return;
}
stock bool CreateHurt(int attacker = 0, int victim = 0, int damage = 0, int weaponid = 0, char[] cCustomWeaponName = "\0", int iDamageType = DMG_BLAST)
{
    if (IsValidEntityEx(victim) && damage > 0)
    {
        char cDamageChar[16];
        IntToString(damage, cDamageChar, 32);

        char cDamageTypeChar[32];
        IntToString(iDamageType, cDamageTypeChar, 32);

        int pointHurt = CreateEntityByName("point_hurt");
        if (pointHurt > MaxClients && IsValidEntityEx(pointHurt))
        {
            if (strlen(cCustomWeaponName) > 0)
            {
                DispatchKeyValue(pointHurt, "classname", cCustomWeaponName);
            }
            else
            {
                if (IsValidEntityEx(weaponid))
                {
                    char cWeaponName[256];
                    GetEntityClassname(weaponid, cWeaponName, sizeof(cWeaponName));
                    DispatchKeyValue(pointHurt, "classname", cWeaponName);
                }
            }
            
            char cTargetEntityOldName[128];
            GetEntPropString(victim, Prop_Data, "m_iName", cTargetEntityOldName, sizeof(cTargetEntityOldName));
            
            char cTargetName[128];
            Format(cTargetName, sizeof(cTargetName), "hurtme_%d", EntIndexToEntRef(victim));
            DispatchKeyValue(victim, "targetname", cTargetName);
            DispatchKeyValue(pointHurt, "DamageTarget", cTargetName);
            
            DispatchKeyValue(pointHurt, "Damage", cDamageChar);
            DispatchKeyValue(pointHurt, "DamageType", cDamageTypeChar);
            DispatchSpawn(pointHurt);
            
            AcceptEntityInput(pointHurt, "Hurt", IsValidEntityEx(attacker) ? attacker : -1);
            AcceptEntityInput(pointHurt, "Kill");
            DispatchKeyValue(victim, "targetname", cTargetEntityOldName);
            // RemoveEdict(pointHurt);
            return true;
        }
    }

    return false;
}
public int IsEntityOnFire(int entity)
{
    if (IsValidEntity(entity))
    {
        int iFireEntity = GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity");
        if (iFireEntity > MaxClients && IsValidEdict(iFireEntity))
        {
            char cClassname[256];
            GetEntityClassname(iFireEntity, cClassname, sizeof(cClassname));
            if (StrEqual(cClassname, "entityflame", false))
                return iFireEntity;
        }
    }
    return false;
}
public void ExtinguishEntityEx(int entity)
{
    if (IsValidEntity(entity))
    {
        // 玩家死亡时就算用的EventHookMode_Pre也无法使用m_hEffectEntity来获得火焰，只能遍历
        // 直接KILL会导致再次spawn前无法再着火
        int iFireEntity = GetEntPropEnt(entity, Prop_Data, "m_hEffectEntity");
        if (IsValidEdict(iFireEntity))
        {
            AcceptEntityInput(iFireEntity, "DisableDraw");
            AcceptEntityInput(iFireEntity, "DisableDamageForces");
            SetEntPropFloat(iFireEntity, Prop_Data, "m_flLifetime", 0.0);
            // AcceptEntityInput(iFireEntity, "Kill");
        }
        else
        {
            char cClassname[256];
            for (iFireEntity = 0; iFireEntity <= GetMaxEntities(); iFireEntity++)
            {
                if (IsValidEdict(iFireEntity))
                {
                    GetEntityClassname(iFireEntity, cClassname, sizeof(cClassname));

                    if (StrContains(cClassname, "entityflame", false) > -1)
                    {
                        if (GetEntPropEnt(iFireEntity, Prop_Data, "m_pParent") == entity)
                        {
                            AcceptEntityInput(iFireEntity, "DisableDraw");
                            AcceptEntityInput(iFireEntity, "DisableDamageForces");
                            SetEntPropFloat(iFireEntity, Prop_Data, "m_flLifetime", 0.0);
                            // AcceptEntityInput(iFireEntity, "Kill");
                        }
                    }
                }
            }
        }
    }

    return;
}
///////////////////////////////////// Function


///////////////////////////////////// GameMode
bool g_bNeedCheckGameMode;
int g_iGameMode;
int g_iGameModeClass;
public void GameMode_OnMapStart()
{
    g_bNeedCheckGameMode = true;
    return;
}
public void GameMode_OnMapEnd()
{
    g_bNeedCheckGameMode = true;
    return;
}
public int GetGameMode()
{
    if (g_bNeedCheckGameMode)
        CheckGameMode();
    return g_iGameMode;
}
public int GetGameModeClass()
{
    if (g_bNeedCheckGameMode)
        CheckGameMode();
    return g_iGameModeClass;
}
stock void CheckGameMode()
{
    char GameMode[32];
    GetConVarString(FindConVar("mp_gamemode"), GameMode, sizeof(GameMode));

    g_iGameModeClass = GAME_MODE_CLASS_PVE;
    if (StrContains(GameMode, "checkpoint", false) > -1)
        g_iGameMode = GAME_MODE_CHECKPOINT;
    else if (StrContains(GameMode, "hunt", false) > -1)
        g_iGameMode = GAME_MODE_HUNT;
    else if (StrContains(GameMode, "conquer", false) > -1)
        g_iGameMode = GAME_MODE_CONQUER;
    else if (StrContains(GameMode, "outpost", false) > -1)
        g_iGameMode = GAME_MODE_OUTPOST;
    else if (StrContains(GameMode, "survival", false) > -1)
        g_iGameMode = GAME_MODE_SURVIVAL;
    else
    {
        g_iGameModeClass = GAME_MODE_CLASS_PVP;

        if (StrContains(GameMode, "push", false) > -1)
            g_iGameMode = GAME_MODE_PUSH;
        else if (StrContains(GameMode, "ambush", false) > -1)
            g_iGameMode = GAME_MODE_AMBUSH;
        else if (StrContains(GameMode, "battle", false) > -1)
            g_iGameMode = GAME_MODE_BATTLE;
        else if (StrContains(GameMode, "elimination", false) > -1)
            g_iGameMode = GAME_MODE_ELIMINATION;
        else if (StrContains(GameMode, "firefight", false) > -1)
            g_iGameMode = GAME_MODE_FIREFIGHT;
        else if (StrContains(GameMode, "flashpoint", false) > -1)
            g_iGameMode = GAME_MODE_FLASHPOINT;
        else if (StrContains(GameMode, "invasion", false) > -1)
            g_iGameMode = GAME_MODE_INVASION;
        else if (StrContains(GameMode, "infiltrate", false) > -1)
            g_iGameMode = GAME_MODE_INFILTRATE;
        else if (StrContains(GameMode, "occupy", false) > -1)
            g_iGameMode = GAME_MODE_OCCUPY;
        else if (StrContains(GameMode, "skirmish", false) > -1)
            g_iGameMode = GAME_MODE_SKIRMISH;
        else if (StrContains(GameMode, "vendetta", false) > -1)
            g_iGameMode = GAME_MODE_VENDETTA;
        else if (StrContains(GameMode, "armsrace", false) > -1)
            g_iGameMode = GAME_MODE_ARMSRACE;
        else if (StrContains(GameMode, "deathmatch", false) > -1)
            g_iGameMode = GAME_MODE_DEATHMATCH;
        else if (StrContains(GameMode, "demolition", false) > -1)
            g_iGameMode = GAME_MODE_DEMOLITION;
    }
    
    g_bNeedCheckGameMode = false;
    return;
}
///////////////////////////////////// GameMode