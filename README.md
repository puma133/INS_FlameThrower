# INS_FlameThrower
FlameThrower plugin for insurgency(2014)

WeaponAttachmentAPI plugin is modified from [MitchDizzle's plugin](https://github.com/MitchDizzle/WeaponAttachmentAPI)

## Required Mod
[其他 Extra | 喷火器 Flamethrower](https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647)

## Convar
```
"sm_flamethrower_range" - FlameThrower fire range (Default value: 700.0)
"sm_flamethrower_angle" - FlameThrower fire angle (Default value: 36.0)
"sm_flamethrower_burn_time" - Burn duration (Default value: 5.0)
```

## Guide
To use this plugin you need modify your mod theater.
#### 1. Subscribe the [required mod](https://steamcommunity.com/sharedfiles/filedetails/?id=2392887647) for your server
#### 2. Add "#base", "sounds" and "localize" to your mod main theater file
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
            "sounds"      "scripts/gandor233_flamethrower_sounds.txt"
            "localize"    "resource/gandor233_flamethrower_%language%.txt"
        }
    }
}
```
#### 3. Add "flame" to your mod ammo theater file
```
"theater"
{
    "ammo"
    {
        "flame"
        {
            "flags_clear"    "AMMO_USE_MAGAZINES"
            "carry"          "500"
            "tracer_type"    "none"
        }
    }
}
```
#### 4. Add "weapon_flamethrower_***" to player templates allowed items
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
                "weapon"    "weapon_flamethrower_british"
                "weapon"    "weapon_flamethrower_american"
                "weapon"    "weapon_flamethrower_german"
                ...
            }
        }
    }
}
```
#### 5. Put FlameThrower_public.smx and WeaponAttachmentAPI.smx to "insurgency\addons\sourcemod\plugins\"