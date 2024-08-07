import csv
import luadata

def getTradeSkillItemTable():
    # Open the CSV file for reading
    with open('Item.csv', mode='r') as file:
        # Create a CSV reader with DictReader
        csv_reader = csv.DictReader(file)
    
        # Initialize an empty list to store the dictionaries
        data_table = []
    
        # Iterate through each row in the CSV file
        for row in csv_reader:
            # Append each row (as a dictionary) to the list
            if row["ClassID"] == '7':
                if row["CraftingQualityID"] != '0':
                    if row["ModifiedCraftingReagentItemID"] != '0':
                        data_table.append(row)
    return data_table

def getReagentItemTable():
    # Open the CSV file for reading
    with open('ModifiedCraftingReagentItem.csv', mode='r') as file:
        # Create a CSV reader with DictReader
        csv_reader = csv.DictReader(file)
    
        # Initialize an empty list to store the dictionaries
        data_table = []
    
        # Iterate through each row in the CSV file
        for row in csv_reader:
            # Append each row (as a dictionary) to the list
            data_table.append(row)
    return data_table

def getCraftingCategoryTable():
    # Open the CSV file for reading
    with open('ModifiedCraftingCategory.csv', mode='r') as file:
        # Create a CSV reader with DictReader
        csv_reader = csv.DictReader(file)
    
        # Initialize an empty list to store the dictionaries
        data_table = []
    
        # Iterate through each row in the CSV file
        for row in csv_reader:
            # Append each row (as a dictionary) to the list
            if row["Field_10_0_0_44649_004"] == '1': # reagents
                if row["Field_9_0_1_33978_001"] != '1': # non test stuff?
                    if row["MatQualityWeight"] != '0': # only weighted mats are relevant
                        data_table.append(row)
    return data_table

def getItemWeight(reagentItemID, reagentItemTable, craftingCategoryTable):
    for reagentItem in reagentItemTable:
            if reagentItemID == reagentItem["ID"]:
                craftingCategoryID = reagentItem["ModifiedCraftingCategoryID"]
                for craftingCategory in craftingCategoryTable:
                    if craftingCategoryID == craftingCategory["ID"]:
                        return int(craftingCategory["MatQualityWeight"])
    return 0

def writeLuaTable(itemWeightTable):
    luadata.write("ReagentWeightData.lua", itemWeightTable, encoding="utf-8", indent="\t", prefix="---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.REAGENT_DATA = ")

if __name__ == '__main__':
    tradeSkillItemTable = getTradeSkillItemTable()
    reagentItemTable = getReagentItemTable()
    craftingCategoryTable = getCraftingCategoryTable()

    print("tradeSkillItemTable: " + str(len(tradeSkillItemTable)))
    print("reagentItemTable: " + str(len(reagentItemTable)))
    print("craftingCategoryTable: " + str(len(craftingCategoryTable)))

    itemWeightTable = {}

    for item in tradeSkillItemTable:
        itemID = item["ID"]
        reagentItemID = item["ModifiedCraftingReagentItemID"]
        weight = getItemWeight(reagentItemID, reagentItemTable, craftingCategoryTable)
        if weight and weight > 0:
            itemWeightTable[int(itemID)] = {"weight": weight}

    #for itemID, itemData in itemWeightTable.items():
    #    print(str(itemID) + " weight: " + str(itemData["weight"]))

    writeLuaTable(itemWeightTable)
        