---@class CraftSim
local CraftSim = select(2, ...)

---@type table<string, CraftSim.SPECIALIZATION_DATA.RULE_DATA>
CraftSim.SPECIALIZATION_DATA.THE_WAR_WITHIN.ALCHEMY_DATA = {
    ALCHEMICAL_MASTERY_1 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 0,
		equalsSkill = 1,
		skill = 3,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_2 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 5,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_3 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 10,
		resourcefulness = 5,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_4 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 15,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_5 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 20,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_6 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 25,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_7 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 30,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_8 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 35,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_9 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 40,
		multicraft = 5,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_11 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 50,
		skill = 10,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
	ALCHEMICAL_MASTERY_10 = {
        childNodeIDs = { "MYCOBLOOM_LORE_1", "LUREDROP_LORE_1", "ORBINID_LORE_1", "ARATHORS_SPEAR_LORE_1", "BLESSING_BLOSSOM_LORE_1" },
        nodeID = 99020,
		threshold = 45,
		resourcefulness = 5,
        idMapping = { [CraftSim.CONST.RECIPE_CATEGORIES.ALL] = {} },
    },
    MYCOBLOOM_LORE_1 = {
        nodeID = 99019,
		threshold = 0,
		equalsSkill = 1,
        affectedReagentIDs = {
            210796, -- Mycobloom q1, q2, q3
            210797,
            210798
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	MYCOBLOOM_LORE_2 = {
        nodeID = 99019,
		threshold = 5,
		resourcefulness = 5,
        affectedReagentIDs = {
            210796, -- Mycobloom q1, q2, q3
            210797,
            210798
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	MYCOBLOOM_LORE_3 = {
        nodeID = 99019,
		threshold = 10,
		ingenuity = 3,
        affectedReagentIDs = {
            210796, -- Mycobloom q1, q2, q3
            210797,
            210798
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	MYCOBLOOM_LORE_4 = {
        nodeID = 99019,
		threshold = 15,
		skill = 3,
        affectedReagentIDs = {
            210796, -- Mycobloom q1, q2, q3
            210797,
            210798
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	MYCOBLOOM_LORE_5 = {
        nodeID = 99019,
		threshold = 20,
        affectedReagentIDs = {
            210796, -- Mycobloom q1, q2, q3
            210797,
            210798
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	MYCOBLOOM_LORE_6 = {
        nodeID = 99019,
		threshold = 25,
		skill = 5,
        affectedReagentIDs = {
            210796, -- Mycobloom q1, q2, q3
            210797,
            210798
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	MYCOBLOOM_LORE_7 = {
        nodeID = 99019,
		threshold = 30,
		ingenuity = 7,
        affectedReagentIDs = {
            210796, -- Mycobloom q1, q2, q3
            210797,
            210798
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	MYCOBLOOM_LORE_8 = {
        nodeID = 99019,
		threshold = 35,
		multicraft = 5,
        affectedReagentIDs = {
            210796, -- Mycobloom q1, q2, q3
            210797,
            210798
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	MYCOBLOOM_LORE_9 = {
        nodeID = 99019,
		threshold = 40,
        affectedReagentIDs = {
            210796, -- Mycobloom q1, q2, q3
            210797,
            210798
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    LUREDROP_LORE_1 = {
        nodeID = 99018,
		threshold = 0,
		equalsSkill = 1,
        affectedReagentIDs = {
            210799, -- Luredrop q1, q2, q3
            210800,
            210801
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	LUREDROP_LORE_2 = {
        nodeID = 99018,
		threshold = 5,
		resourcefulness = 5,
        affectedReagentIDs = {
            210799, -- Luredrop q1, q2, q3
            210800,
            210801
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	LUREDROP_LORE_3 = {
        nodeID = 99018,
		threshold = 10,
		ingenuity = 3,
        affectedReagentIDs = {
            210799, -- Luredrop q1, q2, q3
            210800,
            210801
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	LUREDROP_LORE_4 = {
        nodeID = 99018,
		threshold = 15,
		skill = 3,
        affectedReagentIDs = {
            210799, -- Luredrop q1, q2, q3
            210800,
            210801
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	LUREDROP_LORE_5 = {
        nodeID = 99018,
		threshold = 20,
		concentrationLessUsageFactor = 5,
        affectedReagentIDs = {
            210799, -- Luredrop q1, q2, q3
            210800,
            210801
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	LUREDROP_LORE_6 = {
        nodeID = 99018,
		threshold = 25,
		skill = 5,
        affectedReagentIDs = {
            210799, -- Luredrop q1, q2, q3
            210800,
            210801
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	LUREDROP_LORE_7 = {
        nodeID = 99018,
		threshold = 30,
		ingenuity = 7,
        affectedReagentIDs = {
            210799, -- Luredrop q1, q2, q3
            210800,
            210801
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	LUREDROP_LORE_8 = {
        nodeID = 99018,
		threshold = 35,
		multicraft = 5,
        affectedReagentIDs = {
            210799, -- Luredrop q1, q2, q3
            210800,
            210801
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	LUREDROP_LORE_9 = {
        nodeID = 99018,
		threshold = 40,
        affectedReagentIDs = {
            210799, -- Luredrop q1, q2, q3
            210800,
            210801
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    ORBINID_LORE_1 = {
        nodeID = 99017,
		threshold = 0,
		equalsSkill = 1,
        affectedReagentIDs = {
            210802, -- Orbinid q1, q2, q3
            210803,
            210804
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ORBINID_LORE_2 = {
        nodeID = 99017,
		threshold = 5,
		resourcefulness = 5,
        affectedReagentIDs = {
            210802, -- Orbinid q1, q2, q3
            210803,
            210804
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ORBINID_LORE_3 = {
        nodeID = 99017,
		threshold = 10,
		ingenuity = 3,
        affectedReagentIDs = {
            210802, -- Orbinid q1, q2, q3
            210803,
            210804
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ORBINID_LORE_4 = {
        nodeID = 99017,
		threshold = 15,
		skill = 3,
        affectedReagentIDs = {
            210802, -- Orbinid q1, q2, q3
            210803,
            210804
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ORBINID_LORE_5 = {
        nodeID = 99017,
		threshold = 20,
		concentrationLessUsageFactor = 5,
        affectedReagentIDs = {
            210802, -- Orbinid q1, q2, q3
            210803,
            210804
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ORBINID_LORE_6 = {
        nodeID = 99017,
		threshold = 25,
		skill = 5,
        affectedReagentIDs = {
            210802, -- Orbinid q1, q2, q3
            210803,
            210804
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ORBINID_LORE_7 = {
        nodeID = 99017,
		threshold = 30,
		ingenuity = 7,
        affectedReagentIDs = {
            210802, -- Orbinid q1, q2, q3
            210803,
            210804
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ORBINID_LORE_8 = {
        nodeID = 99017,
		threshold = 35,
		multicraft = 5,
        affectedReagentIDs = {
            210802, -- Orbinid q1, q2, q3
            210803,
            210804
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ORBINID_LORE_9 = {
        nodeID = 99017,
		threshold = 40,
        affectedReagentIDs = {
            210802, -- Orbinid q1, q2, q3
            210803,
            210804
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    ARATHORS_SPEAR_LORE_1 = {
        nodeID =  99016,
		threshold = 0,
		equalsSkill = 1,
        affectedReagentIDs = {
            210808, -- Arathor's Spear q1, q2, q3
            210809,
            210810
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ARATHORS_SPEAR_LORE_2 = {
        nodeID = 99016,
		threshold = 5,
		resourcefulness = 5,
        affectedReagentIDs = {
            210808, -- Arathor's Spear q1, q2, q3
            210809,
            210810
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ARATHORS_SPEAR_LORE_3 = {
        nodeID = 99016,
		threshold = 10,
		ingenuity = 3,
        affectedReagentIDs = {
            210808, -- Arathor's Spear q1, q2, q3
            210809,
            210810
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ARATHORS_SPEAR_LORE_4 = {
        nodeID = 99016,
		threshold = 15,
		skill = 3,
        affectedReagentIDs = {
            210808, -- Arathor's Spear q1, q2, q3
            210809,
            210810
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ARATHORS_SPEAR_LORE_5 = {
        nodeID = 99016,
		threshold = 20,
		concentrationLessUsageFactor = 5,
        affectedReagentIDs = {
            210808, -- Arathor's Spear q1, q2, q3
            210809,
            210810
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ARATHORS_SPEAR_LORE_6 = {
        nodeID = 99016,
		threshold = 25,
		skill = 5,
        affectedReagentIDs = {
            210808, -- Arathor's Spear q1, q2, q3
            210809,
            210810
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ARATHORS_SPEAR_LORE_7 = {
        nodeID = 99016,
		threshold = 30,
		ingenuity = 7,
        affectedReagentIDs = {
            210808, -- Arathor's Spear q1, q2, q3
            210809,
            210810
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ARATHORS_SPEAR_LORE_8 = {
        nodeID = 99016,
		threshold = 35,
		multicraft = 5,
        affectedReagentIDs = {
            210808, -- Arathor's Spear q1, q2, q3
            210809,
            210810
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	ARATHORS_SPEAR_LORE_9 = {
        nodeID = 99016,
		threshold = 40,
        affectedReagentIDs = {
            210808, -- Arathor's Spear q1, q2, q3
            210809,
            210810
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	BLESSING_BLOSSOM_LORE_1 = {
        nodeID =  99015,
		threshold = 0,
		equalsSkill = 1,
        affectedReagentIDs = {
            210805, -- Blessing Blossom q1, q2, q3
            210806,
            210807
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	BLESSING_BLOSSOM_LORE_2 = {
        nodeID = 99015,
		threshold = 5,
		resourcefulness = 5,
        affectedReagentIDs = {
            210805, -- Blessing Blossom q1, q2, q3
            210806,
            210807
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	BLESSING_BLOSSOM_LORE_3 = {
        nodeID = 99015,
		threshold = 10,
		ingenuity = 3,
        affectedReagentIDs = {
            210805, -- Blessing Blossom q1, q2, q3
            210806,
            210807
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	BLESSING_BLOSSOM_LORE_4 = {
        nodeID = 99015,
		threshold = 15,
		skill = 3,
        affectedReagentIDs = {
            210805, -- Blessing Blossom q1, q2, q3
            210806,
            210807
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	BLESSING_BLOSSOM_LORE_5 = {
        nodeID = 99015,
		threshold = 20,
		concentrationLessUsageFactor = 5,
        affectedReagentIDs = {
            210805, -- Blessing Blossom q1, q2, q3
            210806,
            210807
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	BLESSING_BLOSSOM_LORE_6 = {
        nodeID = 99015,
		threshold = 25,
		skill = 5,
        affectedReagentIDs = {
            210805, -- Blessing Blossom q1, q2, q3
            210806,
            210807
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	BLESSING_BLOSSOM_LORE_7 = {
        nodeID = 99015,
		threshold = 30,
		ingenuity = 7,
        affectedReagentIDs = {
            210805, -- Blessing Blossom q1, q2, q3
            210806,
            210807
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	BLESSING_BLOSSOM_LORE_8 = {
        nodeID = 99015,
		threshold = 35,
		multicraft = 5,
        affectedReagentIDs = {
            210805, -- Blessing Blossom q1, q2, q3
            210806,
            210807
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
	BLESSING_BLOSSOM_LORE_9 = {
        nodeID = 99015,
		threshold = 40,
        affectedReagentIDs = {
            210805, -- Blessing Blossom q1, q2, q3
            210806,
            210807
        },
		idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    FANTASTIC_FLASKS_1 = {
        childNodeIDs = { "BULK_PRODUCTION_FLASKS_1", "PROFESSION_PHIALS_1" },
        nodeID = 98953,
        threshold = 0,
        equalsSkill = 2,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    FANTASTIC_FLASKS_2 = {
        childNodeIDs = { "BULK_PRODUCTION_FLASKS_1", "PROFESSION_PHIALS_1" },
        nodeID = 98953,
        threshold = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    FANTASTIC_FLASKS_3 = {
        childNodeIDs = { "BULK_PRODUCTION_FLASKS_1", "PROFESSION_PHIALS_1" },
        nodeID = 98953,
        threshold = 10,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    FANTASTIC_FLASKS_4 = {
        childNodeIDs = { "BULK_PRODUCTION_FLASKS_1", "PROFESSION_PHIALS_1" },
        nodeID = 98953,
        threshold = 15,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    FANTASTIC_FLASKS_5 = {
        childNodeIDs = { "BULK_PRODUCTION_FLASKS_1", "PROFESSION_PHIALS_1" },
        nodeID = 98953,
        threshold = 20,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    FANTASTIC_FLASKS_6 = {
        childNodeIDs = { "BULK_PRODUCTION_FLASKS_1", "PROFESSION_PHIALS_1" },
        nodeID = 98953,
        threshold = 25,
        concentrationLessUsageFactor = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    FANTASTIC_FLASKS_7 = {
        childNodeIDs = { "BULK_PRODUCTION_FLASKS_1", "PROFESSION_PHIALS_1" },
        nodeID = 98953,
        threshold = 30,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    BULK_PRODUCTION_FLASKS_1 = {
        nodeID = 98952,
        threshold = 0,
        equalsMulticraft = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_FLASKS_2 = {
        nodeID = 98952,
        threshold = 5,
        resourcefulnessExtraItemsFactor = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_FLASKS_3 = {
        nodeID = 98952,
        threshold = 10,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_FLASKS_4 = {
        nodeID = 98952,
        threshold = 15,
        resourcefulnessExtraItemsFactor = 5,
        idMapping = {
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_FLASKS_5 = {
        nodeID = 98952,
        threshold = 20,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_FLASKS_6 = {
        nodeID = 98952,
        threshold = 25,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.VICIOUS_FLASKS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    PROFESSION_PHIALS_1 = {
        nodeID = 98951,
        threshold = 0,
        equalsSkill = 2,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    PROFESSION_PHIALS_2 = {
        nodeID = 98951,
        threshold = 5,
        multicraft = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    PROFESSION_PHIALS_3 = {
        nodeID = 98951,
        threshold = 10,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    PROFESSION_PHIALS_4 = {
        nodeID = 98951,
        threshold = 15,
        skill = 15,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    PROFESSION_PHIALS_5 = {
        nodeID = 98951,
        threshold = 20,
        multicraft = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    PROFESSION_PHIALS_6 = {
        nodeID = 98951,
        threshold = 25,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.PHIALS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.PHIALS
            },
        },
    },
    POTENT_POTIONS_1 = {
        childNodeIDs = { "BULK_PRODUCTION_POTIONS_1" },
        nodeID = 99041,
        threshold = 0,
        equalsSkill = 2,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    POTENT_POTIONS_2 = {
        childNodeIDs = { "BULK_PRODUCTION_POTIONS_1" },
        nodeID = 99041,
        threshold = 5,
        resourcefulness = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    POTENT_POTIONS_3 = {
        childNodeIDs = { "BULK_PRODUCTION_POTIONS_1" },
        nodeID = 99041,
        threshold = 10,
        resourcefulness = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    POTENT_POTIONS_4 = {
        childNodeIDs = { "BULK_PRODUCTION_POTIONS_1" },
        nodeID = 99041,
        threshold = 15,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    POTENT_POTIONS_5 = {
        childNodeIDs = { "BULK_PRODUCTION_POTIONS_1" },
        nodeID = 99041,
        threshold = 20,
        resourcefulness = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    POTENT_POTIONS_6 = {
        childNodeIDs = { "BULK_PRODUCTION_POTIONS_1" },
        nodeID = 99041,
        threshold = 25,
        concentrationLessUsageFactor = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    POTENT_POTIONS_7 = {
        childNodeIDs = { "BULK_PRODUCTION_POTIONS_1" },
        nodeID = 99041,
        threshold = 30,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_POTIONS_1 = {
        nodeID = 99040,
        threshold = 0,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_POTIONS_2 = {
        nodeID = 99040,
        threshold = 5,
        resourcefulness = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_POTIONS_3 = {
        nodeID = 99040,
        threshold = 10,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_POTIONS_4 = {
        nodeID = 99040,
        threshold = 15,
        resourcefulnessExtraItemsFactor = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_POTIONS_5 = {
        nodeID = 99040,
        threshold = 20,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    BULK_PRODUCTION_POTIONS_6 = {
        nodeID = 99040,
        threshold = 25,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.POTIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.POTIONS
            },
        },
    },
    THAUMATURGY_1 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 0,
        equalsSkill = 1,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_2 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_3 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 10,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_4 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 15,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_5 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 20,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_6 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 25,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_7 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 30,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_8 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 35,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_9 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 40,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_10 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 45,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_11 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 50,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    THAUMATURGY_12 = {
        childNodeIDs = { "MERCURIAL_MATERIALS_1", "VOLATILE_MATERIALS_1", "OMINOUS_MATERIALS_1", "GLEAMING_TRANSMUTAGEN_1", "TRANSMUTATION_1" },
        nodeID = 99059,
        threshold = 55,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    MERCURIAL_MATERIALS_1 = {
        nodeID = 100208,
        threshold = 0,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430618, --Mercurial Blessings
            449573, --Mercurial Coalescence
            449571, --Mercurial Herbs
            430619, --Mercurial Storms 
        },
    },
    MERCURIAL_MATERIALS_2 = {
        nodeID = 100208,
        threshold = 5,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430618, --Mercurial Blessings
            449573, --Mercurial Coalescence
            449571, --Mercurial Herbs
            430619, --Mercurial Storms 
        },
    },
    MERCURIAL_MATERIALS_3 = {
        nodeID = 100208,
        threshold = 10,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430618, --Mercurial Blessings
            449573, --Mercurial Coalescence
            449571, --Mercurial Herbs
            430619, --Mercurial Storms 
        },
    },
    MERCURIAL_MATERIALS_4 = {
        nodeID = 100208,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430618, --Mercurial Blessings
            449573, --Mercurial Coalescence
            449571, --Mercurial Herbs
            430619, --Mercurial Storms 
        },
    },
    MERCURIAL_MATERIALS_5 = {
        nodeID = 100208,
        threshold = 20,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430618, --Mercurial Blessings
            449573, --Mercurial Coalescence
            449571, --Mercurial Herbs
            430619, --Mercurial Storms 
        },
    },
    MERCURIAL_MATERIALS_6 = {
        nodeID = 100208,
        threshold = 25,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430618, --Mercurial Blessings
            449573, --Mercurial Coalescence
            449571, --Mercurial Herbs
            430619, --Mercurial Storms 
        },
    },
    VOLATILE_MATERIALS_1 = {
        nodeID = 100208,
        threshold = 0,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            449575, --Volatile Coalescence
            430621, --Volatile Stone
            430620, --Volatile Weaving 
        },
    },
    VOLATILE_MATERIALS_2 = {
        nodeID = 100208,
        threshold = 5,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            449575, --Volatile Coalescence
            430621, --Volatile Stone
            430620, --Volatile Weaving
        },
    },
    VOLATILE_MATERIALS_3 = {
        nodeID = 100208,
        threshold = 10,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            449575, --Volatile Coalescence
            430621, --Volatile Stone
            430620, --Volatile Weaving
        },
    },
    VOLATILE_MATERIALS_4 = {
        nodeID = 100208,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            449575, --Volatile Coalescence
            430621, --Volatile Stone
            430620, --Volatile Weaving
        },
    },
    VOLATILE_MATERIALS_5 = {
        nodeID = 100208,
        threshold = 20,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            449575, --Volatile Coalescence
            430621, --Volatile Stone
            430620, --Volatile Weaving
        },
    },
    VOLATILE_MATERIALS_6 = {
        nodeID = 100208,
        threshold = 25,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            449575, --Volatile Coalescence
            430621, --Volatile Stone
            430620, --Volatile Weaving
        },
    },
    OMINOUS_MATERIALS_1 = {
        nodeID = 100208,
        threshold = 0,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430622, --Ominous Call
            449574, --Ominous Coalescence
            430623, --Ominous Gloom 
            449572, --Ominous Herbs
        },
    },
    OMINOUS_MATERIALS_2 = {
        nodeID = 100208,
        threshold = 5,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430622, --Ominous Call
            449574, --Ominous Coalescence
            430623, --Ominous Gloom 
            449572, --Ominous Herbs
        },
    },
    OMINOUS_MATERIALS_3 = {
        nodeID = 100208,
        threshold = 10,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430622, --Ominous Call
            449574, --Ominous Coalescence
            430623, --Ominous Gloom 
            449572, --Ominous Herbs
        },
    },
    OMINOUS_MATERIALS_4 = {
        nodeID = 100208,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430622, --Ominous Call
            449574, --Ominous Coalescence
            430623, --Ominous Gloom 
            449572, --Ominous Herbs
        },
    },
    OMINOUS_MATERIALS_5 = {
        nodeID = 100208,
        threshold = 20,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430622, --Ominous Call
            449574, --Ominous Coalescence
            430623, --Ominous Gloom 
            449572, --Ominous Herbs
        },
    },
    OMINOUS_MATERIALS_6 = {
        nodeID = 100208,
        threshold = 25,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
            430622, --Ominous Call
            449574, --Ominous Coalescence
            430623, --Ominous Gloom 
            449572, --Ominous Herbs
        },
    },
    GLEAMING_TRANSMUTAGEN_1 = {
        nodeID = 100205,
        threshold = 0,
        equalsSkill = 1,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    GLEAMING_TRANSMUTAGEN_2 = {
        nodeID = 100205,
        threshold = 5,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    GLEAMING_TRANSMUTAGEN_3 = {
        nodeID = 100205,
        threshold = 10,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    GLEAMING_TRANSMUTAGEN_4 = {
        nodeID = 100205,
        threshold = 15,
        skill = 5,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    GLEAMING_TRANSMUTAGEN_5 = {
        nodeID = 100205,
        equalsSkill = 20,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    GLEAMING_TRANSMUTAGEN_6 = {
        nodeID = 100205,
        threshold = 25,
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    TRANSMUTATION_1 = {
        nodeID = 99058,
        threshold = 0,
        equalsSkill = 1,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    TRANSMUTATION_2 = {
        nodeID = 99058,
        threshold = 5,
        skill = 3,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    TRANSMUTATION_3 = {
        nodeID = 99058,
        threshold = 10,
        resourcefulness = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    TRANSMUTATION_4 = {
        nodeID = 99058,
        threshold = 15,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    TRANSMUTATION_5 = {
        nodeID = 99058,
        threshold = 20,
        skill = 8,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    TRANSMUTATION_6 = {
        nodeID = 99058,
        threshold = 25,
        resourcefulness = 5,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
    TRANSMUTATION_7 = {
        nodeID = 99058,
        threshold = 30,
        idMapping = { 
            [CraftSim.CONST.RECIPE_CATEGORIES.ALCHEMY.THEWARWITHIN.TRANSMUTATIONS] = {
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.ALCHEMY,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.OTHER_TRANSMUTATIONS,
                CraftSim.CONST.RECIPE_ITEM_SUBTYPES.ALCHEMY.JEWELCRAFTING,
            }
        },
        exceptionRecipeIDs = {
            430315, --Thaumaturgy
        },
    },
}

