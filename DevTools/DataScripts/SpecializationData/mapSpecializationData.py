import sys
import os
sys.path.append('../')
import wagoTools

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

if __name__ == '__main__':
    os.makedirs("Data/Latest", exist_ok=True)
    os.chdir("wow-profession-tree")
    exec(open('generate_database.py').read())
    exec(open('get_csv_output.py').read())
    os.chdir("..")
    os.replace('wow-profession-tree/output/profTalentData.csv', 'Data/Latest/profTalentData.csv')

    rawDataTable = wagoTools.loadCSVTables(["profTalentData"], None)[0]

    professionDataTable = {
        "DRAGONFLIGHT": {},
        "THE_WAR_WITHIN": {}
    }
    print("Mapping Profession Talents\n")
    count = 0
    total = len(rawDataTable)
    for row in rawDataTable:
        count = count + 1
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

        wagoTools.updateProgressBar(count, total, f"{expansion}->{profession}->{recipeID}")

        professionDataTable[expansion][profession]["recipeMapping"][recipeID].append(perkID)

        professionDataTable[expansion][profession]["nodeData"][perkID] = {
            "nodeID": nodeID,
            "maxRank": maxRank,
            "stat": stat.lower().replace(" ", "").replace("(dnt-writemanually!)", "").replace("(dnt-writemanually)", ""),
            "stat_amount": stat_amount,
        }

    print("\nWriting Lua Files")
    for expansion, professions in professionDataTable.items():
        for profession, dataTable in professions.items():
            resultFileName = expansion.upper() + "/" + profession
            prefix = f"---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.SPECIALIZATION_DATA.{expansion.upper()}.{profession.upper()}_DATA = "
            wagoTools.writeLuaTable(dataTable, resultFileName, prefix, None, True)
    print("Done")
