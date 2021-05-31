#if defined _WeaponAttachmentAPI_included
 #endinput
#endif
#define _WeaponAttachmentAPI_included

/**
 * Gets the attachment postion of the client's model.
 *
 * @param client				Client index
 * @param cPlayerAttachment		The attachment point to look up
 * @return 						Returns false if the position could not be looked up
 * @error						Invalid client.
 */
native bool WA_GetPlayerAttachmentPos(int client, char[] cPlayerAttachment, float fPosition[3], float fAngle[3] = {0.0, 0.0, 0.0});

/**
 * Gets the attachment postion of the client's current weapon.
 *
 * @param client				Client index
 * @param cWeaponAttachment		The attachment point to look up
 * @return 						Returns false if the position could not be looked up
 * @error						Invalid client.
 */
native bool WA_GetPlayerWeaponAttachmentPos(int client, char[] cWeaponAttachment, float fPosition[3]);

/**
 * Set Parent to player's current weapon attachment.
 *
 * @param client				Client index
 * @param iEntity				Target entity index
 * @param cWeaponAttachment		Target weapon attachment index
 * @return 						Returns false if player's current weapon could not be looked up
 * @error						Invalid client.
 */
native bool WA_SetParentToPlayerWeaponAttachment(int client, int iEntity, char[] cWeaponAttachment);

public SharedPlugin:__pl_WeaponAttachmentAPI =
{
	name = "WeaponAttachmentAPI",
	file = "WeaponAttachmentAPI.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_WeaponAttachmentAPI_SetNTVOptional()
{
	MarkNativeAsOptional("WA_GetPlayerAttachmentPos");
	MarkNativeAsOptional("WA_GetPlayerWeaponAttachmentPos");
	MarkNativeAsOptional("WA_SetParentToPlayerWeaponAttachment");
}
#endif
