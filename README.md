# INS_FlameThrower
Flamethrower plugin for insurgency(2014) v2.0

## Required Mod
[其他 Extra | 喷火器 Flamethrower](https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647)

## Convar
```
"sm_flamethrower_burn_time" - Burn duration (Default value: 2.0)
"sm_ft_sound_enable" - Is all plugin flamethrower fire sound enable? (Default value: 1)
"sm_ft_start_sound_sec" - Flamethrower fire START sound file path for team sec. Closed if empty. (Default value: "weapons/flamethrowerno2/flamethrower_start.wav")
"sm_ft_loop_sound_sec" - Flamethrower fire LOOP sound file path for team sec. Closed if empty. (Default value: "weapons/flamethrowerno2/flamethrower_looping.wav")
"sm_ft_end_sound_sec" - Flamethrower fire END sound file path for team sec. Closed if empty. (Default value: "weapons/flamethrowerno2/flamethrower_end.wav")
"sm_ft_empty_sound_sec" - Flamethrower fire EMPTY sound file path for team sec. Closed if empty. (Default value: "")
"sm_ft_start_sound_ins" - Flamethrower fire START sound file path for team ins. Closed if empty. (Default value: "weapons/flamethrowerno41/flamethrower_start.wav")
"sm_ft_loop_sound_ins" - Flamethrower fire LOOP sound file path for team ins. Closed if empty. (Default value: "weapons/flamethrowerno41/flamethrower_looping.wav")
"sm_ft_end_sound_ins" - Flamethrower fire END sound file path for team ins. Closed if empty. (Default value: "weapons/flamethrowerno41/flamethrower_end.wav")
"sm_ft_empty_sound_ins" - Flamethrower fire EMPTY sound file path for team ins. Closed if empty. (Default value: "")
```
## Guide
To use this plugin you need to modify the original theater and create your own theater mod. If you don't know how to do it, please check the [theater modding guide](https://steamcommunity.com/sharedfiles/filedetails/?id=424392708).
### 1. Subscribe the [required mod](https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647) for your server or download it and edit it into your own mod
### 2. Add "#base", "sounds" and "localize" to your mod main theater file
```
"#base" "base/gandor233_flamethrower.theater"
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
}
```
### 3. Add "flame" to your mod ammo theater file
```
"theater"
{
    "ammo"
    {
        "flame_proj"
        {
            "flags_clear"    "AMMO_USE_MAGAZINES"
            "carry"          "500"
        }
    }
}
```
### 4. Add "weapon_flamethrower_***" to player templates allowed items
```
"theater"
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
}
```
### 5. Install plugin
Remove other versions of flamethrower plugin
<br>Put FlameThrower_public_v2.0.smx into "insurgency\addons\sourcemod\plugins\"
### 6. Particles file
Put the v2.0 versions custom\Flamethrower_Particles_dir.vpk and custom\Flamethrower_Particles_000.vpk to your fastdl folder, and make sure player is forced to download these two vpk files to them custom folder when they join your server.

If you don't have a fastdl server, player also need to subscribe the required mod by themself, otherwise the flamethrower fire particles effect won't show up if player didn't reconnect to your server when they first join your server erverytime after they start the game program.

## Credits
* Models and scripts are modified by axotn1k

## Changelog
```
v2.0:
* Add New player gerar - Fuel Tank
* Fix the problem that the flame doesn't shoot from the muzzle in first person.
* The WeaponAttachmentAPI plugin is no longer needed.
* Using plugin instead of theater scripts to play the sound effect of flamethrower.
* Using theater scripts instead of plugin to create direct damage.
* Using theater scripts instead of plugin to create flamethrower effects.
* Fixed problems in the previous version models and particles files.

v1.0:
* Initial release.
```
中文INS服务器使用此插件请署名作者。