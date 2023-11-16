_, CraftSim = ...

CraftSim.OPTIONAL_REAGENT_DATA = {
    -- Lesser Illustrious Insight
    [191526] = {skill = 30},
    -- Illustrious Insight
    [191529] = {skill = 30},
    -- Stable Fluid Draconium
    [191511] = {inspirationBonusSkillFactor = 0.15, qualityID = 1},
    [191512] = {inspirationBonusSkillFactor = 0.20, qualityID = 2},
    [191513] = {inspirationBonusSkillFactor = 0.25, qualityID = 3},
    -- Primal Infusion
    [197921] = {recipeDifficulty = 30},
    [198046] = {recipeDifficulty = 50},
    -- Missives Combat Stats
    [192553] = {recipeDifficulty = 25, qualityID = 1}, -- crit haste
    [192554] = {recipeDifficulty = 20, qualityID = 2},
    [192552] = {recipeDifficulty = 15, qualityID = 3},
    [194579] = {recipeDifficulty = 25, qualityID = 1}, -- crit mastery
    [194580] = {recipeDifficulty = 20, qualityID = 2},
    [194578] = {recipeDifficulty = 15, qualityID = 3},
    [194567] = {recipeDifficulty = 25, qualityID = 1}, -- mastery haste
    [194568] = {recipeDifficulty = 20, qualityID = 2},
    [194566] = {recipeDifficulty = 15, qualityID = 3},
    [194573] = {recipeDifficulty = 25, qualityID = 1}, -- vers crit
    [194574] = {recipeDifficulty = 20, qualityID = 2},
    [194572] = {recipeDifficulty = 15, qualityID = 3},
    [194570] = {recipeDifficulty = 25, qualityID = 1}, -- verse haste
    [194571] = {recipeDifficulty = 20, qualityID = 2},
    [194569] = {recipeDifficulty = 15, qualityID = 3},
    [194576] = {recipeDifficulty = 25, qualityID = 1}, -- vers mastery
    [194577] = {recipeDifficulty = 20, qualityID = 2},
    [194575] = {recipeDifficulty = 15, qualityID = 3},
    -- Missives Profession Stats
    [198534] = {recipeDifficulty = 25, qualityID = 1}, -- inspiration
    [198535] = {recipeDifficulty = 20, qualityID = 2},
    [198536] = {recipeDifficulty = 15, qualityID = 3},
    [200571] = {recipeDifficulty = 25, qualityID = 1}, -- crafting speed
    [200572] = {recipeDifficulty = 20, qualityID = 2},
    [200573] = {recipeDifficulty = 15, qualityID = 3},
    [200568] = {recipeDifficulty = 25, qualityID = 1}, -- multicraft
    [200569] = {recipeDifficulty = 20, qualityID = 2},
    [200570] = {recipeDifficulty = 15, qualityID = 3},
    [200565] = {recipeDifficulty = 25, qualityID = 1}, -- ressourcefulness
    [200566] = {recipeDifficulty = 20, qualityID = 2},
    [200567] = {recipeDifficulty = 15, qualityID = 3},
    -- Missives Gathering Stats
    [200574] = {recipeDifficulty = 25, qualityID = 1}, -- finesse
    [200575] = {recipeDifficulty = 20, qualityID = 2},
    [200576] = {recipeDifficulty = 15, qualityID = 3},
    [200577] = {recipeDifficulty = 25, qualityID = 1}, -- perception
    [200578] = {recipeDifficulty = 20, qualityID = 2},
    [200579] = {recipeDifficulty = 15, qualityID = 3},
    [200580] = {recipeDifficulty = 25, qualityID = 1}, -- deftness
    [200581] = {recipeDifficulty = 20, qualityID = 2},
    [200582] = {recipeDifficulty = 15, qualityID = 3},
    -- Embellishments
    [200652] = {recipeDifficulty = 25}, -- Flavor Pocket
    [198256] = {recipeDifficulty = 35, qualityID = 1}, -- Healing Darts
    [198257] = {recipeDifficulty = 30, qualityID = 2},
    [198258] = {recipeDifficulty = 25, qualityID = 3},
    [193468] = {recipeDifficulty = 35, qualityID = 1}, -- Fang Adornments
    [193551] = {recipeDifficulty = 30, qualityID = 2},
    [193554] = {recipeDifficulty = 25, qualityID = 3},
    [191532] = {recipeDifficulty = 35, qualityID = 1}, -- Absorption
    [191533] = {recipeDifficulty = 30, qualityID = 2},
    [191534] = {recipeDifficulty = 25, qualityID = 3},
    [193944] = {recipeDifficulty = 35, qualityID = 1}, -- Silken Lining
    [193945] = {recipeDifficulty = 30, qualityID = 2},
    [193946] = {recipeDifficulty = 25, qualityID = 3},
    [193941] = {recipeDifficulty = 35, qualityID = 1}, -- Grip Wrappings
    [193942] = {recipeDifficulty = 30, qualityID = 2},
    [193943] = {recipeDifficulty = 25, qualityID = 3},

    -- Titan Matrix
    [198048] = {recipeDifficulty = 20}, -- II
    [198056] = {recipeDifficulty = 40}, -- II
    [198058] = {recipeDifficulty = 60}, -- III
    [198059] = {recipeDifficulty = 150}, -- IV

    -- Cooking
    [197765] = {resourcefulness = 110}, -- Impossible Sharp Cutting Knife
    [197764] = {multicraft = 90}, -- Salad on the Side
    [194902] = {}, -- Chocolate TODO: implement the serving increase

    -- Alchemy
    [191520] = {inspiration = 30, multicraft = 27, qualityID = 1}, -- Potion Augmentation
    [191521] = {inspiration = 40, multicraft = 36, qualityID = 2},
    [191522] = {inspiration = 50, multicraft = 45, qualityID = 3},
    [191523] = {inspiration = 30, multicraft = 27, qualityID = 1}, -- Phial Embellishment
    [191524] = {inspiration = 40, multicraft = 36, qualityID = 2},
    [191525] = {inspiration = 50, multicraft = 45, qualityID = 3},
    [191514] = {inspiration = 30, craftingspeedBonusFactor = 0.12, qualityID = 1}, -- Brood Salt
    [191515] = {inspiration = 40, craftingspeedBonusFactor = 0.16, qualityID = 2},
    [191516] = {inspiration = 50, craftingspeedBonusFactor = 0.20, qualityID = 3},
    [191517] = {recipeDifficulty = 18, qualityID = 1}, -- Writhefire Oil
    [191518] = {recipeDifficulty = 24, qualityID = 2}, -- Writhefire Oil
    [191519] = {recipeDifficulty = 30, qualityID = 3}, -- Writhefire Oil

    -- Leatherworking
    [193469] = {recipeDifficulty = 35, qualityID = 1}, -- Toxic Embellishment
    [193552] = {recipeDifficulty = 30, qualityID = 2},
    [193555] = {recipeDifficulty = 25, qualityID = 3},

    -- Jewelcrafting
    [192894] = {recipeDifficulty = 18, qualityID = 1}, -- Blotting Sand
    [192895] = {recipeDifficulty = 24, qualityID = 2},
    [192896] = {recipeDifficulty = 30, qualityID = 3},
    [192897] = {inspiration = 30, inspirationBonusSkillFactor = 0.07, qualityID = 1}, -- Pounce
    [192898] = {inspiration = 40, inspirationBonusSkillFactor = 0.10, qualityID = 2},
    [192899] = {inspiration = 50, inspirationBonusSkillFactor = 0.12, qualityID = 3},

    -- Inscription
    [194868] = {recipeDifficulty = 20, qualityID = 1}, -- Emberscale
    [199055] = {recipeDifficulty = 15, qualityID = 2},
    [199056] = {recipeDifficulty = 10, qualityID = 3},
    [198431] = {recipeDifficulty = 20, qualityID = 1}, -- Jetscale
    [199057] = {recipeDifficulty = 15, qualityID = 2},
    [199058] = {recipeDifficulty = 10, qualityID = 3},
    [194869] = {recipeDifficulty = 20, qualityID = 1}, -- Sagescale
    [199059] = {recipeDifficulty = 15, qualityID = 2},
    [199060] = {recipeDifficulty = 10, qualityID = 3},
    [194871] = {recipeDifficulty = 20, qualityID = 1}, -- Azurescale
    [199051] = {recipeDifficulty = 15, qualityID = 2},
    [199052] = {recipeDifficulty = 10, qualityID = 3},
    [194870] = {recipeDifficulty = 20, qualityID = 1}, -- Bronzescale
    [199053] = {recipeDifficulty = 15, qualityID = 2},
    [199054] = {recipeDifficulty = 10, qualityID = 3},

    -- Tailoring
    [193950] = {recipeDifficulty = 18, qualityID = 1}, -- Abrasive Polishing Cloth 
    [193951] = {recipeDifficulty = 24, qualityID = 2},
    [193952] = {recipeDifficulty = 30, qualityID = 3},
    [193953] = {inspiration = 30, inspirationBonusSkillFactor = 0.07, qualityID = 1}, -- Vibrant Polishing Cloth
    [193954] = {inspiration = 40, inspirationBonusSkillFactor = 0.10, qualityID = 2},
    [193955] = {inspiration = 50, inspirationBonusSkillFactor = 0.12, qualityID = 3},
    [193959] = {inspirationBonusSkillFactor = 0.07, craftingspeedBonusFactor = 0.12, qualityID = 1}, -- Chromatic Embroidery Thread
    [193960] = {inspirationBonusSkillFactor = 0.10, craftingspeedBonusFactor = 0.16, qualityID = 2},
    [193961] = {inspirationBonusSkillFactor = 0.12, craftingspeedBonusFactor = 0.20, qualityID = 3},
    [193962] = {resourcefulnessExtraItemsFactor = 0.15, qualityID = 1}, -- Shimmering Embroidery Thread
    [193963] = {resourcefulnessExtraItemsFactor = 0.20, qualityID = 2},
    [193964] = {resourcefulnessExtraItemsFactor = 0.25, qualityID = 3},
    [193956] = {recipeDifficulty = 18, qualityID = 1}, -- Blazing Embroidery Thread 
    [193957] = {recipeDifficulty = 24, qualityID = 2},
    [193958] = {recipeDifficulty = 30, qualityID = 3},

    -- Engineering
    [198219] = {inspiration = 30, ressourcefulness = 33, qualityID = 1}, -- Overclocker
    [198220] = {inspiration = 40, ressourcefulness = 44, qualityID = 2},
    [198221] = {inspiration = 50, ressourcefulness = 55, qualityID = 3},
    [198216] = {recipeDifficulty = 18, qualityID = 1}, -- Hazard Wires
    [198217] = {recipeDifficulty = 24, qualityID = 2},
    [198218] = {recipeDifficulty = 30, qualityID = 3},
    [198253] = {recipeDifficulty = 20, qualityID = 1}, -- Safety Switch
    [198254] = {recipeDifficulty = 15, qualityID = 2},
    [198255] = {recipeDifficulty = 10, qualityID = 3},
    [198259] = {recipeDifficulty = 20, qualityID = 1}, -- Failure Prevention Unit
    [198260] = {recipeDifficulty = 15, qualityID = 2},
    [198261] = {recipeDifficulty = 10, qualityID = 3},
    [198619] = {recipeDifficulty = 20, qualityID = 1}, -- Capacitor Casing
    [198620] = {recipeDifficulty = 15, qualityID = 2},
    [198621] = {recipeDifficulty = 10, qualityID = 3},
    [198236] = {recipeDifficulty = 25, qualityID = 1}, -- Tuned Gear
    [198237] = {recipeDifficulty = 20, qualityID = 2},
    [198238] = {recipeDifficulty = 15, qualityID = 3},
    [198307] = {recipeDifficulty = 25, qualityID = 1}, -- Fits-All Gear
    [198308] = {recipeDifficulty = 20, qualityID = 2},
    [198309] = {recipeDifficulty = 15, qualityID = 3},
    [198231] = {recipeDifficulty = 25, qualityID = 1}, -- Ticking Gear
    [198232] = {recipeDifficulty = 20, qualityID = 2},
    [198233] = {recipeDifficulty = 15, qualityID = 3},
    [198174] = {recipeDifficulty = 25, qualityID = 1}, -- Razor-Sharp Gear
    [198175] = {recipeDifficulty = 20, qualityID = 2},
    [198176] = {recipeDifficulty = 15, qualityID = 3},

    [203652] = {},

    -- Blacksmithing
    [191250] = {recipeDifficulty = 35, qualityID = 1}, -- Armor Spikes
    [191872] = {recipeDifficulty = 30, qualityID = 2}, 
    [191873] = {recipeDifficulty = 25, qualityID = 3}, 


    --- 10.1 Additions
    -- General
    [204673] = {recipeDifficulty = 150},-- Titan Matrix V
    [204681] = {recipeDifficulty = 160},-- Enchanted Whelpling's Shadowflame Crest
    [204682] = {recipeDifficulty = 30}, -- Enchanted Wyrm’s Shadowflame Crest
    [204697] = {recipeDifficulty = 50}, -- Enchanted Aspect’s Shadowflame Crest
    
    -- Leatherworking
    [204708] = {recipeDifficulty = 35}, -- Shadowflame Tempered Armor Patch
    [204709] = {recipeDifficulty = 30},
    [204710] = {recipeDifficulty = 25},
    
    -- Tailoring
    [205012] = {recipeDifficulty = 25}, -- Reserve Parachute

    --- 10.2 Additions
    -- General
    [206977] = {recipeDifficulty = 160},-- Enchanted Whelpling's Shadowflame Crest
    [206960] = {recipeDifficulty = 30}, -- Enchanted Wyrm’s Shadowflame Crest
    [206961] = {recipeDifficulty = 50}, -- Enchanted Aspect’s Shadowflame Crest

    -- Tailoring
    [210671] = {recipeDifficulty = 35, qualityID = 1}, -- Verdant Tether
    [210672] = {recipeDifficulty = 30, qualityID = 2}, 
    [210673] = {recipeDifficulty = 25, qualityID = 3}, 

    -- Leatherworking
    [208187] = {recipeDifficulty = 35, qualityID = 1}, -- Verdant Conduit
    [208188] = {recipeDifficulty = 30, qualityID = 2}, 
    [208189] = {recipeDifficulty = 25, qualityID = 3}, 

    -- Jewelcrafting
    [208746] = {recipeDifficulty = 35, qualityID = 1}, -- Dreamtender's Charm
    [208747] = {recipeDifficulty = 30, qualityID = 2}, 
    [208748] = {recipeDifficulty = 25, qualityID = 3}, 

}