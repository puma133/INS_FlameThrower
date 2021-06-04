[SIZE="4"]A Flamethrower plugin made of "Day of Infamy" model and particles for insurgency(2014) v2.0[/SIZE]

[ATTACH]189544[/ATTACH]

[SIZE="4"]Feature list[/SIZE]
[LIST][*]Ignite and kill other players
[*]Ignite and kill yourself (if you fire a flamethrower too close to wall)
[*]Ignite map entity (like weapon cache or bush)
[*]Ignite player dead body ragdoll if he dies of burn damage[/LIST]

[SIZE="4"]Convar[/SIZE]
[CODE]"sm_flamethrower_burn_time" - Burn duration (Default value: 2.0)
"sm_ft_sound_enable" - Is all plugin flamethrower fire sound enable? (Default value: 1)
"sm_ft_start_sound_sec" - Flamethrower fire START sound file path for team sec. Closed if empty. (Default value: "weapons/flamethrowerno2/flamethrower_start.wav")
"sm_ft_loop_sound_sec" - Flamethrower fire LOOP sound file path for team sec. Closed if empty. (Default value: "weapons/flamethrowerno2/flamethrower_looping.wav")
"sm_ft_end_sound_sec" - Flamethrower fire END sound file path for team sec. Closed if empty. (Default value: "weapons/flamethrowerno2/flamethrower_end.wav")
"sm_ft_empty_sound_sec" - Flamethrower fire EMPTY sound file path for team sec. Closed if empty. (Default value: "")
"sm_ft_start_sound_ins" - Flamethrower fire START sound file path for team ins. Closed if empty. (Default value: "weapons/flamethrowerno41/flamethrower_start.wav")
"sm_ft_loop_sound_ins" - Flamethrower fire LOOP sound file path for team ins. Closed if empty. (Default value: "weapons/flamethrowerno41/flamethrower_looping.wav")
"sm_ft_end_sound_ins" - Flamethrower fire END sound file path for team ins. Closed if empty. (Default value: "weapons/flamethrowerno41/flamethrower_end.wav")
"sm_ft_empty_sound_ins" - Flamethrower fire EMPTY sound file path for team ins. Closed if empty. (Default value: "")[/CODE]

[SIZE="4"]Required Mod[/SIZE]
[LIST]
[*][URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647"]其他 Extra | 喷火器 Flamethrower[/URL] (steam workshop id=2392887647)
[/LIST]

[SIZE="4"]Installation Guide[/SIZE]
[SPOILER]To use this plugin you need to modify the original theater and create your own theater mod.
If you don't know how to do it, please check the [URL="https://steamcommunity.com/sharedfiles/filedetails/?id=424392708"]theater modding guide[/URL].
[LIST=1][*][SIZE="2"]Subscribe the [URL="https://steamcommunity.com/sharedfiles/filedetails/?id=424392708"]required mod[/URL] for your server or download it and edit it into your own mod[/SIZE]
[*][SIZE="2"]Add "#base", "sounds" and "localize" to your mod main theater file[/SIZE]
[CODE]"#base" "base/gandor233_flamethrower.theater"
...
"theater"
{
    "core"
    {
        "precache"
        {
            ...
            "particles"   "particles/ins_flamethrower.pcf"
            "sounds"      "scripts/gandor233_flamethrower_sounds.txt"
            "localize"    "resource/gandor233_flamethrower_%language%.txt"
        }
    }
}[/CODE]
[*][SIZE="2"]Add "flame" to your mod ammo theater file[/SIZE]
[CODE]"theater"
{
    "ammo"
    {
        "flame_proj"
        {
            "flags_clear"    "AMMO_USE_MAGAZINES"
            "carry"          "500"
        }
    }
}[/CODE]
[*][SIZE="2"]Add "weapon_flamethrower_***" to player templates allowed items[/SIZE]
[CODE]"theater"
{
    "player_templates"
    {
        "template_security_1"
        {
            "team"    "security"
            "models"
            {
                ...
            }
            "buy_order"
            {
                ...
            }
            "allowed_items"
            {
                "gear"      "fuel_tank_sec"
                "weapon"    "weapon_flamethrower_sec"
                ...
            }
        }
        "template_insurgent_1"
        {
            "team"    "insurgents"
            "models"
            {
                ...
            }
            "buy_order"
            {
                ...
            }
            "allowed_items"
            {
                "gear"      "fuel_tank_ins"
                "weapon"    "weapon_flamethrower_ins"
                ...
            }
        }
    }
}[/CODE]
[*][SIZE="2"]Install Plugin[/SIZE]
Put FlameThrower_public.smx into "insurgency\addons\sourcemod\plugins\"


[*][SIZE="2"]Custom Particles File[/SIZE]
Download Flamethrower_Particles.zip or clone from [URL="https://github.com/gandor233/INS_FlameThrower"]github[/URL]. put Flamethrower_Particles_dir.vpk and Flamethrower_Particles_000.vpk to your fastdl folder, and make sure player is forced to download these two vpk files to them [B]insurgency/custom/[/B] folder when they join your server.

If you don't have a fastdl server, player also need to subscribe the [URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647"]required mod[/URL] by themself, otherwise the flamethrower fire particles effect won't show up if player didn't reconnect to your server when they first join your server erverytime after they restart the game program.[/LIST][/SPOILER]

[SIZE="4"]Changelog[/SIZE]
[CODE]v2.0:
* Fix the problem that the flame doesn't shoot from the muzzle in first person.
* The WeaponAttachmentAPI plugin is no longer needed.
* Using plugin instead of theater scripts to play the sound effect of flamethrower.
* Using theater scripts instead of plugin to cause direct damage.
* Using theater scripts instead of plugin to create flamethrower effects.
* Fixed problems in the previous version of the model and particle effects files.
* New player gerar - Fuel Tank

v1.0:
* Initial release.[/CODE]

[SIZE="4"]Credits[/SIZE]
[LIST]
[*]Models and scripts are modified by [B]axotn1k[/B]
[/LIST]

中文INS服务器使用此插件请署名作者。

[SIZE="4"]Link[/SIZE]
[LIST]
[*][SIZE="4"][URL="https://github.com/gandor233/INS_FlameThrower"]Github[/URL][/SIZE]
[*][SIZE="4"][URL="https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647"]Required Mod[/URL][/SIZE]
[/LIST]

[ATTACH]189542[/ATTACH]