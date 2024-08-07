import sys
sys.path.append('../')
import db2Tools

buildVersion = "11.0.2.55959" # Beta 07.08.2024
db2Tables = ["Item", "ModifiedCraftingReagentItem", "CraftingReagentEffect", "ProfessionEffect", "ProfessionEffectType"]

if __name__ == '__main__':
    args = sys.argv[1:]
    download = len(args) > 0 and args[0] == "true"
    csvTables = db2Tools.getWagoTables(db2Tables, download, buildVersion)
    Item = csvTables[0]
    ModifiedCraftingReagentItem = csvTables[1]
    CraftingReagentEffect = csvTables[2]
    ProfessionEffect = csvTables[3]
    ProfessionEffectType = csvTables[4]

    # itemID -> qualityID, {stat: statvalue}
    optionalReagentsDataTable = {}

    for itemData in Item:
        if itemData["ClassID"] == "7": # TradeSkill
            isFinishing = itemData["SubclassID"] == "19"
            isOptional = itemData["SubclassID"] == "18"
            qualityID = int(itemData["CraftingQualityID"])
            itemID = int(itemData["ID"])
            if isFinishing or isOptional:
                modifiedCraftingReagentItemID = itemData["ModifiedCraftingReagentItemID"]
                for modifiedCraftingReagentItemData in ModifiedCraftingReagentItem:
                    if modifiedCraftingReagentItemData["ID"] == modifiedCraftingReagentItemID:
                        modifiedCraftingCategoryID = modifiedCraftingReagentItemData["ModifiedCraftingCategoryID"]
                        for craftingReagentEffectData in CraftingReagentEffect:
                            if craftingReagentEffectData["ModifiedCraftingCategoryID"] == modifiedCraftingCategoryID:
                                professionEffectID = craftingReagentEffectData["ProfessionEffectID"]
                                for professionEffectData in ProfessionEffect:
                                    if professionEffectData["ID"] == professionEffectID:
                                        amount = int(professionEffectData["Amount"])
                                        professionEffectTypeEnumID = professionEffectData["ProfessionEffectTypeEnumID"]
                                        if itemID not in optionalReagentsDataTable:
                                            optionalReagentsDataTable[itemID] = {
                                                "stats": []
                                            }
                                        if qualityID != None:
                                            optionalReagentsDataTable[itemID]["qualityID"] = qualityID
                                        for professionEffectTypeData in ProfessionEffectType:
                                            if professionEffectTypeData["ID"] == professionEffectTypeEnumID:
                                                stat = professionEffectTypeData["Name_lang"]
                                                optionalReagentsDataTable[itemID]["stats"].append({
                                                    "stat": stat.replace("(DNT - write manually)", "").replace("(DNT)", "").replace(" ", "").lower(),
                                                    "amount": amount
                                                })


    db2Tools.writeLuaTable(optionalReagentsDataTable, "OptionalReagentData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.OPTIONAL_REAGENT_DATA = ", buildVersion)
        