import sys
sys.path.append('../')
import wagoTools

buildVersion = "11.0.2.56044" # Beta 08.08.2024
wagoTables = ["Item", "ModifiedCraftingReagentItem", "CraftingReagentEffect", "ProfessionEffect", "ProfessionEffectType", "CraftingReagentQuality", "ItemSparse"]

def printD(text, enabled):
    if enabled:
        print(text)

if __name__ == '__main__':
    args = sys.argv[1:]
    download = len(args) > 0 and args[0] == "true"
    wagoTables = wagoTools.getWagoTables(wagoTables, download, buildVersion)
    Item = wagoTables[0]
    ModifiedCraftingReagentItem = wagoTables[1]
    CraftingReagentEffect = wagoTables[2]
    ProfessionEffect = wagoTables[3]
    ProfessionEffectType = wagoTables[4]
    CraftingReagentQualityTable = wagoTables[5]
    ItemSparse = wagoTables[6]

    # itemID -> qualityID, {stat: statvalue}
    optionalReagentsDataTable = {}

    optionalReagents = wagoTools.searchTable(Item, {"conditions": {"ClassID": "7", "SubclassID": "18"}})
    finishingReagents = wagoTools.searchTable(Item, {"conditions": {"ClassID": "7", "SubclassID": "19"}})

    Reagents = optionalReagents + finishingReagents

    print("Mapping Optional Items")
    counter = 0
    reagentCount = len(Reagents)
    for reagentData in Reagents:
        counter = counter + 1
        itemID = int(reagentData["ID"])

        debug = False

        wagoTools.updateProgressBar(counter, reagentCount, itemID)

        itemSparseData = wagoTools.searchTable(ItemSparse, {"singleResult": True, "conditions": {"ID": str(itemID)}})

        if not itemSparseData:
            continue # item does not exist

        itemName = itemSparseData["Display_lang"]

        if "delete me" in itemName.lower():
            continue

        expansionID = int(itemSparseData["ExpansionID"])
        qualityID = int(reagentData["CraftingQualityID"])
        
        modifiedCraftingReagentItemID = reagentData["ModifiedCraftingReagentItemID"]
        
        
        printD(f"modifiedCraftingReagentItemID: {modifiedCraftingReagentItemID}", debug)

        craftingReagentQuality = wagoTools.searchTable(CraftingReagentQualityTable, {"singleResult": True, "conditions": {"ItemID": str(itemID)}})

        if craftingReagentQuality:
            difficultyIncrease = int(craftingReagentQuality["MaxDifficultyAdjustment"])
            if difficultyIncrease > 0:
                optionalReagentsDataTable[itemID] = {
                    "qualityID": qualityID,
                    "name": itemName,
                    "expansionID": expansionID,
                    "stats": [
                        {
                            "increasedifficulty": difficultyIncrease
                        }
                    ]
                }
                continue

        modifiedCraftingReagent = wagoTools.searchTable(ModifiedCraftingReagentItem, {"singleResult": True, "conditions": {"ID": modifiedCraftingReagentItemID}})
        if not modifiedCraftingReagent:
            continue

        printD(f"categoryID: {modifiedCraftingReagent["ModifiedCraftingCategoryID"]}", debug)

        craftingReagentEffects = wagoTools.searchTable(CraftingReagentEffect, {"conditions": {"ModifiedCraftingCategoryID": modifiedCraftingReagent["ModifiedCraftingCategoryID"]}})

        if len(craftingReagentEffects) == 0:
            continue

        statList = []
        for craftingReagentEffect in craftingReagentEffects:
            professionEffects = wagoTools.searchTable(ProfessionEffect, {"conditions": {"ID": craftingReagentEffect["ProfessionEffectID"]}})
            for professionEffect in professionEffects:
                professionEffectEnum = wagoTools.searchTable(ProfessionEffectType, {"singleResult": True, "conditions": {"EnumID": professionEffect["ProfessionEffectTypeEnumID"]}})
                if not professionEffectEnum:
                    continue
                statName = professionEffectEnum["Name_lang"].replace("(DNT - write manually)", "").replace("(DNT - write manually!)", "").replace("(DNT)", "").replace(" ", "").lower()
                if statName == "dummyeffectfor#tokenization":
                    continue
                amount = int(professionEffect["Amount"])
                statList.append({
                    "stat": statName,
                    "amount": amount
                })
                printD(f"- ProfessionEffect {professionEffect["ID"]} / {professionEffectEnum["ID"]} : {statName} -> {amount}", debug)

        if len(statList) > 0:
            optionalReagentsDataTable[itemID] = {
                "qualityID": qualityID,
                "name": itemName,
                "expansionID": expansionID,
                "stats": statList,
            }

    wagoTools.writeLuaTable(optionalReagentsDataTable, "OptionalReagentData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.OPTIONAL_REAGENT_DATA = ", buildVersion)
        