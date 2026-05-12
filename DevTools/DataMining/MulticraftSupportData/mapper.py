import sys
sys.path.append('../')
import wagoTools
import shutil

wagoTables = ["Profession", "SkillLine", "SkillLineAbility", "ModifiedCraftingSpellSlot", "SpellEffect", "CraftingData", "CraftingDataItemQuality", "ItemSparse"]
ALCHEMY_PROFESSION_ENUM = 3
CAULDRON_KEYWORD = "cauldron"

def copy(buildVersion):
    shutil.copy(f"_Result/{buildVersion}/multicraftSupportData.lua", "../../Data/multicraftSupportData.lua")

def map(buildVersion):
    csvTables = wagoTools.getWagoTables(wagoTables, False, buildVersion)
    professionTable = csvTables[0]
    skillLineTable = csvTables[1]
    skillLineAbilityTable = csvTables[2]
    modifiedCraftingSpellSlotTable = csvTables[3]
    spellEffectTable = csvTables[4]
    craftingDataTable = csvTables[5]
    craftingDataItemQualityTable = csvTables[6]
    itemSparseTable = csvTables[7]

    professionByRootSkillLine = {}
    for professionData in professionTable:
        professionEnum = int(professionData["ProfessionEnumValue"])
        if professionEnum > 0:
            professionByRootSkillLine[professionData["SkillLineID"]] = professionEnum

    parentBySkillLine = {}
    for skillLineData in skillLineTable:
        parentBySkillLine[skillLineData["ID"]] = skillLineData["ParentSkillLineID"]

    resolvedRootSkillLine = {}

    def getRootSkillLine(skillLineID):
        if skillLineID in resolvedRootSkillLine:
            return resolvedRootSkillLine[skillLineID]

        currentSkillLineID = skillLineID
        visited = set()
        while currentSkillLineID and currentSkillLineID != "0" and currentSkillLineID not in visited:
            visited.add(currentSkillLineID)
            parentSkillLineID = parentBySkillLine.get(currentSkillLineID, "0")
            if not parentSkillLineID or parentSkillLineID == "0":
                break
            currentSkillLineID = parentSkillLineID

        resolvedRootSkillLine[skillLineID] = currentSkillLineID
        return currentSkillLineID

    recipeSpellIDs = set()
    for slotData in modifiedCraftingSpellSlotTable:
        spellID = slotData["SpellID"]
        if spellID and spellID != "0":
            recipeSpellIDs.add(spellID)

    spellToProfession = {}
    for skillLineAbilityData in skillLineAbilityTable:
        spellID = skillLineAbilityData["Spell"]
        if spellID not in recipeSpellIDs:
            continue

        rootSkillLineID = getRootSkillLine(skillLineAbilityData["SkillLine"])
        professionEnum = professionByRootSkillLine.get(rootSkillLineID)
        if professionEnum:
            spellToProfession[int(spellID)] = professionEnum

    craftingDataByID = {}
    for craftingData in craftingDataTable:
        craftingDataByID[int(craftingData["ID"])] = craftingData

    qualityItemIDsByCraftingDataID = {}
    for qualityData in craftingDataItemQualityTable:
        craftingDataID = int(qualityData["CraftingDataID"])
        itemID = int(qualityData["ItemID"])
        if craftingDataID not in qualityItemIDsByCraftingDataID:
            qualityItemIDsByCraftingDataID[craftingDataID] = set()
        qualityItemIDsByCraftingDataID[craftingDataID].add(itemID)

    stackableByItemID = {}
    itemNameByID = {}
    for itemSparseData in itemSparseTable:
        itemID = int(itemSparseData["ID"])
        stackableByItemID[itemID] = int(itemSparseData["Stackable"])
        # Display_lang can contain extra data after a "|" separator in extracted DB2 text.
        # The first segment is the item name.
        itemNameByID[itemID] = itemSparseData.get("Display_lang", "").split("|")[0].strip().lower()

    craftingDataIDsBySpellID = {}
    for spellEffectData in spellEffectTable:
        if spellEffectData["Effect"] not in ["288", "301"]:
            continue

        spellID = int(spellEffectData["SpellID"])
        if spellID not in spellToProfession:
            continue

        craftingDataID = int(spellEffectData["EffectMiscValue_0"])
        if spellID not in craftingDataIDsBySpellID:
            craftingDataIDsBySpellID[spellID] = set()
        craftingDataIDsBySpellID[spellID].add(craftingDataID)

    multicraftSupportData = {}

    for spellID, professionEnum in spellToProfession.items():
        craftingDataIDs = craftingDataIDsBySpellID.get(spellID, set())
        supportsMulticraft = False

        for craftingDataID in craftingDataIDs:
            craftingData = craftingDataByID.get(craftingDataID)
            if not craftingData:
                continue

            if craftingData["Type"] == "3": # enchant recipes can stack but do not support multicraft
                continue

            craftedItemIDs = set()
            craftedItemID = int(craftingData["CraftedItemID"])
            if craftedItemID > 0:
                craftedItemIDs.add(craftedItemID)

            for qualityItemID in qualityItemIDsByCraftingDataID.get(craftingDataID, set()):
                craftedItemIDs.add(qualityItemID)

            if professionEnum == ALCHEMY_PROFESSION_ENUM and any(
                CAULDRON_KEYWORD.lower() in itemNameByID.get(itemID, "") for itemID in craftedItemIDs
            ):
                continue

            if any(stackableByItemID.get(itemID, 0) > 1 for itemID in craftedItemIDs):
                supportsMulticraft = True
                break

        if supportsMulticraft:
            if professionEnum not in multicraftSupportData:
                multicraftSupportData[professionEnum] = []
            multicraftSupportData[professionEnum].append(spellID)

    for professionEnum in multicraftSupportData:
        multicraftSupportData[professionEnum] = sorted(multicraftSupportData[professionEnum])

    wagoTools.writeLuaTable(multicraftSupportData, "multicraftSupportData", "---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.MULTICRAFT_SUPPORT_DATA = ", buildVersion)
