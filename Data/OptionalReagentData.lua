---@class CraftSim
local CraftSim = select(2, ...)
CraftSim.OPTIONAL_REAGENT_DATA = {
	[191250] = {
		qualityID = 1,
		name = "Armor Spikes",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[191532] = {
		qualityID = 1,
		name = "Potion Absorption Inhibitor",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[191533] = {
		qualityID = 2,
		name = "Potion Absorption Inhibitor",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[191534] = {
		qualityID = 3,
		name = "Potion Absorption Inhibitor",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[191872] = {
		qualityID = 2,
		name = "Armor Spikes",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[191873] = {
		qualityID = 3,
		name = "Armor Spikes",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[192552] = {
		qualityID = 3,
		name = "Draconic Missive of the Fireflash",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[192553] = {
		qualityID = 1,
		name = "Draconic Missive of the Fireflash",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[192554] = {
		qualityID = 2,
		name = "Draconic Missive of the Fireflash",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[193468] = {
		qualityID = 1,
		name = "Fang Adornments",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[193469] = {
		qualityID = 1,
		name = "Toxified Armor Patch",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[193551] = {
		qualityID = 2,
		name = "Fang Adornments",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[193552] = {
		qualityID = 2,
		name = "Toxified Armor Patch",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[193554] = {
		qualityID = 3,
		name = "Fang Adornments",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[193555] = {
		qualityID = 3,
		name = "Toxified Armor Patch",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[193941] = {
		qualityID = 1,
		name = "Bronzed Grip Wrappings",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[193942] = {
		qualityID = 2,
		name = "Bronzed Grip Wrappings",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[193943] = {
		qualityID = 3,
		name = "Bronzed Grip Wrappings",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[193944] = {
		qualityID = 1,
		name = "Blue Silken Lining",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[193945] = {
		qualityID = 2,
		name = "Blue Silken Lining",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[193946] = {
		qualityID = 3,
		name = "Blue Silken Lining",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[194566] = {
		qualityID = 3,
		name = "Draconic Missive of the Feverflare",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[194567] = {
		qualityID = 1,
		name = "Draconic Missive of the Feverflare",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[194568] = {
		qualityID = 2,
		name = "Draconic Missive of the Feverflare",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[194569] = {
		qualityID = 3,
		name = "Draconic Missive of the Aurora",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[194570] = {
		qualityID = 1,
		name = "Draconic Missive of the Aurora",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[194571] = {
		qualityID = 2,
		name = "Draconic Missive of the Aurora",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[194572] = {
		qualityID = 3,
		name = "Draconic Missive of the Quickblade",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[194573] = {
		qualityID = 1,
		name = "Draconic Missive of the Quickblade",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[194574] = {
		qualityID = 2,
		name = "Draconic Missive of the Quickblade",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[194575] = {
		qualityID = 3,
		name = "Draconic Missive of the Harmonious",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[194576] = {
		qualityID = 1,
		name = "Draconic Missive of the Harmonious",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[194577] = {
		qualityID = 2,
		name = "Draconic Missive of the Harmonious",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[194578] = {
		qualityID = 3,
		name = "Draconic Missive of the Peerless",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[194579] = {
		qualityID = 1,
		name = "Draconic Missive of the Peerless",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[194580] = {
		qualityID = 2,
		name = "Draconic Missive of the Peerless",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[194868] = {
		qualityID = 1,
		name = "Emberscale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[194869] = {
		qualityID = 1,
		name = "Sagescale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[194870] = {
		qualityID = 1,
		name = "Bronzescale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[194871] = {
		qualityID = 1,
		name = "Azurescale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[197921] = {
		qualityID = 1,
		name = "Primal Infusion",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[198046] = {
		qualityID = 2,
		name = "Concentrated Primal Infusion",
		expansionID = 9,
		stats = {
			increasedifficulty = 50,
		},
	},
	[198048] = {
		qualityID = 1,
		name = "Titan Training Matrix I",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198056] = {
		qualityID = 1,
		name = "Titan Training Matrix II",
		expansionID = 9,
		stats = {
			increasedifficulty = 40,
		},
	},
	[198058] = {
		qualityID = 2,
		name = "Titan Training Matrix III",
		expansionID = 9,
		stats = {
			increasedifficulty = 60,
		},
	},
	[198059] = {
		qualityID = 3,
		name = "Titan Training Matrix IV",
		expansionID = 9,
		stats = {
			increasedifficulty = 140,
		},
	},
	[198174] = {
		qualityID = 1,
		name = "Razor-Sharp Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[198175] = {
		qualityID = 2,
		name = "Razor-Sharp Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198176] = {
		qualityID = 3,
		name = "Razor-Sharp Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[198231] = {
		qualityID = 1,
		name = "Rapidly Ticking Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[198232] = {
		qualityID = 2,
		name = "Rapidly Ticking Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198233] = {
		qualityID = 3,
		name = "Rapidly Ticking Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[198236] = {
		qualityID = 1,
		name = "Meticulously-Tuned Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[198237] = {
		qualityID = 2,
		name = "Meticulously-Tuned Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198238] = {
		qualityID = 3,
		name = "Meticulously-Tuned Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[198253] = {
		qualityID = 1,
		name = "Calibrated Safety Switch",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198254] = {
		qualityID = 2,
		name = "Calibrated Safety Switch",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[198255] = {
		qualityID = 3,
		name = "Calibrated Safety Switch",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[198256] = {
		qualityID = 1,
		name = "Magazine of Healing Darts",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[198257] = {
		qualityID = 2,
		name = "Magazine of Healing Darts",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[198258] = {
		qualityID = 3,
		name = "Magazine of Healing Darts",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[198259] = {
		qualityID = 1,
		name = "Critical Failure Prevention Unit",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198260] = {
		qualityID = 2,
		name = "Critical Failure Prevention Unit",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[198261] = {
		qualityID = 3,
		name = "Critical Failure Prevention Unit",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[198307] = {
		qualityID = 1,
		name = "One-Size-Fits-All Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[198308] = {
		qualityID = 2,
		name = "One-Size-Fits-All Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198309] = {
		qualityID = 3,
		name = "One-Size-Fits-All Gear",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[198431] = {
		qualityID = 1,
		name = "Jetscale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198534] = {
		qualityID = 1,
		name = "Draconic Missive of Ingenuity",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[198535] = {
		qualityID = 2,
		name = "Draconic Missive of Ingenuity",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198536] = {
		qualityID = 3,
		name = "Draconic Missive of Ingenuity",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[198619] = {
		qualityID = 1,
		name = "Spring-Loaded Capacitor Casing",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[198620] = {
		qualityID = 2,
		name = "Spring-Loaded Capacitor Casing",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[198621] = {
		qualityID = 3,
		name = "Spring-Loaded Capacitor Casing",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[199051] = {
		qualityID = 2,
		name = "Azurescale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[199052] = {
		qualityID = 3,
		name = "Azurescale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[199053] = {
		qualityID = 2,
		name = "Bronzescale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[199054] = {
		qualityID = 3,
		name = "Bronzescale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[199055] = {
		qualityID = 2,
		name = "Emberscale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[199056] = {
		qualityID = 3,
		name = "Emberscale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[199057] = {
		qualityID = 2,
		name = "Jetscale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[199058] = {
		qualityID = 3,
		name = "Jetscale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[199059] = {
		qualityID = 2,
		name = "Sagescale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[199060] = {
		qualityID = 3,
		name = "Sagescale Sigil",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[200565] = {
		qualityID = 1,
		name = "Draconic Missive of Resourcefulness",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[200566] = {
		qualityID = 2,
		name = "Draconic Missive of Resourcefulness",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[200567] = {
		qualityID = 3,
		name = "Draconic Missive of Resourcefulness",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[200568] = {
		qualityID = 1,
		name = "Draconic Missive of Multicraft",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[200569] = {
		qualityID = 2,
		name = "Draconic Missive of Multicraft",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[200570] = {
		qualityID = 3,
		name = "Draconic Missive of Multicraft",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[200571] = {
		qualityID = 1,
		name = "Draconic Missive of Crafting Speed",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[200572] = {
		qualityID = 2,
		name = "Draconic Missive of Crafting Speed",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[200573] = {
		qualityID = 3,
		name = "Draconic Missive of Crafting Speed",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[200574] = {
		qualityID = 1,
		name = "Draconic Missive of Finesse",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[200575] = {
		qualityID = 2,
		name = "Draconic Missive of Finesse",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[200576] = {
		qualityID = 3,
		name = "Draconic Missive of Finesse",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[200577] = {
		qualityID = 1,
		name = "Draconic Missive of Perception",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[200578] = {
		qualityID = 2,
		name = "Draconic Missive of Perception",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[200579] = {
		qualityID = 3,
		name = "Draconic Missive of Perception",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[200580] = {
		qualityID = 1,
		name = "Draconic Missive of Deftness",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[200581] = {
		qualityID = 2,
		name = "Draconic Missive of Deftness",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[200582] = {
		qualityID = 3,
		name = "Draconic Missive of Deftness",
		expansionID = 9,
		stats = {
			increasedifficulty = 15,
		},
	},
	[200652] = {
		qualityID = 1,
		name = "Alchemical Flavor Pocket",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[204673] = {
		qualityID = 4,
		name = "Titan Training Matrix V",
		expansionID = 9,
		stats = {
			increasedifficulty = 150,
		},
	},
	[204681] = {
		qualityID = 5,
		name = "Enchanted Whelpling's Shadowflame Crest",
		expansionID = 9,
		stats = {
			increasedifficulty = 160,
		},
	},
	[204682] = {
		qualityID = 1,
		name = "Enchanted Wyrm's Shadowflame Crest",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[204697] = {
		qualityID = 2,
		name = "Enchanted Aspect's Shadowflame Crest",
		expansionID = 9,
		stats = {
			increasedifficulty = 50,
		},
	},
	[204708] = {
		qualityID = 1,
		name = "Shadowflame-Tempered Armor Patch",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[204709] = {
		qualityID = 2,
		name = "Shadowflame-Tempered Armor Patch",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[204710] = {
		qualityID = 3,
		name = "Shadowflame-Tempered Armor Patch",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[204909] = {
		qualityID = 1,
		name = "Statuette of Foreseen Power",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[205012] = {
		qualityID = 1,
		name = "Reserve Parachute",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[205115] = {
		qualityID = 2,
		name = "Statuette of Foreseen Power",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[205170] = {
		qualityID = 3,
		name = "Statuette of Foreseen Power",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[205171] = {
		qualityID = 1,
		name = "Figurine of the Gathering Storm",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[205172] = {
		qualityID = 2,
		name = "Figurine of the Gathering Storm",
		expansionID = 9,
		stats = {
			increasedifficulty = 20,
		},
	},
	[205173] = {
		qualityID = 3,
		name = "Figurine of the Gathering Storm",
		expansionID = 9,
		stats = {
			increasedifficulty = 10,
		},
	},
	[205411] = {
		qualityID = 1,
		name = "Medical Wrap Kit",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[206960] = {
		qualityID = 1,
		name = "Enchanted Wyrm's Dreaming Crest",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[206961] = {
		qualityID = 2,
		name = "Enchanted Aspect's Dreaming Crest",
		expansionID = 9,
		stats = {
			increasedifficulty = 50,
		},
	},
	[206977] = {
		qualityID = 6,
		name = "Enchanted Whelpling's Dreaming Crest",
		expansionID = 9,
		stats = {
			increasedifficulty = 160,
		},
	},
	[208187] = {
		qualityID = 1,
		name = "Verdant Conduit",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[208188] = {
		qualityID = 2,
		name = "Verdant Conduit",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[208189] = {
		qualityID = 3,
		name = "Verdant Conduit",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[208746] = {
		qualityID = 1,
		name = "Dreamtender's Charm",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[208747] = {
		qualityID = 2,
		name = "Dreamtender's Charm",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[208748] = {
		qualityID = 3,
		name = "Dreamtender's Charm",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[210671] = {
		qualityID = 1,
		name = "Verdant Tether",
		expansionID = 9,
		stats = {
			increasedifficulty = 35,
		},
	},
	[210672] = {
		qualityID = 2,
		name = "Verdant Tether",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[210673] = {
		qualityID = 3,
		name = "Verdant Tether",
		expansionID = 9,
		stats = {
			increasedifficulty = 25,
		},
	},
	[211518] = {
		qualityID = 1,
		name = "Enchanted Wyrm's Awakened Crest",
		expansionID = 9,
		stats = {
			increasedifficulty = 30,
		},
	},
	[211519] = {
		qualityID = 2,
		name = "Enchanted Aspect's Awakened Crest",
		expansionID = 9,
		stats = {
			increasedifficulty = 50,
		},
	},
	[211520] = {
		qualityID = 7,
		name = "Enchanted Whelpling's Awakened Crest",
		expansionID = 9,
		stats = {
			increasedifficulty = 160,
		},
	},
	[213768] = {
		qualityID = 1,
		name = "Elemental Focusing Lens",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[213769] = {
		qualityID = 2,
		name = "Elemental Focusing Lens",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[213770] = {
		qualityID = 3,
		name = "Elemental Focusing Lens",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[213771] = {
		qualityID = 1,
		name = "Prismatic Null Stone",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[213772] = {
		qualityID = 2,
		name = "Prismatic Null Stone",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[213773] = {
		qualityID = 3,
		name = "Prismatic Null Stone",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[213774] = {
		qualityID = 1,
		name = "Captured Starlight",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[213775] = {
		qualityID = 2,
		name = "Captured Starlight",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[213776] = {
		qualityID = 3,
		name = "Captured Starlight",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[219495] = {
		qualityID = 1,
		name = "Blessed Weapon Grip",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[219496] = {
		qualityID = 2,
		name = "Blessed Weapon Grip",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[219497] = {
		qualityID = 3,
		name = "Blessed Weapon Grip",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[219504] = {
		qualityID = 1,
		name = "Writhing Armor Banding",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[219505] = {
		qualityID = 2,
		name = "Writhing Armor Banding",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[219506] = {
		qualityID = 3,
		name = "Writhing Armor Banding",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221911] = {
		qualityID = 1,
		name = "Serrated Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221912] = {
		qualityID = 2,
		name = "Serrated Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221913] = {
		qualityID = 3,
		name = "Serrated Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221914] = {
		qualityID = 1,
		name = "Overclocked Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221915] = {
		qualityID = 2,
		name = "Overclocked Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221916] = {
		qualityID = 3,
		name = "Overclocked Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221917] = {
		qualityID = 1,
		name = "Impeccable Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221918] = {
		qualityID = 2,
		name = "Impeccable Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221919] = {
		qualityID = 3,
		name = "Impeccable Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221920] = {
		qualityID = 1,
		name = "Adjustable Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221921] = {
		qualityID = 2,
		name = "Adjustable Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221922] = {
		qualityID = 3,
		name = "Adjustable Cogwheel",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221923] = {
		qualityID = 1,
		name = "Recalibrated Safety Switch",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221924] = {
		qualityID = 2,
		name = "Recalibrated Safety Switch",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221925] = {
		qualityID = 3,
		name = "Recalibrated Safety Switch",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221926] = {
		qualityID = 1,
		name = "Blame Redirection Device",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221927] = {
		qualityID = 2,
		name = "Blame Redirection Device",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221928] = {
		qualityID = 3,
		name = "Blame Redirection Device",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221932] = {
		qualityID = 1,
		name = "Complicated Fuse Box",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221933] = {
		qualityID = 2,
		name = "Complicated Fuse Box",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221934] = {
		qualityID = 3,
		name = "Complicated Fuse Box",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221935] = {
		qualityID = 1,
		name = "Pouch of Pocket Grenades",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221936] = {
		qualityID = 2,
		name = "Pouch of Pocket Grenades",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221937] = {
		qualityID = 3,
		name = "Pouch of Pocket Grenades",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221938] = {
		qualityID = 1,
		name = "Concealed Chaos Module",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221939] = {
		qualityID = 2,
		name = "Concealed Chaos Module",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221940] = {
		qualityID = 3,
		name = "Concealed Chaos Module",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[221941] = {
		qualityID = 1,
		name = "Energy Redistribution Beacon",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[221942] = {
		qualityID = 2,
		name = "Energy Redistribution Beacon",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[221943] = {
		qualityID = 3,
		name = "Energy Redistribution Beacon",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222579] = {
		qualityID = 1,
		name = "Algari Missive of the Aurora",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222580] = {
		qualityID = 2,
		name = "Algari Missive of the Aurora",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222581] = {
		qualityID = 3,
		name = "Algari Missive of the Aurora",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222582] = {
		qualityID = 1,
		name = "Algari Missive of the Feverflare",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222583] = {
		qualityID = 2,
		name = "Algari Missive of the Feverflare",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222584] = {
		qualityID = 3,
		name = "Algari Missive of the Feverflare",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222585] = {
		qualityID = 1,
		name = "Algari Missive of the Fireflash",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222586] = {
		qualityID = 2,
		name = "Algari Missive of the Fireflash",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222587] = {
		qualityID = 3,
		name = "Algari Missive of the Fireflash",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222588] = {
		qualityID = 1,
		name = "Algari Missive of the Harmonious",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222589] = {
		qualityID = 2,
		name = "Algari Missive of the Harmonious",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222590] = {
		qualityID = 3,
		name = "Algari Missive of the Harmonious",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222591] = {
		qualityID = 1,
		name = "Algari Missive of the Peerless",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222592] = {
		qualityID = 2,
		name = "Algari Missive of the Peerless",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222593] = {
		qualityID = 3,
		name = "Algari Missive of the Peerless",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222594] = {
		qualityID = 1,
		name = "Algari Missive of the Quickblade",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222595] = {
		qualityID = 2,
		name = "Algari Missive of the Quickblade",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222596] = {
		qualityID = 3,
		name = "Algari Missive of the Quickblade",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222626] = {
		qualityID = 1,
		name = "Algari Missive of Ingenuity",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222627] = {
		qualityID = 2,
		name = "Algari Missive of Ingenuity",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222628] = {
		qualityID = 3,
		name = "Algari Missive of Ingenuity",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222629] = {
		qualityID = 1,
		name = "Algari Missive of Resourcefulness",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222630] = {
		qualityID = 2,
		name = "Algari Missive of Resourcefulness",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222631] = {
		qualityID = 3,
		name = "Algari Missive of Resourcefulness",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222632] = {
		qualityID = 1,
		name = "Algari Missive of Multicraft",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222633] = {
		qualityID = 2,
		name = "Algari Missive of Multicraft",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222634] = {
		qualityID = 3,
		name = "Algari Missive of Multicraft",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222635] = {
		qualityID = 1,
		name = "Algari Missive of Crafting Speed",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222636] = {
		qualityID = 2,
		name = "Algari Missive of Crafting Speed",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222637] = {
		qualityID = 3,
		name = "Algari Missive of Crafting Speed",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222638] = {
		qualityID = 1,
		name = "Algari Missive of Finesse",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222639] = {
		qualityID = 2,
		name = "Algari Missive of Finesse",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222640] = {
		qualityID = 3,
		name = "Algari Missive of Finesse",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222641] = {
		qualityID = 1,
		name = "Algari Missive of Perception",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222642] = {
		qualityID = 2,
		name = "Algari Missive of Perception",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222643] = {
		qualityID = 3,
		name = "Algari Missive of Perception",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222644] = {
		qualityID = 1,
		name = "Algari Missive of Deftness",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222645] = {
		qualityID = 2,
		name = "Algari Missive of Deftness",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222646] = {
		qualityID = 3,
		name = "Algari Missive of Deftness",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222868] = {
		qualityID = 1,
		name = "Dawnthread Lining",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222869] = {
		qualityID = 2,
		name = "Dawnthread Lining",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222870] = {
		qualityID = 3,
		name = "Dawnthread Lining",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[222871] = {
		qualityID = 1,
		name = "Duskthread Lining",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[222872] = {
		qualityID = 2,
		name = "Duskthread Lining",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[222873] = {
		qualityID = 3,
		name = "Duskthread Lining",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[224069] = {
		qualityID = 1,
		name = "Enchanted Weathered Harbinger Crest",
		expansionID = 10,
		stats = {
			increasedifficulty = 100,
		},
	},
	[224072] = {
		qualityID = 1,
		name = "Enchanted Runed Harbinger Crest",
		expansionID = 10,
		stats = {
			increasedifficulty = 10,
		},
	},
	[224073] = {
		qualityID = 2,
		name = "Enchanted Gilded Harbinger Crest",
		expansionID = 10,
		stats = {
			increasedifficulty = 20,
		},
	},
	[226022] = {
		qualityID = 1,
		name = "Darkmoon Sigil: Ascension",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[226023] = {
		qualityID = 2,
		name = "Darkmoon Sigil: Ascension",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[226024] = {
		qualityID = 3,
		name = "Darkmoon Sigil: Ascension",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[226025] = {
		qualityID = 1,
		name = "Darkmoon Sigil: Radiance",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[226026] = {
		qualityID = 2,
		name = "Darkmoon Sigil: Radiance",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[226027] = {
		qualityID = 3,
		name = "Darkmoon Sigil: Radiance",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[226028] = {
		qualityID = 1,
		name = "Darkmoon Sigil: Symbiosis",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[226029] = {
		qualityID = 2,
		name = "Darkmoon Sigil: Symbiosis",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[226030] = {
		qualityID = 3,
		name = "Darkmoon Sigil: Symbiosis",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[226031] = {
		qualityID = 1,
		name = "Darkmoon Sigil: Vivacity",
		expansionID = 10,
		stats = {
			increasedifficulty = 25,
		},
	},
	[226032] = {
		qualityID = 2,
		name = "Darkmoon Sigil: Vivacity",
		expansionID = 10,
		stats = {
			increasedifficulty = 15,
		},
	},
	[226033] = {
		qualityID = 3,
		name = "Darkmoon Sigil: Vivacity",
		expansionID = 10,
		stats = {
			increasedifficulty = 5,
		},
	},
	[228338] = {
		qualityID = 1,
		name = "Soul Sigil I",
		expansionID = 10,
		stats = {
			increasedifficulty = 20,
		},
	},
	[228339] = {
		qualityID = 1,
		name = "Soul Sigil II",
		expansionID = 10,
		stats = {
			increasedifficulty = 40,
		},
	},
	[230935] = {
		qualityID = 2,
		name = "Enchanted Gilded Undermine Crest",
		expansionID = 10,
		stats = {
			increasedifficulty = 20,
		},
	},
	[230936] = {
		qualityID = 1,
		name = "Enchanted Runed Undermine Crest",
		expansionID = 10,
		stats = {
			increasedifficulty = 10,
		},
	},
	[230937] = {
		qualityID = 2,
		name = "Enchanted Weathered Undermine Crest",
		expansionID = 10,
		stats = {
			increasedifficulty = 100,
		},
	},
	[231767] = {
		qualityID = 3,
		name = "Enchanted Weathered Ethereal Crest",
		expansionID = 10,
		stats = {
			increasedifficulty = 100,
		},
	},
	[231768] = {
		qualityID = 2,
		name = "Enchanted Gilded Ethereal Crest",
		expansionID = 10,
		stats = {
			increasedifficulty = 20,
		},
	},
	[231769] = {
		qualityID = 1,
		name = "Enchanted Runed Ethereal Crest",
		expansionID = 10,
		stats = {
			increasedifficulty = 10,
		},
	},
	[240164] = {
		qualityID = 1,
		name = "Sunfire Silk Lining",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[240165] = {
		qualityID = 2,
		name = "Sunfire Silk Lining",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[240166] = {
		qualityID = 1,
		name = "Arcanoweave Lining",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[240167] = {
		qualityID = 2,
		name = "Arcanoweave Lining",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[244603] = {
		qualityID = 1,
		name = "Blessed Pango Charm",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[244604] = {
		qualityID = 2,
		name = "Blessed Pango Charm",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[244607] = {
		qualityID = 1,
		name = "Primal Spore Binding",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[244608] = {
		qualityID = 2,
		name = "Primal Spore Binding",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[244674] = {
		qualityID = 1,
		name = "Devouring Banding",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[244675] = {
		qualityID = 2,
		name = "Devouring Banding",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245781] = {
		qualityID = 1,
		name = "Thalassian Missive of the Aurora",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245782] = {
		qualityID = 2,
		name = "Thalassian Missive of the Aurora",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245783] = {
		qualityID = 1,
		name = "Thalassian Missive of the Feverflare",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245784] = {
		qualityID = 2,
		name = "Thalassian Missive of the Feverflare",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245785] = {
		qualityID = 1,
		name = "Thalassian Missive of the Fireflash",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245786] = {
		qualityID = 2,
		name = "Thalassian Missive of the Fireflash",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245787] = {
		qualityID = 1,
		name = "Thalassian Missive of the Harmonious",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245788] = {
		qualityID = 2,
		name = "Thalassian Missive of the Harmonious",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245789] = {
		qualityID = 1,
		name = "Thalassian Missive of the Peerless",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245790] = {
		qualityID = 2,
		name = "Thalassian Missive of the Peerless",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245791] = {
		qualityID = 1,
		name = "Thalassian Missive of the Quickblade",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245792] = {
		qualityID = 2,
		name = "Thalassian Missive of the Quickblade",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245814] = {
		qualityID = 1,
		name = "Thalassian Missive of Ingenuity",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245815] = {
		qualityID = 2,
		name = "Thalassian Missive of Ingenuity",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245816] = {
		qualityID = 1,
		name = "Thalassian Missive of Resourcefulness",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245817] = {
		qualityID = 2,
		name = "Thalassian Missive of Resourcefulness",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245818] = {
		qualityID = 1,
		name = "Thalassian Missive of Multicraft",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245819] = {
		qualityID = 2,
		name = "Thalassian Missive of Multicraft",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245820] = {
		qualityID = 1,
		name = "Thalassian Missive of Crafting Speed",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245821] = {
		qualityID = 2,
		name = "Thalassian Missive of Crafting Speed",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245822] = {
		qualityID = 1,
		name = "Thalassian Missive of Finesse",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245823] = {
		qualityID = 2,
		name = "Thalassian Missive of Finesse",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245824] = {
		qualityID = 1,
		name = "Thalassian Missive of Perception",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245825] = {
		qualityID = 2,
		name = "Thalassian Missive of Perception",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245826] = {
		qualityID = 1,
		name = "Thalassian Missive of Deftness",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245827] = {
		qualityID = 2,
		name = "Thalassian Missive of Deftness",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245871] = {
		qualityID = 1,
		name = "Darkmoon Sigil: Blood",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245872] = {
		qualityID = 2,
		name = "Darkmoon Sigil: Blood",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245873] = {
		qualityID = 1,
		name = "Darkmoon Sigil: Void",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245874] = {
		qualityID = 2,
		name = "Darkmoon Sigil: Void",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245875] = {
		qualityID = 1,
		name = "Darkmoon Sigil: Hunt",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245876] = {
		qualityID = 2,
		name = "Darkmoon Sigil: Hunt",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[245877] = {
		qualityID = 1,
		name = "Darkmoon Sigil: Rot",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[245878] = {
		qualityID = 2,
		name = "Darkmoon Sigil: Rot",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[248132] = {
		qualityID = 1,
		name = "Kinetic Ankle Primers",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[248133] = {
		qualityID = 2,
		name = "Kinetic Ankle Primers",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[248135] = {
		qualityID = 1,
		name = "B1P, Scorcher of Souls",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[248592] = {
		qualityID = 2,
		name = "B1P, Scorcher of Souls",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[251487] = {
		qualityID = 1,
		name = "Prismatic Focusing Iris",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[251488] = {
		qualityID = 2,
		name = "Prismatic Focusing Iris",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[251489] = {
		qualityID = 1,
		name = "Stabilizing Gemstone Bandolier",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[251490] = {
		qualityID = 2,
		name = "Stabilizing Gemstone Bandolier",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[255843] = {
		qualityID = 1,
		name = "HU5H, Nonchalant Pup",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[255844] = {
		qualityID = 2,
		name = "HU5H, Nonchalant Pup",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[257735] = {
		qualityID = 1,
		name = "B0P, Curator of Booms",
		expansionID = 11,
		stats = {
			increasedifficulty = 15,
		},
	},
	[257741] = {
		qualityID = 2,
		name = "B0P, Curator of Booms",
		expansionID = 11,
		stats = {
			increasedifficulty = 5,
		},
	},
	[191511] = {
		qualityID = 1,
		name = "Stable Fluidic Draconium",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 15.0,
		},
	},
	[191512] = {
		qualityID = 2,
		name = "Stable Fluidic Draconium",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 20.0,
		},
	},
	[191513] = {
		qualityID = 3,
		name = "Stable Fluidic Draconium",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 25.0,
		},
	},
	[191514] = {
		qualityID = 1,
		name = "Brood Salt",
		expansionID = 9,
		stats = {
			ingenuity = 30.0,
			craftingspeed = 12.0,
		},
	},
	[191515] = {
		qualityID = 2,
		name = "Brood Salt",
		expansionID = 9,
		stats = {
			ingenuity = 40.0,
			craftingspeed = 16.0,
		},
	},
	[191516] = {
		qualityID = 3,
		name = "Brood Salt",
		expansionID = 9,
		stats = {
			ingenuity = 50.0,
			craftingspeed = 20.0,
		},
	},
	[191517] = {
		qualityID = 1,
		name = "Writhefire Oil",
		expansionID = 9,
		stats = {
			modifyskillgain = 9.0,
			increasedifficulty = 18.0,
		},
	},
	[191518] = {
		qualityID = 2,
		name = "Writhefire Oil",
		expansionID = 9,
		stats = {
			modifyskillgain = 12.0,
			increasedifficulty = 24.0,
		},
	},
	[191519] = {
		qualityID = 3,
		name = "Writhefire Oil",
		expansionID = 9,
		stats = {
			modifyskillgain = 15.0,
			increasedifficulty = 30.0,
		},
	},
	[191520] = {
		qualityID = 1,
		name = "Agitating Potion Augmentation",
		expansionID = 9,
		stats = {
			ingenuity = 30.0,
			multicraft = 27.0,
		},
	},
	[191521] = {
		qualityID = 2,
		name = "Agitating Potion Augmentation",
		expansionID = 9,
		stats = {
			ingenuity = 40.0,
			multicraft = 36.0,
		},
	},
	[191522] = {
		qualityID = 3,
		name = "Agitating Potion Augmentation",
		expansionID = 9,
		stats = {
			ingenuity = 50.0,
			multicraft = 45.0,
		},
	},
	[191523] = {
		qualityID = 1,
		name = "Reactive Phial Embellishment",
		expansionID = 9,
		stats = {
			ingenuity = 30.0,
			multicraft = 27.0,
		},
	},
	[191524] = {
		qualityID = 2,
		name = "Reactive Phial Embellishment",
		expansionID = 9,
		stats = {
			ingenuity = 40.0,
			multicraft = 36.0,
		},
	},
	[191525] = {
		qualityID = 3,
		name = "Reactive Phial Embellishment",
		expansionID = 9,
		stats = {
			ingenuity = 50.0,
			multicraft = 45.0,
		},
	},
	[191526] = {
		qualityID = 1,
		name = "Lesser Illustrious Insight",
		expansionID = 9,
		stats = {
			skill = 30.0,
		},
	},
	[191529] = {
		qualityID = 1,
		name = "Illustrious Insight",
		expansionID = 9,
		stats = {
			skill = 30.0,
		},
	},
	[192894] = {
		qualityID = 1,
		name = "Blotting Sand",
		expansionID = 9,
		stats = {
			modifyskillgain = 9.0,
			increasedifficulty = 18.0,
		},
	},
	[192895] = {
		qualityID = 2,
		name = "Blotting Sand",
		expansionID = 9,
		stats = {
			modifyskillgain = 12.0,
			increasedifficulty = 24.0,
		},
	},
	[192896] = {
		qualityID = 3,
		name = "Blotting Sand",
		expansionID = 9,
		stats = {
			modifyskillgain = 15.0,
			increasedifficulty = 30.0,
		},
	},
	[192897] = {
		qualityID = 1,
		name = "Pounce",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 7.199999999999999,
			ingenuity = 30.0,
		},
	},
	[192898] = {
		qualityID = 2,
		name = "Pounce",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 9.600000000000001,
			ingenuity = 40.0,
		},
	},
	[192899] = {
		qualityID = 3,
		name = "Pounce",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 12.0,
			ingenuity = 50.0,
		},
	},
	[193950] = {
		qualityID = 1,
		name = "Abrasive Polishing Cloth",
		expansionID = 9,
		stats = {
			modifyskillgain = 9.0,
			increasedifficulty = 18.0,
		},
	},
	[193951] = {
		qualityID = 2,
		name = "Abrasive Polishing Cloth",
		expansionID = 9,
		stats = {
			modifyskillgain = 12.0,
			increasedifficulty = 24.0,
		},
	},
	[193952] = {
		qualityID = 3,
		name = "Abrasive Polishing Cloth",
		expansionID = 9,
		stats = {
			modifyskillgain = 15.0,
			increasedifficulty = 30.0,
		},
	},
	[193953] = {
		qualityID = 1,
		name = "Vibrant Polishing Cloth",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 7.199999999999999,
			ingenuity = 30.0,
		},
	},
	[193954] = {
		qualityID = 2,
		name = "Vibrant Polishing Cloth",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 9.600000000000001,
			ingenuity = 40.0,
		},
	},
	[193955] = {
		qualityID = 3,
		name = "Vibrant Polishing Cloth",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 12.0,
			ingenuity = 50.0,
		},
	},
	[193956] = {
		qualityID = 1,
		name = "Blazing Embroidery Thread",
		expansionID = 9,
		stats = {
			modifyskillgain = 9.0,
			increasedifficulty = 18.0,
		},
	},
	[193957] = {
		qualityID = 2,
		name = "Blazing Embroidery Thread",
		expansionID = 9,
		stats = {
			modifyskillgain = 12.0,
			increasedifficulty = 24.0,
		},
	},
	[193958] = {
		qualityID = 3,
		name = "Blazing Embroidery Thread",
		expansionID = 9,
		stats = {
			modifyskillgain = 15.0,
			increasedifficulty = 30.0,
		},
	},
	[193959] = {
		qualityID = 1,
		name = "Chromatic Embroidery Thread",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 7.199999999999999,
			craftingspeed = 12.0,
		},
	},
	[193960] = {
		qualityID = 2,
		name = "Chromatic Embroidery Thread",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 9.600000000000001,
			craftingspeed = 16.0,
		},
	},
	[193961] = {
		qualityID = 3,
		name = "Chromatic Embroidery Thread",
		expansionID = 9,
		stats = {
			ingenuityrefundincrease = 12.0,
			craftingspeed = 20.0,
		},
	},
	[193962] = {
		qualityID = 1,
		name = "Shimmering Embroidery Thread",
		expansionID = 9,
		stats = {
			reagentssavedfromresourcefulness = 15.0,
		},
	},
	[193963] = {
		qualityID = 2,
		name = "Shimmering Embroidery Thread",
		expansionID = 9,
		stats = {
			reagentssavedfromresourcefulness = 20.0,
		},
	},
	[193964] = {
		qualityID = 3,
		name = "Shimmering Embroidery Thread",
		expansionID = 9,
		stats = {
			reagentssavedfromresourcefulness = 25.0,
		},
	},
	[194902] = {
		qualityID = 1,
		name = "Ooey-Gooey Chocolate",
		expansionID = 9,
		stats = {
			additionalitemscraftedwithmulticraft = 25.0,
			multicraft = 1100.0,
		},
	},
	[197764] = {
		qualityID = 1,
		name = "Salad on the Side",
		expansionID = 9,
		stats = {
			multicraft = 90.0,
		},
	},
	[197765] = {
		qualityID = 1,
		name = "Impossibly Sharp Cutting Knife",
		expansionID = 9,
		stats = {
			resourcefulness = 110.0,
		},
	},
	[198216] = {
		qualityID = 1,
		name = "Haphazardly Tethered Wires",
		expansionID = 9,
		stats = {
			modifyskillgain = 9.0,
			increasedifficulty = 18.0,
		},
	},
	[198217] = {
		qualityID = 2,
		name = "Haphazardly Tethered Wires",
		expansionID = 9,
		stats = {
			modifyskillgain = 12.0,
			increasedifficulty = 24.0,
		},
	},
	[198218] = {
		qualityID = 3,
		name = "Haphazardly Tethered Wires",
		expansionID = 9,
		stats = {
			modifyskillgain = 15.0,
			increasedifficulty = 30.0,
		},
	},
	[198219] = {
		qualityID = 1,
		name = "Overcharged Overclocker",
		expansionID = 9,
		stats = {
			resourcefulness = 33.0,
			ingenuity = 30.0,
		},
	},
	[198220] = {
		qualityID = 2,
		name = "Overcharged Overclocker",
		expansionID = 9,
		stats = {
			resourcefulness = 44.0,
			ingenuity = 40.0,
		},
	},
	[198221] = {
		qualityID = 3,
		name = "Overcharged Overclocker",
		expansionID = 9,
		stats = {
			resourcefulness = 55.0,
			ingenuity = 50.0,
		},
	},
	[213762] = {
		qualityID = 1,
		name = "Sifted Cave Sand",
		expansionID = 10,
		stats = {
			reagentssavedfromresourcefulness = 6.0,
			resourcefulness = 75.0,
		},
	},
	[213763] = {
		qualityID = 2,
		name = "Sifted Cave Sand",
		expansionID = 10,
		stats = {
			reagentssavedfromresourcefulness = 9.0,
			resourcefulness = 112.5,
		},
	},
	[213764] = {
		qualityID = 3,
		name = "Sifted Cave Sand",
		expansionID = 10,
		stats = {
			reagentssavedfromresourcefulness = 12.0,
			resourcefulness = 150.0,
		},
	},
	[213765] = {
		qualityID = 1,
		name = "Ominous Energy Crystal",
		expansionID = 10,
		stats = {
			ingenuity = 150.0,
		},
	},
	[213766] = {
		qualityID = 2,
		name = "Ominous Energy Crystal",
		expansionID = 10,
		stats = {
			ingenuity = 225.0,
		},
	},
	[213767] = {
		qualityID = 3,
		name = "Ominous Energy Crystal",
		expansionID = 10,
		stats = {
			ingenuity = 300.0,
		},
	},
	[214043] = {
		qualityID = 1,
		name = "Glittering Gemdust",
		expansionID = 10,
		stats = {
			skill = 50.0,
			modifyskillgain = 25.0,
		},
	},
	[222499] = {
		qualityID = 1,
		name = "Forged Framework",
		expansionID = 10,
		stats = {
			ingenuity = 150.0,
		},
	},
	[222500] = {
		qualityID = 2,
		name = "Forged Framework",
		expansionID = 10,
		stats = {
			ingenuity = 225.0,
		},
	},
	[222501] = {
		qualityID = 3,
		name = "Forged Framework",
		expansionID = 10,
		stats = {
			ingenuity = 300.0,
		},
	},
	[222511] = {
		qualityID = 1,
		name = "Adjustable Framework",
		expansionID = 10,
		stats = {
			additionalitemscraftedwithmulticraft = 12.5,
		},
	},
	[222512] = {
		qualityID = 2,
		name = "Adjustable Framework",
		expansionID = 10,
		stats = {
			additionalitemscraftedwithmulticraft = 18.75,
		},
	},
	[222513] = {
		qualityID = 3,
		name = "Adjustable Framework",
		expansionID = 10,
		stats = {
			additionalitemscraftedwithmulticraft = 25.0,
		},
	},
	[222514] = {
		qualityID = 1,
		name = "Tempered Framework",
		expansionID = 10,
		stats = {
			resourcefulness = 150.0,
		},
	},
	[222515] = {
		qualityID = 2,
		name = "Tempered Framework",
		expansionID = 10,
		stats = {
			resourcefulness = 225.0,
		},
	},
	[222516] = {
		qualityID = 3,
		name = "Tempered Framework",
		expansionID = 10,
		stats = {
			resourcefulness = 300.0,
		},
	},
	[222876] = {
		qualityID = 1,
		name = "Gritty Polishing Cloth",
		expansionID = 10,
		stats = {
			resourcefulness = 150.0,
		},
	},
	[222877] = {
		qualityID = 2,
		name = "Gritty Polishing Cloth",
		expansionID = 10,
		stats = {
			resourcefulness = 225.0,
		},
	},
	[222878] = {
		qualityID = 3,
		name = "Gritty Polishing Cloth",
		expansionID = 10,
		stats = {
			resourcefulness = 300.0,
		},
	},
	[222879] = {
		qualityID = 1,
		name = "Bright Polishing Cloth",
		expansionID = 10,
		stats = {
			additionalitemscraftedwithmulticraft = 12.5,
		},
	},
	[222880] = {
		qualityID = 2,
		name = "Bright Polishing Cloth",
		expansionID = 10,
		stats = {
			additionalitemscraftedwithmulticraft = 18.75,
		},
	},
	[222881] = {
		qualityID = 3,
		name = "Bright Polishing Cloth",
		expansionID = 10,
		stats = {
			additionalitemscraftedwithmulticraft = 25.0,
		},
	},
	[222882] = {
		qualityID = 1,
		name = "Weavercloth Embroidery Thread",
		expansionID = 10,
		stats = {
			ingenuity = 150.0,
		},
	},
	[222883] = {
		qualityID = 2,
		name = "Weavercloth Embroidery Thread",
		expansionID = 10,
		stats = {
			ingenuity = 225.0,
		},
	},
	[222884] = {
		qualityID = 3,
		name = "Weavercloth Embroidery Thread",
		expansionID = 10,
		stats = {
			ingenuity = 300.0,
		},
	},
	[222885] = {
		qualityID = 1,
		name = "Preserving Embroidery Thread",
		expansionID = 10,
		stats = {
			reagentssavedfromresourcefulness = 12.5,
		},
	},
	[222886] = {
		qualityID = 2,
		name = "Preserving Embroidery Thread",
		expansionID = 10,
		stats = {
			reagentssavedfromresourcefulness = 18.75,
		},
	},
	[222887] = {
		qualityID = 3,
		name = "Preserving Embroidery Thread",
		expansionID = 10,
		stats = {
			reagentssavedfromresourcefulness = 25.0,
		},
	},
	[224173] = {
		qualityID = 1,
		name = "Concentration Concentrate",
		expansionID = 10,
		stats = {
			reduceconcentrationcost = 6.0,
		},
	},
	[224174] = {
		qualityID = 2,
		name = "Concentration Concentrate",
		expansionID = 10,
		stats = {
			reduceconcentrationcost = 8.0,
		},
	},
	[224175] = {
		qualityID = 3,
		name = "Concentration Concentrate",
		expansionID = 10,
		stats = {
			reduceconcentrationcost = 10.0,
		},
	},
	[224176] = {
		qualityID = 3,
		name = "Mirror Powder",
		expansionID = 10,
		stats = {
			multicraft = 300.0,
		},
	},
	[224177] = {
		qualityID = 2,
		name = "Mirror Powder",
		expansionID = 10,
		stats = {
			multicraft = 240.0,
		},
	},
	[224178] = {
		qualityID = 1,
		name = "Mirror Powder",
		expansionID = 10,
		stats = {
			multicraft = 180.0,
		},
	},
	[225670] = {
		qualityID = 1,
		name = "Apprentice's Crafting License",
		expansionID = 10,
		stats = {
			skill = 5.0,
		},
	},
	[225671] = {
		qualityID = 1,
		name = "Stack of Pentagold Reviews",
		expansionID = 10,
		stats = {
			skill = 10.0,
		},
	},
	[225672] = {
		qualityID = 1,
		name = "Unraveled Instructions",
		expansionID = 10,
		stats = {
			skill = 20.0,
		},
	},
	[225673] = {
		qualityID = 1,
		name = "Artisan's Consortium Seal of Approval",
		expansionID = 10,
		stats = {
			skill = 40.0,
		},
	},
	[225912] = {
		qualityID = 1,
		name = "Hot Honeycomb",
		expansionID = 10,
		stats = {
			multicraft = 1100.0,
		},
	},
	[225987] = {
		qualityID = 1,
		name = "Bottled Brilliance",
		expansionID = 10,
		stats = {
			modifyskillgain = 20.0,
		},
	},
	[225988] = {
		qualityID = 2,
		name = "Bottled Brilliance",
		expansionID = 10,
		stats = {
			modifyskillgain = 30.0,
		},
	},
	[225989] = {
		qualityID = 3,
		name = "Bottled Brilliance",
		expansionID = 10,
		stats = {
			modifyskillgain = 40.0,
		},
	},
	[228401] = {
		qualityID = 1,
		name = "Bubbling Mycobloom Culture",
		expansionID = 10,
		stats = {
			resourcefulness = 150.0,
		},
	},
	[228402] = {
		qualityID = 2,
		name = "Bubbling Mycobloom Culture",
		expansionID = 10,
		stats = {
			resourcefulness = 225.0,
		},
	},
	[228403] = {
		qualityID = 3,
		name = "Bubbling Mycobloom Culture",
		expansionID = 10,
		stats = {
			resourcefulness = 300.0,
		},
	},
	[228404] = {
		qualityID = 1,
		name = "Petal Powder",
		expansionID = 10,
		stats = {
			additionalitemscraftedwithmulticraft = 12.5,
		},
	},
	[228405] = {
		qualityID = 2,
		name = "Petal Powder",
		expansionID = 10,
		stats = {
			additionalitemscraftedwithmulticraft = 18.75,
		},
	},
	[228406] = {
		qualityID = 3,
		name = "Petal Powder",
		expansionID = 10,
		stats = {
			additionalitemscraftedwithmulticraft = 25.0,
		},
	},
	[246447] = {
		qualityID = 1,
		name = "Apprentice's Scribbles",
		expansionID = 11,
		stats = {
			skill = 5.0,
		},
	},
	[246448] = {
		qualityID = 1,
		name = "Artisan's Ledger",
		expansionID = 11,
		stats = {
			skill = 10.0,
		},
	},
	[246449] = {
		qualityID = 1,
		name = "Mentor's Helpful Handiwork",
		expansionID = 11,
		stats = {
			skill = 20.0,
		},
	},
	[246450] = {
		qualityID = 1,
		name = "Artisan's Consortium Gold Star",
		expansionID = 11,
		stats = {
			skill = 50.0,
		},
	},
	[247719] = {
		qualityID = 1,
		name = "Multicraft Matrix",
		expansionID = 11,
		stats = {
			multicraft = 90.0,
		},
	},
	[247724] = {
		qualityID = 2,
		name = "Multicraft Manifold",
		expansionID = 11,
		stats = {
			multicraft = 90.0,
		},
	},
	[247725] = {
		qualityID = 1,
		name = "Resourceful Rebar",
		expansionID = 11,
		stats = {
			resourcefulness = 4.0,
		},
	},
	[247726] = {
		qualityID = 1,
		name = "Resourceful Routing",
		expansionID = 11,
		stats = {
			resourcefulness = 15.0,
		},
	},
	[247788] = {
		qualityID = 2,
		name = "Ingenious Identity",
		expansionID = 11,
		stats = {
			ingenuity = 25.0,
		},
	},
	[260630] = {
		qualityID = 1,
		name = "Ingenious Identifier",
		expansionID = 11,
		stats = {
			ingenuity = 5.0,
		},
	},
	[265800] = {
		qualityID = 1,
		name = "Earthy Garnish",
		expansionID = 11,
		stats = {
			resourcefulness = 110.0,
		},
	},
	[265801] = {
		qualityID = 1,
		name = "Savory Anomaly",
		expansionID = 11,
		stats = {
			resourcefulness = 110.0,
		},
	},
	[265803] = {
		qualityID = 1,
		name = "Bazaar Bites",
		expansionID = 11,
		stats = {
			multicraft = 1100.0,
			additionalitemscraftedwithmulticraft = 25.0,
		},
	},
	[210232] = {
		qualityID = 0,
		name = "Forged Aspirant's Heraldry",
		expansionID = 10,
		stats = {
			increasedifficulty = 50,
		},
	},
	[210233] = {
		qualityID = 0,
		name = "Forged Gladiator's Heraldry",
		expansionID = 10,
		stats = {
			increasedifficulty = 150,
		},
	},
	[229389] = {
		qualityID = 0,
		name = "Prized Aspirant's Heraldry",
		expansionID = 10,
		stats = {
			increasedifficulty = 50,
		},
	},
	[229390] = {
		qualityID = 0,
		name = "Prized Gladiator's Heraldry",
		expansionID = 10,
		stats = {
			increasedifficulty = 150,
		},
	},
	[230286] = {
		qualityID = 0,
		name = "Astral Aspirant's Heraldry",
		expansionID = 10,
		stats = {
			increasedifficulty = 50,
		},
	},
	[230287] = {
		qualityID = 0,
		name = "Astral Gladiator's Heraldry",
		expansionID = 10,
		stats = {
			increasedifficulty = 150,
		},
	},
	[256607] = {
		qualityID = 0,
		name = "Galactic Aspirant's Heraldry",
		expansionID = 11,
		stats = {
			increasedifficulty = 50,
		},
	},
	[256608] = {
		qualityID = 0,
		name = "Galactic Gladiator's Heraldry",
		expansionID = 11,
		stats = {
			increasedifficulty = 150,
		},
	},
}