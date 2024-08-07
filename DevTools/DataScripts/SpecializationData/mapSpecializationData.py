import csv
import luadata

professionsDF = {
    "2822": "Blacksmithing",
    "2830": "Leatherworking",
    "2823": "Alchemy",
    "2832": "Herbalism",
    "2833": "Mining",
    "2831": "Tailoring",
    "2827": "Engineering",
    "2825": "Enchanting",
    "2834": "Skinning",
    "2829": "Jewelcrafting",
    "2828": "Inscription"
}

professionsTWW = {
     "2872": "Blacksmithing",
     "2880": "Leatherworking",
     "2871": "Alchemy",
     "2877": "Herbalism",
     "2881": "Mining",
     "2883": "Tailoring",
     "2875": "Engineering",
     "2874": "Enchanting",
     "2882": "Skinning",
     "2879": "Jewelcrafting",
     "2878": "Inscription"
}

def getRawDataForProfession():
    # Open the CSV file for reading
    with open('profTalentData.csv', mode='r') as file:
        # Create a CSV reader with DictReader
        csv_reader = csv.DictReader(file)
    
        # Initialize an empty list to store the dictionaries
        data_table = []
    
        # Iterate through each row in the CSV file
        for row in csv_reader:
            data_table.append(row)
    return data_table

def writeLuaTable(expansion, profession, dictData):
    luadata.write(expansion.upper() + "/" + profession + ".lua", dictData, encoding="utf-8", indent="\t", prefix="---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.SPECIALIZATION_DATA."+expansion.upper()+"."+profession.upper()+"_DATA = ")

if __name__ == '__main__':
    rawDataTable = getRawDataForProfession()

    print("rawDataTable: " + str(len(rawDataTable)))

    professionDataTable = {
        "DRAGONFLIGHT": {},
        "THE_WAR_WITHIN": {}
    }
    for row in rawDataTable:
        skillLineID = row["ProfessionExpansionID"]

        if not skillLineID:
            continue

        recipeID = int(row["SpellID"])
        perkID = int(row["TraitNodeID"])
        nodeID = int(row["ParentTraitNodeID"])
        maxRank = int(row["MaxRanks"])
        stat = row["Stat"]
        stat_amount = int(row["Amount"])

        professionDF = None
        professionTWW = None
        if skillLineID in professionsDF:
            professionDF = professionsDF[skillLineID]
        if skillLineID in professionsTWW:
            professionTWW = professionsTWW[skillLineID]

        if professionDF == None and professionTWW == None:
            continue

        expansion = None
        profession = None
        if professionDF is not None:
            expansion = "DRAGONFLIGHT"
            profession = professionDF
            
        if professionTWW is not None:
            expansion = "THE_WAR_WITHIN"
            profession = professionTWW

        if not profession in professionDataTable[expansion]:
            professionDataTable[expansion][profession] = {
                "recipeMapping": {},
                "nodeData": {},
            }

        if not recipeID in professionDataTable[expansion][profession]["recipeMapping"]:
            professionDataTable[expansion][profession]["recipeMapping"][recipeID] = []

        print("adding recipe for " + expansion + ": " + profession + "-> " + str(recipeID))
        professionDataTable[expansion][profession]["recipeMapping"][recipeID].append(perkID)

        professionDataTable[expansion][profession]["nodeData"][perkID] = {
            "nodeID": nodeID,
            "maxRank": maxRank,
            "stat": stat.lower().replace(" ", "").replace("(dnt-writemanually!)", "").replace("(dnt-writemanually)", ""),
            "stat_amount": stat_amount,
        }

    for expansion, professions in professionDataTable.items():
        for profession, dataTable in professions.items():
            writeLuaTable(expansion, profession, dataTable)
