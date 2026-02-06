import sys
sys.path.append('../')
import wagoTools
import shutil

wagoTables = ["Item", "ModifiedCraftingReagentItem", "CraftingReagentEffect", "ProfessionEffect", "ProfessionEffectType", "CraftingReagentQuality", "ItemSparse", "CurrencyTypes", "CurrencyCategory"]

def copy(buildVersion):
    shutil.copy(f"Result/{buildVersion}/OptionalReagentData.lua", "../../../Data/OptionalReagentData.lua")
    shutil.copy(f"Result/{buildVersion}/OptionalCurrencyReagentData.lua", "../../../Data/OptionalCurrencyReagentData.lua")

def printD(text, enabled):
    if enabled:
        print(text)

def map(download, buildVersion):
    dataTables = wagoTools.getWagoTables(wagoTables, download, buildVersion)
    Item = dataTables[0]
    ModifiedCraftingReagentItem = dataTables[1]
    CraftingReagentEffect = dataTables[2]
    ProfessionEffect = dataTables[3]
    ProfessionEffectType = dataTables[4]
    CraftingReagentQualityTable = dataTables[5]
    ItemSparse = dataTables[6]
    CurrencyTypes = dataTables[7]
    CurrencyCategory = dataTables[8]

    # itemID -> qualityID, {stat: statvalue}
    optionalReagentsDataTable = {}

    # currencyID -> qualityID, {stat: statvalue}
    optionalCurrencyReagentsDataTable = {}

    optionalReagents = wagoTools.searchTable(Item, {"conditions": {"ClassID": "7", "SubclassID": "18"}})
    finishingReagents = wagoTools.searchTable(Item, {"conditions": {"ClassID": "7", "SubclassID": "19"}})
    sparkReagents = wagoTools.searchTable(Item, {"conditions": {"ClassID": "7", "SubclassID": "11"}})
    currencyReagents = wagoTools.searchTable(CurrencyTypes, {"conditions": {"CategoryID": "268", "Flags_0": "2359490"}}) # 268 is Midnight Season 1 and Flags_0 differentiates from non-crafting currencies (i.e. Coffer Keys & Shards and Spark residue)
    #sparkReagents = wagoTools.searchTable(Item, {"conditions": {"ClassID": "7", "SubclassID": "11", "CraftingQualityID": "0"}})
    # Filter to recieve spark reagents only
    #sparkReagents = [sparkReagent for sparkReagent in sparkReagents if int(sparkReagent["ModifiedCraftingReagentItemID"]) > 0]

    Reagents = optionalReagents + finishingReagents + sparkReagents + currencyReagents
    print("Mapping Optional Items")
    print("#optionalReagents: " + str(len(optionalReagents)))
    print("#finishingReagents: " + str(len(finishingReagents)))
    print("#sparkReagents: " + str(len(sparkReagents)))
    print("#currencyReagents: " + str(len(currencyReagents)))
    counter = 0
    reagentCount = len(Reagents)
    for reagentData in Reagents:
        counter += 1
        itemID = int(reagentData["ID"]) if "ClassID" in reagentData else None
        currencyID = int(reagentData["ID"]) if "CategoryID" in reagentData else None
        isOptional = reagentData["SubclassID"] == "18" if itemID is not None else True
        isFinishing = reagentData["SubclassID"] == "19" if itemID is not None else False
        isSpark = reagentData["SubclassID"] == "11" if itemID is not None else False

        if itemID is not None:
            craftingReagentQuality = wagoTools.searchTable(CraftingReagentQualityTable, {"singleResult": True, "conditions": {"ItemID": str(itemID)}})
        if currencyID is not None:
            results = wagoTools.searchTable(CraftingReagentQualityTable, {"conditions": {"CurrencyTypesID": str(currencyID)}})
            # data is dirty, there's a test entry for each type of Dawncrest (except Champion as it is not used as a reagent)
            craftingReagentQuality = results[0] if len(results) == 1 else results[0] if results[0]["MaxDifficultyAdjustment"] != "0" else results[1]

        qualityID = 0
        modifiedCraftingCategoryID = None
        if craftingReagentQuality:
            qualityID = int(craftingReagentQuality["OrderIndex"])+1
            modifiedCraftingCategoryID = craftingReagentQuality["ModifiedCraftingCategoryID"]

        #if isSpark and qualityID > 0:
           # printD(f"Skipping spark reagent with quality > 0: {itemID}", debug)
           # continue

        debug = False
        debugItemID = 210232

        if debug and itemID != debugItemID:
            continue

        wagoTools.updateProgressBar(counter, reagentCount, itemID or currencyID)

        if itemID is not None:
            itemSparseData = wagoTools.searchTable(ItemSparse, {"singleResult": True, "conditions": {"ID": str(itemID)}})

            if not itemSparseData:
                printD(f"ItemSparse data not found for itemID {itemID}", debug)
                continue # item does not exist

            itemName = itemSparseData["Display_lang"]

            if "delete me" in itemName.lower():
                printD(f"Skipping item with 'delete me' in name: {itemName} (ID: {itemID})", debug)
                continue


            expansionID = int(itemSparseData["ExpansionID"])

        if currencyID is not None:
            currencyData = wagoTools.searchTable(CurrencyTypes, {"singleResult": True, "conditions": {"ID": str(currencyID)}})
            itemName = currencyData["Name_lang"]
            currencyCategoryData = wagoTools.searchTable(CurrencyCategory, {"singleResult": True, "conditions": {"ID": str(reagentData["CategoryID"])}})
            expansionID = int(currencyCategoryData["ExpansionID"])        

        #modifiedCraftingReagentItemID = reagentData["ModifiedCraftingReagentItemID"]
        #printD(f"modifiedCraftingReagentItemID: {modifiedCraftingReagentItemID}", debug)

        if craftingReagentQuality and (isOptional or isSpark):
            difficultyIncrease = int(craftingReagentQuality["MaxDifficultyAdjustment"])
            if difficultyIncrease > 0:
                if itemID is not None:
                    optionalReagentsDataTable[itemID] = {
                        "qualityID": 0 if isSpark else qualityID,
                        "name": itemName,
                        "expansionID": expansionID,
                        "stats": {
                                "increasedifficulty": difficultyIncrease
                            }
                        
                    }
                if currencyID is not None:
                    optionalCurrencyReagentsDataTable[currencyID] = {
                        "qualityID": qualityID,
                        "name": itemName,
                        "expansionID": expansionID,
                        "stats": {
                                "increasedifficulty": difficultyIncrease
                            }
                        
                    }
                continue

        reagentEffectPct = 1
        if craftingReagentQuality and len(craftingReagentQuality) > 0 and isFinishing:
            reagentEffectPct = float(craftingReagentQuality["ReagentEffectPct"]) / 100


        #modifiedCraftingReagent = wagoTools.searchTable(ModifiedCraftingReagentItem, {"singleResult": True, "conditions": {"ID": modifiedCraftingReagentItemID}})
        if not modifiedCraftingCategoryID:
            continue

        printD(f"categoryID: {modifiedCraftingCategoryID}", debug)

        craftingReagentEffects = wagoTools.searchTable(CraftingReagentEffect, {"conditions": {"ModifiedCraftingCategoryID": modifiedCraftingCategoryID}})

        printD(f"Found {len(craftingReagentEffects)} CraftingReagentEffects for item {itemID}", debug)

        if len(craftingReagentEffects) == 0:
            printD(f"No CraftingReagentEffects found for item {itemID}", debug)
            continue

        statMap = {}
        for craftingReagentEffect in craftingReagentEffects:
            professionEffects = wagoTools.searchTable(ProfessionEffect, {"conditions": {"ID": craftingReagentEffect["ProfessionEffectID"]}})
            for professionEffect in professionEffects:
                professionEffectEnum = wagoTools.searchTable(ProfessionEffectType, {"singleResult": True, "conditions": {"EnumID": professionEffect["ProfessionEffectTypeEnumID"]}})
                if not professionEffectEnum:
                    continue
                statName = professionEffectEnum["Name_lang"].replace("(DNT - write manually)", "").replace("(DNT - write manually!)", "").replace("(DNT)", "").replace(" ", "").lower()
                if statName == "dummyeffectfor#tokenization":
                    continue

                amount = int(professionEffect["Amount"]) * reagentEffectPct
                statMap[statName] = amount
                printD(f"- ProfessionEffect {professionEffect['ID']} / {professionEffectEnum['ID']} : {statName} -> {amount}", debug)

        printD(f"Final StatMap for item {itemID}: {statMap}", debug)
        if len(statMap) > 0:
            optionalReagentsDataTable[itemID] = {
                "qualityID": 0 if isSpark else qualityID,
                "name": itemName,
                "expansionID": expansionID,
                "stats": statMap,
            }

    wagoTools.writeLuaTable(optionalReagentsDataTable, "OptionalReagentData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.OPTIONAL_REAGENT_DATA = ", buildVersion)
    wagoTools.writeLuaTable(optionalCurrencyReagentsDataTable, "OptionalCurrencyReagentData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.OPTIONAL_CURRENCY_REAGENT_DATA = ", buildVersion)

def update(buildVersion):
    map(True, buildVersion)
    copy(buildVersion)        

if __name__ == '__main__':
    args = sys.argv[1:]
    buildVersion = (len(args) > 0 and args[0]) or "Latest"

    update(buildVersion)