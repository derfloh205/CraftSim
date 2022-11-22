CraftSimGEARSIM = {}

function CraftSimGEARSIM:GetUniqueCombosFromAllPermutations(totalCombos)
    local uniqueCombos = {}
    local combinationList = {}

    local function checkIfCombinationExists(combinationToTest)
        for _, combination in pairs(combinationList) do
            local exists1 = false
            local exists2 = false
            local exists3 = false
            for _, itemLink in pairs(combination) do 
                if combinationToTest[1] == itemLink then
                    exists1 = true
                elseif combinationToTest[2] == itemLink then
                    exists2 = true
                elseif combinationToTest[3] == itemLink then
                    exists3 = true
                end
            end
            if exists1 and exists2 and exists3 then
                print("found existing combo..")
                return true
            end
        end
        print("combo not existing..")
        return false
    end

    for _, combo in pairs(totalCombos) do
        -- check if combinationList of itemLinks already exists in combinationList
        -- write the itemLink of an empty slot as "empty"
        local link1 = combo[1].itemLink
        local link2 = combo[2].itemLink
        local link3 = combo[3].itemLink
        local comboTuple = {link1, link2, link3}
        if not checkIfCombinationExists(comboTuple) then
            table.insert(combinationList, comboTuple)
            table.insert(uniqueCombos, combo)
        end
    end

    return uniqueCombos
end

function CraftSimGEARSIM:GetProfessionGearCombinations()
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

    -- an empty slot needs to be included to factor in the possibility of an empty slot needed if all combos are not valid
    -- e.g. the cases of the player not having enough items to fully equip
    local gearSlotItems = {{isEmptySlot = true, itemLink = "empty"}}
    local toolSlotItems = {{isEmptySlot = true,  itemLink = "empty"}}

    for _, gear in pairs(inventoryGear) do
        if gear.equipSlot == CraftSimCONST.PROFESSIONTOOL_INV_TYPES.GEAR then
            table.insert(gearSlotItems, gear)
        elseif gear.equipSlot == CraftSimCONST.PROFESSIONTOOL_INV_TYPES.TOOL then
            table.insert(toolSlotItems, gear)
        end
    end

    -- permutate the gearslot items to get all combinations of two
    local gearSlotCombos = {}
    for key, gear in pairs(gearSlotItems) do
        for subkey, subgear in pairs(gearSlotItems) do
            if subkey ~= key then
                -- do not match item with itself..
                -- todo: somehow neglect order cause it is not important (maybe with temp list to remove items from..)
                table.insert(gearSlotCombos, {gear, subgear})
            end
        end
    end
    -- then permutate those combinations with the tool items to get all available gear combos
    local totalCombos = {}
    for _, gearcombo in pairs(gearSlotCombos) do
        for _, tool in pairs(toolSlotItems) do
            table.insert(totalCombos, {tool, gearcombo[1], gearcombo[2]})
        end
    end

    local uniqueCombos = CraftSimGEARSIM:GetUniqueCombosFromAllPermutations(totalCombos)

    -- TODO: remove invalid combos (with two gear items that share the same unique equipped restriction)

    return uniqueCombos
end

function CraftSimGEARSIM:EquipBestProfessionGearCombination()
    print("start equip sim..")
    -- unequip all professiontools and just get from inventory for easier equipping/listing?
    local recipeData = CraftSimDATAEXPORT:exportRecipeData()
    local gearCombos = CraftSimGEARSIM:GetProfessionGearCombinations()

    -- TODO: simulate the mean profit for each combination
    -- TODO: extract the best simulation
    -- TODO: equip the p gear combi of the best simulation
end
