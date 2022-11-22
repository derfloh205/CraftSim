CraftSimGEARSIM = {}

function CraftSimGEARSIM:EquipBestProfessionGearCombination()
    print("start equip sim..")
    local recipeData = CraftSimDATAEXPORT:exportRecipeData()
    -- unequip all professiontools and just get from inventory for easier equipping?
    -- local equippedGear = CraftSimDATAEXPORT:GetEquippedProfessionGear()
    -- APPROACH: consider inventory only for now
    local inventoryGear =  CraftSimDATAEXPORT:GetProfessionGearFromInventory()

    -- TODO: get p gear from slots - check
    -- TODO: get p gear from inventory - check
    -- TODO: check for each item in which slot it fits
    -- TODO: extract from each item the stat changes it brings - check
    -- TODO: create a list of all combination of gear items and their stat changes
    -- TODO: simulate the mean profit for each combination
    -- TODO: extract the best simulation
    -- TODO: equip the p gear combi of the best simulation

    -- get p gear from slots

end
