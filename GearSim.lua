CraftSimGEARSIM = {}

function CraftSimGEARSIM:EquipBestProfessionGearCombination()
    print("start equip sim..")
    local recipeData = CraftSimDATAEXPORT:exportRecipeData()
    -- unequip all professiontools and just get from inventory for easier equipping?
    -- local equippedGear = CraftSimDATAEXPORT:GetEquippedProfessionGear()
    -- APPROACH: consider inventory only for now
    local inventoryGear =  CraftSimDATAEXPORT:GetProfessionGearFromInventory()


    -- remove duplicated items (with same stats, this means the link should be the same..)

    local setInventoryGear = {}
    for _, gear in pairs(inventoryGear) do
        if setInventoryGear[gear.itemLink] == nil then
            setInventoryGear[gear.itemLink] = gear
        end
    end
    inventoryGear = setInventoryGear

    local gearSlotItems = {}
    local toolSlotItems = {}

    for _, gear in pairs(inventoryGear) do
        if gear.equipSlot == CraftSimCONST.PROFESSIONTOOL_INV_TYPES.GEAR then
            table.insert(gearSlotItems, gear)
        elseif gear.equipSlot == CraftSimCONST.PROFESSIONTOOL_INV_TYPES.TOOL then
            table.insert(toolSlotItems, gear)
        end
    end

    -- TODO: get p gear from slots - check
    -- TODO: get p gear from inventory - check
    -- TODO: check for each item in which slot it fits -- check
    -- TODO: remove dups - check
    -- TODO: extract from each item the stat changes it brings - check
    -- TODO: create a list of all combination of gear items and their stat changes
    -- TODO: simulate the mean profit for each combination
    -- TODO: extract the best simulation
    -- TODO: equip the p gear combi of the best simulation

    -- get p gear from slots
end
