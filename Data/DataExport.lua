CraftSimAddonName, CraftSim = ...

CraftSim.DATAEXPORT = {}

LibCompress = LibStub:GetLibrary("LibCompress")

local print = CraftSim.UTIL:SetDebugPrint(CraftSim.CONST.DEBUG_IDS.DATAEXPORT)


function CraftSim.DATAEXPORT:GetDifferentQualitiesByCraftingReagentTbl(recipeID, craftingReagentInfoTbl, allocationItemGUID, maxQuality)
	local linksByQuality = {}
	local max = 8
	if maxQuality then
		max = 3 + maxQuality
	end
	for i = 4, max, 1 do
		local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, craftingReagentInfoTbl, allocationItemGUID, i)
		table.insert(linksByQuality, outputItemData.hyperlink)
	end
	 return linksByQuality
end

function CraftSim.DATAEXPORT:GetDifferentQualityIDsByCraftingReagentTbl(recipeID, craftingReagentInfoTbl, allocationItemGUID)
	local qualityIDs = {}
	for i = 1, 3, 1 do
		local outputItemData = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, craftingReagentInfoTbl, allocationItemGUID, i)
		table.insert(qualityIDs, outputItemData.itemID)
	end
	 return qualityIDs
end

-- TODO: turn into OOP
function CraftSim.DATAEXPORT:exportBuffData()
	local buffData = {
		inspirationIncense = false,
		quickPhial = false,
		alchemicallyInspired = false,
	}
	
	-- check for buffs
	local inspirationIncense = C_UnitAuras.GetPlayerAuraBySpellID(CraftSim.CONST.BUFF_IDS.INSPIRATION_INCENSE)
	local quickPhial = C_UnitAuras.GetPlayerAuraBySpellID(CraftSim.CONST.BUFF_IDS.PHIAL_OF_QUICK_HANDS)
	local alchemicallyInspired = C_UnitAuras.GetPlayerAuraBySpellID(CraftSim.CONST.BUFF_IDS.ALCHEMICALLY_INSPIRED)

	buffData.inspirationIncense = inspirationIncense and 20 -- gives 20 inspiration
	buffData.quickPhial = quickPhial and quickPhial.points[1] -- points gives us the % as integer	
	buffData.alchemicallyInspired = alchemicallyInspired and 20 -- gives 20 inspiration

	return buffData
end

function CraftSim.DATAEXPORT:GetProfessionInfoFromCache(recipeID)
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo()

	if not professionInfo or not professionInfo.profession then
		-- try to get from cache
		local professionID = CraftSim.RECIPE_SCAN:GetProfessionIDByRecipeID(recipeID)

		if professionID then
			professionInfo = CraftSim.CACHE:GetCacheEntryByVersion(CraftSimProfessionInfoCache, professionID)

			if not professionInfo then
				return
			end
		end
	else
		if professionInfo.profession then
			professionInfo.professionID = professionInfo.profession
			professionInfo.skillLineID = C_TradeSkillUI.GetProfessionChildSkillLineID()
			CraftSim.CACHE:AddCacheEntryByVersion(CraftSimProfessionInfoCache, professionInfo.professionID, professionInfo)
		else
			print("ProfessionData without professionID")
			return nil
		end
	end

	return professionInfo
end
