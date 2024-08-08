---@class CraftSim
local CraftSim = select(2, ...)
CraftSim.OPTIONAL_REAGENT_DATA = {
	[191250] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[191252] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[191532] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[191533] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[191534] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[191872] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[191873] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[191874] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[191875] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[192552] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[192553] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[192554] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[193468] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[193469] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[193551] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[193552] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[193554] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[193555] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[193941] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[193942] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[193943] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[193944] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[193945] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[193946] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[194566] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[194567] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[194568] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[194569] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[194570] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[194571] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[194572] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[194573] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[194574] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[194575] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[194576] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[194577] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[194578] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[194579] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[194580] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[194868] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[194869] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[194870] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[194871] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[197921] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[198046] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 50,
			},
		},
	},
	[198048] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198056] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 40,
			},
		},
	},
	[198058] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 60,
			},
		},
	},
	[198059] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 140,
			},
		},
	},
	[198174] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[198175] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198176] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[198231] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[198232] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198233] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[198236] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[198237] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198238] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[198253] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198254] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[198255] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[198256] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[198257] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[198258] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[198259] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198260] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[198261] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[198307] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[198308] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198309] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[198431] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198534] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[198535] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198536] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[198619] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[198620] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[198621] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[199051] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[199052] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[199053] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[199054] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[199055] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[199056] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[199057] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[199058] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[199059] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[199060] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[200565] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[200566] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[200567] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[200568] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[200569] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[200570] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[200571] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[200572] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[200573] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[200574] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[200575] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[200576] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[200577] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[200578] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[200579] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[200580] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[200581] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[200582] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[200652] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[204673] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 150,
			},
		},
	},
	[204681] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 160,
			},
		},
	},
	[204682] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[204697] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 50,
			},
		},
	},
	[204708] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[204709] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[204710] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[204909] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[205012] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[205115] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[205170] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[205171] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[205172] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[205173] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[205411] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[206960] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[206961] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 50,
			},
		},
	},
	[206977] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 160,
			},
		},
	},
	[208187] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[208188] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[208189] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[208746] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[208747] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[208748] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[210671] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 35,
			},
		},
	},
	[210672] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[210673] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[211518] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 30,
			},
		},
	},
	[211519] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 50,
			},
		},
	},
	[211520] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 160,
			},
		},
	},
	[213768] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[213769] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[213770] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[213771] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[213772] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[213773] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[213774] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[213775] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[213776] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[219495] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[219496] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[219497] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[219504] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[219505] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[219506] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221911] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221912] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221913] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221914] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221915] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221916] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221917] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221918] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221919] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221920] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221921] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221922] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221923] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221924] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221925] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221926] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221927] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221928] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221932] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221933] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221934] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221935] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221936] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221937] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221938] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221939] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221940] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[221941] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[221942] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[221943] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222579] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222580] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222581] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222582] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222583] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222584] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222585] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222586] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222587] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222588] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222589] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222590] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222591] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222592] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222593] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222594] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222595] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222596] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222626] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222627] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222628] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222629] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222630] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222631] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222632] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222633] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222634] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222635] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222636] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222637] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222638] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222639] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222640] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222641] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222642] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222643] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222644] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222645] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222646] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222868] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222869] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222870] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[222871] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[222872] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[222873] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[224069] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 100,
			},
		},
	},
	[224072] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 10,
			},
		},
	},
	[224073] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[226022] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[226023] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[226024] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[226025] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[226026] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[226027] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[226028] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[226029] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[226030] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[226031] = {
		qualityID = 1,
		stats = {
			{
				increasedifficulty = 25,
			},
		},
	},
	[226032] = {
		qualityID = 2,
		stats = {
			{
				increasedifficulty = 15,
			},
		},
	},
	[226033] = {
		qualityID = 3,
		stats = {
			{
				increasedifficulty = 5,
			},
		},
	},
	[228338] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 20,
			},
		},
	},
	[228339] = {
		qualityID = 0,
		stats = {
			{
				increasedifficulty = 40,
			},
		},
	},
	[190653] = {
		qualityID = 0,
		stats = {
			{
				stat = "resourcefulness",
				amount = 10,
			},
			{
				stat = "ingenuity",
				amount = 10,
			},
		},
	},
	[191511] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 25,
			},
		},
	},
	[191512] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 25,
			},
		},
	},
	[191513] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 25,
			},
		},
	},
	[191514] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuity",
				amount = 50,
			},
			{
				stat = "craftingspeed",
				amount = 20,
			},
		},
	},
	[191515] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuity",
				amount = 50,
			},
			{
				stat = "craftingspeed",
				amount = 20,
			},
		},
	},
	[191516] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuity",
				amount = 50,
			},
			{
				stat = "craftingspeed",
				amount = 20,
			},
		},
	},
	[191517] = {
		qualityID = 1,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[191518] = {
		qualityID = 2,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[191519] = {
		qualityID = 3,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[191520] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuity",
				amount = 50,
			},
			{
				stat = "multicraft",
				amount = 45,
			},
		},
	},
	[191521] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuity",
				amount = 50,
			},
			{
				stat = "multicraft",
				amount = 45,
			},
		},
	},
	[191522] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuity",
				amount = 50,
			},
			{
				stat = "multicraft",
				amount = 45,
			},
		},
	},
	[191523] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuity",
				amount = 50,
			},
			{
				stat = "multicraft",
				amount = 45,
			},
		},
	},
	[191524] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuity",
				amount = 50,
			},
			{
				stat = "multicraft",
				amount = 45,
			},
		},
	},
	[191525] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuity",
				amount = 50,
			},
			{
				stat = "multicraft",
				amount = 45,
			},
		},
	},
	[191526] = {
		qualityID = 0,
		stats = {
			{
				stat = "skill",
				amount = 30,
			},
		},
	},
	[191529] = {
		qualityID = 0,
		stats = {
			{
				stat = "skill",
				amount = 30,
			},
		},
	},
	[192894] = {
		qualityID = 1,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[192895] = {
		qualityID = 2,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[192896] = {
		qualityID = 3,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[192897] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[192898] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[192899] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[193950] = {
		qualityID = 1,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[193951] = {
		qualityID = 2,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[193952] = {
		qualityID = 3,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[193953] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[193954] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[193955] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[193956] = {
		qualityID = 1,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[193957] = {
		qualityID = 2,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[193958] = {
		qualityID = 3,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[193959] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "craftingspeed",
				amount = 20,
			},
		},
	},
	[193960] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "craftingspeed",
				amount = 20,
			},
		},
	},
	[193961] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "craftingspeed",
				amount = 20,
			},
		},
	},
	[193962] = {
		qualityID = 1,
		stats = {
			{
				stat = "reagentssavedfromresourcefulness",
				amount = 25,
			},
		},
	},
	[193963] = {
		qualityID = 2,
		stats = {
			{
				stat = "reagentssavedfromresourcefulness",
				amount = 25,
			},
		},
	},
	[193964] = {
		qualityID = 3,
		stats = {
			{
				stat = "reagentssavedfromresourcefulness",
				amount = 25,
			},
		},
	},
	[194902] = {
		qualityID = 0,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
			{
				stat = "multicraft",
				amount = 1100,
			},
		},
	},
	[197764] = {
		qualityID = 0,
		stats = {
			{
				stat = "multicraft",
				amount = 90,
			},
		},
	},
	[197765] = {
		qualityID = 0,
		stats = {
			{
				stat = "resourcefulness",
				amount = 110,
			},
		},
	},
	[198216] = {
		qualityID = 1,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[198217] = {
		qualityID = 2,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[198218] = {
		qualityID = 3,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 15,
			},
			{
				stat = "increasedifficulty",
				amount = 30,
			},
		},
	},
	[198219] = {
		qualityID = 1,
		stats = {
			{
				stat = "resourcefulness",
				amount = 55,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[198220] = {
		qualityID = 2,
		stats = {
			{
				stat = "resourcefulness",
				amount = 55,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[198221] = {
		qualityID = 3,
		stats = {
			{
				stat = "resourcefulness",
				amount = 55,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[213762] = {
		qualityID = 1,
		stats = {
			{
				stat = "reagentssavedfromresourcefulness",
				amount = 12,
			},
			{
				stat = "resourcefulness",
				amount = 150,
			},
		},
	},
	[213763] = {
		qualityID = 2,
		stats = {
			{
				stat = "reagentssavedfromresourcefulness",
				amount = 12,
			},
			{
				stat = "resourcefulness",
				amount = 150,
			},
		},
	},
	[213764] = {
		qualityID = 3,
		stats = {
			{
				stat = "reagentssavedfromresourcefulness",
				amount = 12,
			},
			{
				stat = "resourcefulness",
				amount = 150,
			},
		},
	},
	[213765] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuity",
				amount = 300,
			},
		},
	},
	[213766] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuity",
				amount = 300,
			},
		},
	},
	[213767] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuity",
				amount = 300,
			},
		},
	},
	[214043] = {
		qualityID = 0,
		stats = {
			{
				stat = "skill",
				amount = 50,
			},
			{
				stat = "modifyskillgain",
				amount = 25,
			},
		},
	},
	[222499] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuity",
				amount = 300,
			},
		},
	},
	[222500] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuity",
				amount = 300,
			},
		},
	},
	[222501] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuity",
				amount = 300,
			},
		},
	},
	[222511] = {
		qualityID = 1,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
		},
	},
	[222512] = {
		qualityID = 2,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
		},
	},
	[222513] = {
		qualityID = 3,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
		},
	},
	[222514] = {
		qualityID = 1,
		stats = {
			{
				stat = "resourcefulness",
				amount = 300,
			},
		},
	},
	[222515] = {
		qualityID = 2,
		stats = {
			{
				stat = "resourcefulness",
				amount = 300,
			},
		},
	},
	[222516] = {
		qualityID = 3,
		stats = {
			{
				stat = "resourcefulness",
				amount = 300,
			},
		},
	},
	[222876] = {
		qualityID = 1,
		stats = {
			{
				stat = "resourcefulness",
				amount = 300,
			},
		},
	},
	[222877] = {
		qualityID = 2,
		stats = {
			{
				stat = "resourcefulness",
				amount = 300,
			},
		},
	},
	[222878] = {
		qualityID = 3,
		stats = {
			{
				stat = "resourcefulness",
				amount = 300,
			},
		},
	},
	[222879] = {
		qualityID = 1,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
		},
	},
	[222880] = {
		qualityID = 2,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
		},
	},
	[222881] = {
		qualityID = 3,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
		},
	},
	[222882] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuity",
				amount = 300,
			},
		},
	},
	[222883] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuity",
				amount = 300,
			},
		},
	},
	[222884] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuity",
				amount = 300,
			},
		},
	},
	[222885] = {
		qualityID = 1,
		stats = {
			{
				stat = "reagentssavedfromresourcefulness",
				amount = 25,
			},
		},
	},
	[222886] = {
		qualityID = 2,
		stats = {
			{
				stat = "reagentssavedfromresourcefulness",
				amount = 25,
			},
		},
	},
	[222887] = {
		qualityID = 3,
		stats = {
			{
				stat = "reagentssavedfromresourcefulness",
				amount = 25,
			},
		},
	},
	[224173] = {
		qualityID = 1,
		stats = {
			{
				stat = "reduceconcentrationcost",
				amount = 10,
			},
		},
	},
	[224174] = {
		qualityID = 2,
		stats = {
			{
				stat = "reduceconcentrationcost",
				amount = 10,
			},
		},
	},
	[224175] = {
		qualityID = 3,
		stats = {
			{
				stat = "reduceconcentrationcost",
				amount = 10,
			},
		},
	},
	[224176] = {
		qualityID = 3,
		stats = {
			{
				stat = "multicraft",
				amount = 300,
			},
		},
	},
	[224177] = {
		qualityID = 2,
		stats = {
			{
				stat = "multicraft",
				amount = 300,
			},
		},
	},
	[224178] = {
		qualityID = 1,
		stats = {
			{
				stat = "multicraft",
				amount = 300,
			},
		},
	},
	[225670] = {
		qualityID = 0,
		stats = {
			{
				stat = "skill",
				amount = 5,
			},
		},
	},
	[225671] = {
		qualityID = 0,
		stats = {
			{
				stat = "skill",
				amount = 10,
			},
		},
	},
	[225672] = {
		qualityID = 0,
		stats = {
			{
				stat = "skill",
				amount = 20,
			},
		},
	},
	[225673] = {
		qualityID = 0,
		stats = {
			{
				stat = "skill",
				amount = 40,
			},
		},
	},
	[225912] = {
		qualityID = 0,
		stats = {
			{
				stat = "multicraft",
				amount = 1100,
			},
		},
	},
	[225984] = {
		qualityID = 1,
		stats = {
			{
				stat = "multicraft",
				amount = 300,
			},
		},
	},
	[225985] = {
		qualityID = 2,
		stats = {
			{
				stat = "multicraft",
				amount = 300,
			},
		},
	},
	[225986] = {
		qualityID = 3,
		stats = {
			{
				stat = "multicraft",
				amount = 300,
			},
		},
	},
	[225987] = {
		qualityID = 1,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 40,
			},
		},
	},
	[225988] = {
		qualityID = 2,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 40,
			},
		},
	},
	[225989] = {
		qualityID = 3,
		stats = {
			{
				stat = "modifyskillgain",
				amount = 40,
			},
		},
	},
	[228401] = {
		qualityID = 1,
		stats = {
			{
				stat = "resourcefulness",
				amount = 300,
			},
		},
	},
	[228402] = {
		qualityID = 2,
		stats = {
			{
				stat = "resourcefulness",
				amount = 300,
			},
		},
	},
	[228403] = {
		qualityID = 3,
		stats = {
			{
				stat = "resourcefulness",
				amount = 300,
			},
		},
	},
	[228404] = {
		qualityID = 1,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
		},
	},
	[228405] = {
		qualityID = 2,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
		},
	},
	[228406] = {
		qualityID = 3,
		stats = {
			{
				stat = "additionalitemscraftedwithmulticraft",
				amount = 25,
			},
		},
	},
	[221626] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221629] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221632] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221635] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221726] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221729] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221732] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221735] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222392] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222393] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222394] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222395] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222396] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222397] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222398] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222399] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222400] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222401] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222402] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[222403] = {
		qualityID = 1,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221627] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221630] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221633] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221636] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221727] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221730] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221733] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221736] = {
		qualityID = 2,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221628] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221631] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221634] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221637] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221728] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221731] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221734] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
	[221737] = {
		qualityID = 3,
		stats = {
			{
				stat = "ingenuityrefundincrease",
				amount = 12,
			},
			{
				stat = "ingenuity",
				amount = 50,
			},
		},
	},
}