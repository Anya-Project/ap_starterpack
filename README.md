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

Config.Inventory = 'qb'  -- Choose 'qb' or 'ox' according to the inventory system used

-- NPC Settings
Config.NPC = {
    model = 's_m_y_swat_01',
    coords = vector4(-239.88, -989.92, 29.29, 249.91),
}

-- Target Interaction Settings
Config.Target = {
    label = 'Claim Starter Pack',
    icon = 'fas fa-gift',
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

-- Vehicle Configuration
Config.Vehicle = {
    enabled = true,
    model = 'sultan',
    spawnMethod = 'spawn', -- Options: 'spawn' or 'garage'
    garage = 'pillboxgarage', -- Garage name if spawnMethod = 'garage'
    spawnPoint = vector4(-225.5, -961.65, 29.2, 155.29), -- Spawn location if spawnMethod = 'spawn'
}

-- Fuel System Configuration
Config.FuelSystem = {
    -- Choose fuel system : 'legacy', 'cdn', 'ox', or 'none'
    system = 'legacy', 

    setFuelToFull = true 
}

-- Notification Messages
Config.Pesan = {
    sukses = 'Congratulations! You have received your Starter Pack.', 
    sudah_klaim = 'You have already claimed this pack.', 
}

-- Rules UI Configuration
Config.Rules = {
    header = "CITY RULES",
    text = "Welcome to our city! Before proceeding, please read and agree to the rules below:\n\n" ..
           "1. **No RDM & VDM:** Killing or ramming other players without a valid RP reason is strictly prohibited.\n\n" ..
           "2. **Fear RP:** Value your life. If threatened with a weapon, you must act afraid and comply.\n\n" ..
           "3. **Metagaming & Powergaming:** Using out-of-character (OOC) information in-character (IC) is not allowed.\n\n" ..
           "4. **No Exploits or Cheats:** Using any form of exploit or cheat to gain an unfair advantage is forbidden.\n\n" ..
           "5. **Respect Other Players:** Treat all players with respect. Harassment or discrimination will not be tolerated.\n\n" ..
           "By clicking the 'Agree' button, you confirm that you have read, understood, and will comply with all city rules.",
    button = {
        submit = "Agree & Claim",
        cancel = "Decline"
    }
}

-- Discord Log Configuration
Config.Discord = {
    enabled = false, -- set to false to disable logging
    webhook = "Url_webhook" 
}

-- Weekly Claim Configuration
Config.WeeklyClaim = {
    enabled = true,
    cooldown_days = 7,
    itemsToGive = 2, 
    RewardPool = {
        { name = 'sandwich', amount = 5 },
        { name = 'water_bottle', amount = 5 },
        { name = 'lockpick', amount = 3 },
        { name = 'advancedlockpick', amount = 1 },
        { name = 'bandage', amount = 4 },
        { name = 'money-roll', amount = 1 }, 
        { name = 'goldbar', amount = 1 }, 
    },
    Pesan = {
        sukses = "You have successfully claimed your weekly reward! See you next week.",
        tunggu = "You can claim again in: ",
        penuh = "Your inventory is full! Please try again later.",
    }
}

```
### 🔍 Preview

![Preview 1](https://i.imgur.com/yndqDg0.png)
![Preview 2](https://i.imgur.com/qe3kdrL.png)
![Preview 3](https://i.imgur.com/Gj5cvSV.jpeg)

