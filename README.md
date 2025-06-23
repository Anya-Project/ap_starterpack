# ap_starterpack

## ▶️ Main Features

- **Comprehensive Starter Pack:** New players can claim a one-time package containing cash, bank money, essential items, a personal vehicle, and a driver's license.
- **Weekly Loyalty Rewards:** Existing players who have already claimed the starter pack can return to the NPC weekly to receive random item rewards, encouraging player retention.
- **Modular Inventory Integration:** Natively supports both `qb-inventory` (default) and `ox_inventory` through a simple configuration setting.
- **Automatic Discord Logs:** Every time a starter pack is claimed, a detailed notification is sent to a designated admin channel via a Discord webhook.
- **Rules UI:** Before claiming their pack, new players must read and agree to configurable server rules.
- **Anti-Abuse System:** A solid system based on character metadata prevents players from repeatedly claiming the starter pack.
- **Easy Configuration:** Nearly every aspect (rewards, NPC, vehicle, messages) can be easily modified through the `config.lua` file.

## ⚙️ Requirements

- **[qb-core](https://github.com/qbcore-framework/qb-core)**
- **[qb-target](https://github.com/qbcore-framework/qb-target)** 
- **[ox_lib](https://github.com/overextended/ox_lib)** 
- **[oxmysql](https://github.com/overextended/oxmysql)**

## 🛠️ Installation

1.  Download this script and place the `qb-starterpack` folder into your server's `resources` directory.
2.  (Optional) If you plan to use `ox_inventory`, ensure that resource is also installed.
3.  Open `config.lua` and adjust all settings to your preference (see the **Configuration** section below).
4.  Add the following line to your `server.cfg` file, making sure it is placed **after** all the required dependencies:
    ```cfg
    ensure qb-starterpack
    ```
5.  Restart your server or run `refresh; ensure qb-starterpack` in the server console. The NPC will now appear at your configured location.

## 🔧 Configuration
```lua
Config = {}

Config.Inventory = 'qb'  -- 'qb' atau 'ox'

Config.Pesan = {
    sukses_starter = 'Congratulations! You have received your Starter Pack.',
    sukses_weekly = "You have successfully claimed your weekly reward! Items received: %s.", 
    tunggu_weekly = "You can claim again in: ",
    inventaris_penuh = 'Your inventory is full! The claim has been cancelled.',
    tolak_aturan = "You must agree to the rules to claim your pack.",
    mobil_disiapkan = "Your vehicle is being prepared...",
    mobil_sukses = "Enjoy your new vehicle!",
    mobil_ke_garasi = "A %s (%s) has been sent to your %s.", 
    terima_kasih_setuju = "Thank you for agreeing. Processing your starter pack...",
}

-- NPC Settings
Config.NPC = {
    model = 's_m_y_swat_01',
    coords = vector4(-1306.11, -646.17, 26.37, 216.2),
    anim = 'amb@world_human_cop_idles@a@a', 
    animDict = 'amb@world_human_cop_idles@a'
}

-- Target Interaction Settings
Config.Target = {
    label = 'Claim Starter Pack',
    icon = 'fas fa-gift',
    label_weekly = 'Claim Weekly Reward',
    icon_weekly = 'fas fa-calendar-check'
}

-- Starter Pack Items
Config.StarterPack = {
    Money = { cash = 5000, bank = 10000 },
    Items = {
        { name = 'phone', amount = 1 },
        { name = 'water_bottle', amount = 5 },
        { name = 'sandwich', amount = 5 },
    }
}

Config.Vehicle = {
    enabled = true,
    
    options = {
        { model = 'sultan', label = 'Karin Sultan' },
        { model = 'elegy2', label = 'Annis Elegy RH8' },
        { model = 'fusilade', label = 'Schyster Fusilade' }
    },
    spawnMethod = 'spawn', -- 'spawn' atau 'garage'
    garage = 'pillboxgarage',
    spawnPoint = vector4(-988.84, -407.03, 37.83, 295.43),
}

Config.FuelSystem = {
    system = 'legacy', -- 'legacy', 'cdn', 'ox', atau 'none'
    setFuelToFull = true
}

-- Rules Configuration
Config.Rules = {
    header = "CITY RULES",
    text = "Welcome to our city! Please read and agree to the rules below:\n\n" ..
           "1. **No RDM & VDM:** Do not kill or ram others without a valid RP reason.\n\n" ..
           "2. **Fear RP:** Value your life. Act afraid when threatened.\n\n" ..
           "3. **Metagaming & Powergaming:** Do not use out-of-character (OOC) information in-character (IC).\n\n" ..
           "By clicking 'Agree', you confirm you will comply with all city rules.",
    button = {
        submit = "Agree & Claim",
        cancel = "Decline"
    }
}

-- Discord Log Configuration
Config.Discord = {
    enabled = true,
    webhook = "https://discord.com/api/webhooks/1385743649601753250/uDsqkia1A4TVHKFD0ZKq_ODP72lwl-3h7C_9jrIPfPhfyCpppmMoN76iJ13OeXr8fW3u",
    embeds = {
        starter = {
            title = "✅ Starter Pack Claimed!",
            color = 3066993, -- Hijau
        },
        weekly = {
            title = "🎁 Weekly Reward Claimed!",
            color = 15158332, -- Emas
        }
    }
}

-- Weekly Claim Configuration
Config.WeeklyClaim = {
    enabled = true,
    cooldown_days = 7,
    itemsToGive = 2,
    RewardPool = {
        { name = 'sandwich', amount = 5, chance = 40 },
        { name = 'water_bottle', amount = 5, chance = 40 },
        { name = 'lockpick', amount = 3, chance = 25 },
        { name = 'advancedlockpick', amount = 1, chance = 15 },
        { name = 'bandage', amount = 4, chance = 30 },
        { name = 'money-roll', amount = 1, chance = 5 },
        { name = 'goldbar', amount = 1, chance = 2 },
    }
}
```
### 🔍 Preview

![Preview 1](https://i.imgur.com/yndqDg0.png)
![Preview 2](https://i.imgur.com/qe3kdrL.png)
![Preview 3](https://i.imgur.com/Gj5cvSV.jpeg)

