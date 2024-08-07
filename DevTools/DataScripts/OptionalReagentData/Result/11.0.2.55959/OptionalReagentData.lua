---@class CraftSim
local CraftSim = select(2, ...)
CraftSim.OPTIONAL_REAGENT_DATA = {
	[180055] = {
		stats = {
			{
				stat = "reduceconcentrationcost",
				amount = 15,
			},
			{
				stat = "reduceconcentrationcost",
				amount = 29,
			},
		},
		qualityID = 0,
	},
	[180057] = {
		stats = {
			{
				stat = "reduceconcentrationcost",
				amount = 25,
			},
			{
				stat = "reduceconcentrationcost",
				amount = 65,
			},
		},
		qualityID = 0,
	},
	[180058] = {
		stats = {
			{
				stat = "reduceconcentrationcost",
				amount = 35,
			},
			{
				stat = "reduceconcentrationcost",
				amount = 94,
			},
		},
		qualityID = 0,
	},
	[180059] = {
		stats = {
			{
				stat = "reduceconcentrationcost",
				amount = 45,
			},
			{
				stat = "reduceconcentrationcost",
				amount = 127,
			},
		},
		qualityID = 0,
	},
	[180060] = {
		stats = {
			{
				stat = "reduceconcentrationcost",
				amount = 55,
			},
			{
				stat = "reduceconcentrationcost",
				amount = 163,
			},
		},
		qualityID = 0,
	},
	[190653] = {
		stats = {
			{
				stat = "inspiration",
				amount = 10,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 10,
			},
		},
		qualityID = 0,
	},
	[191511] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 25,
			},
		},
		qualityID = 1,
	},
	[191512] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 25,
			},
		},
		qualityID = 2,
	},
	[191513] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 25,
			},
		},
		qualityID = 3,
	},
	[191514] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
			{
				stat = "perception",
				amount = 20,
			},
		},
		qualityID = 1,
	},
	[191515] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
			{
				stat = "perception",
				amount = 20,
			},
		},
		qualityID = 2,
	},
	[191516] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
			{
				stat = "perception",
				amount = 20,
			},
		},
		qualityID = 3,
	},
	[191517] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 1,
	},
	[191518] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 2,
	},
	[191519] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 3,
	},
	[191520] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
			{
				stat = "craftingspeed",
				amount = 45,
			},
		},
		qualityID = 1,
	},
	[191521] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
			{
				stat = "craftingspeed",
				amount = 45,
			},
		},
		qualityID = 2,
	},
	[191522] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
			{
				stat = "craftingspeed",
				amount = 45,
			},
		},
		qualityID = 3,
	},
	[191523] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
			{
				stat = "craftingspeed",
				amount = 45,
			},
		},
		qualityID = 1,
	},
	[191524] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
			{
				stat = "craftingspeed",
				amount = 45,
			},
		},
		qualityID = 2,
	},
	[191525] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
			{
				stat = "craftingspeed",
				amount = 45,
			},
		},
		qualityID = 3,
	},
	[191526] = {
		stats = {},
		qualityID = 0,
	},
	[191529] = {
		stats = {},
		qualityID = 0,
	},
	[192894] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 1,
	},
	[192895] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 2,
	},
	[192896] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 3,
	},
	[192897] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[192898] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[192899] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[193950] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 1,
	},
	[193951] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 2,
	},
	[193952] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 3,
	},
	[193953] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[193954] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[193955] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[193956] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 1,
	},
	[193957] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 2,
	},
	[193958] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 3,
	},
	[193959] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "perception",
				amount = 20,
			},
		},
		qualityID = 1,
	},
	[193960] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "perception",
				amount = 20,
			},
		},
		qualityID = 2,
	},
	[193961] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "perception",
				amount = 20,
			},
		},
		qualityID = 3,
	},
	[193962] = {
		stats = {
			{
				stat = "bonuscraftingskillfrominspiration(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 1,
	},
	[193963] = {
		stats = {
			{
				stat = "bonuscraftingskillfrominspiration(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 2,
	},
	[193964] = {
		stats = {
			{
				stat = "bonuscraftingskillfrominspiration(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 3,
	},
	[194902] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
			{
				stat = "craftingspeed",
				amount = 1100,
			},
		},
		qualityID = 0,
	},
	[197764] = {
		stats = {
			{
				stat = "craftingspeed",
				amount = 90,
			},
		},
		qualityID = 0,
	},
	[197765] = {
		stats = {
			{
				stat = "inspiration",
				amount = 110,
			},
		},
		qualityID = 0,
	},
	[198216] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 1,
	},
	[198217] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 2,
	},
	[198218] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 15,
			},
			{
				stat = "decreasedifficulty",
				amount = 30,
			},
		},
		qualityID = 3,
	},
	[198219] = {
		stats = {
			{
				stat = "inspiration",
				amount = 55,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[198220] = {
		stats = {
			{
				stat = "inspiration",
				amount = 55,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[198221] = {
		stats = {
			{
				stat = "inspiration",
				amount = 55,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[213762] = {
		stats = {
			{
				stat = "bonuscraftingskillfrominspiration(dnt-writemanually!)",
				amount = 12,
			},
			{
				stat = "inspiration",
				amount = 150,
			},
		},
		qualityID = 1,
	},
	[213763] = {
		stats = {
			{
				stat = "bonuscraftingskillfrominspiration(dnt-writemanually!)",
				amount = 12,
			},
			{
				stat = "inspiration",
				amount = 150,
			},
		},
		qualityID = 2,
	},
	[213764] = {
		stats = {
			{
				stat = "bonuscraftingskillfrominspiration(dnt-writemanually!)",
				amount = 12,
			},
			{
				stat = "inspiration",
				amount = 150,
			},
		},
		qualityID = 3,
	},
	[213765] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 300,
			},
		},
		qualityID = 1,
	},
	[213766] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 300,
			},
		},
		qualityID = 2,
	},
	[213767] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 300,
			},
		},
		qualityID = 3,
	},
	[214043] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 25,
			},
		},
		qualityID = 0,
	},
	[222499] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 300,
			},
		},
		qualityID = 1,
	},
	[222500] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 300,
			},
		},
		qualityID = 2,
	},
	[222501] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 300,
			},
		},
		qualityID = 3,
	},
	[222511] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 1,
	},
	[222512] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 2,
	},
	[222513] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 3,
	},
	[222514] = {
		stats = {
			{
				stat = "inspiration",
				amount = 300,
			},
		},
		qualityID = 1,
	},
	[222515] = {
		stats = {
			{
				stat = "inspiration",
				amount = 300,
			},
		},
		qualityID = 2,
	},
	[222516] = {
		stats = {
			{
				stat = "inspiration",
				amount = 300,
			},
		},
		qualityID = 3,
	},
	[222876] = {
		stats = {
			{
				stat = "inspiration",
				amount = 300,
			},
		},
		qualityID = 1,
	},
	[222877] = {
		stats = {
			{
				stat = "inspiration",
				amount = 300,
			},
		},
		qualityID = 2,
	},
	[222878] = {
		stats = {
			{
				stat = "inspiration",
				amount = 300,
			},
		},
		qualityID = 3,
	},
	[222879] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 1,
	},
	[222880] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 2,
	},
	[222881] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 3,
	},
	[222882] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 300,
			},
		},
		qualityID = 1,
	},
	[222883] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 300,
			},
		},
		qualityID = 2,
	},
	[222884] = {
		stats = {
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 300,
			},
		},
		qualityID = 3,
	},
	[222885] = {
		stats = {
			{
				stat = "bonuscraftingskillfrominspiration(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 1,
	},
	[222886] = {
		stats = {
			{
				stat = "bonuscraftingskillfrominspiration(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 2,
	},
	[222887] = {
		stats = {
			{
				stat = "bonuscraftingskillfrominspiration(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 3,
	},
	[224173] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 10,
			},
		},
		qualityID = 1,
	},
	[224174] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 10,
			},
		},
		qualityID = 2,
	},
	[224175] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 10,
			},
		},
		qualityID = 3,
	},
	[224176] = {
		stats = {
			{
				stat = "craftingspeed",
				amount = 300,
			},
		},
		qualityID = 3,
	},
	[224177] = {
		stats = {
			{
				stat = "craftingspeed",
				amount = 300,
			},
		},
		qualityID = 2,
	},
	[224178] = {
		stats = {
			{
				stat = "craftingspeed",
				amount = 300,
			},
		},
		qualityID = 1,
	},
	[225670] = {
		stats = {},
		qualityID = 0,
	},
	[225671] = {
		stats = {},
		qualityID = 0,
	},
	[225672] = {
		stats = {},
		qualityID = 0,
	},
	[225673] = {
		stats = {},
		qualityID = 0,
	},
	[225912] = {
		stats = {
			{
				stat = "craftingspeed",
				amount = 1100,
			},
		},
		qualityID = 0,
	},
	[225984] = {
		stats = {
			{
				stat = "craftingspeed",
				amount = 300,
			},
		},
		qualityID = 1,
	},
	[225985] = {
		stats = {
			{
				stat = "craftingspeed",
				amount = 300,
			},
		},
		qualityID = 2,
	},
	[225986] = {
		stats = {
			{
				stat = "craftingspeed",
				amount = 300,
			},
		},
		qualityID = 3,
	},
	[225987] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 40,
			},
		},
		qualityID = 1,
	},
	[225988] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 40,
			},
		},
		qualityID = 2,
	},
	[225989] = {
		stats = {
			{
				stat = "increasedifficulty",
				amount = 40,
			},
		},
		qualityID = 3,
	},
	[228368] = {
		stats = {
			{
				stat = "reduceconcentrationcost",
				amount = 65,
			},
			{
				stat = "reduceconcentrationcost",
				amount = 350,
			},
		},
		qualityID = 0,
	},
	[228401] = {
		stats = {
			{
				stat = "inspiration",
				amount = 300,
			},
		},
		qualityID = 1,
	},
	[228402] = {
		stats = {
			{
				stat = "inspiration",
				amount = 300,
			},
		},
		qualityID = 2,
	},
	[228403] = {
		stats = {
			{
				stat = "inspiration",
				amount = 300,
			},
		},
		qualityID = 3,
	},
	[228404] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 1,
	},
	[228405] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 2,
	},
	[228406] = {
		stats = {
			{
				stat = "gatherrangerating(dnt-writemanually!)",
				amount = 25,
			},
		},
		qualityID = 3,
	},
	[221626] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[221629] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[221632] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[221635] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[221726] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[221729] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[221732] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[221735] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222392] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222393] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222394] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222395] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222396] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222397] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222398] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222399] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222400] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222401] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222402] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[222403] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 1,
	},
	[221627] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[221630] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[221633] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[221636] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[221727] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[221730] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[221733] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[221736] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 2,
	},
	[221628] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[221631] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[221634] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[221637] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[221728] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[221731] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[221734] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
	[221737] = {
		stats = {
			{
				stat = "ingenuity",
				amount = 12,
			},
			{
				stat = "traitranksbypoints-modifierlabel",
				amount = 50,
			},
		},
		qualityID = 3,
	},
}