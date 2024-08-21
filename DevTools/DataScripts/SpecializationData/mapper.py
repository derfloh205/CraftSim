import sys
import os
sys.path.append('../')
import wagoTools
import shutil
import urllib

import sqlite3
import csv
import http.client
import json
import urllib.parse
import requests
from pathlib import Path

# because blizzard does not clean up its databases..
outdatedNodeIDs = [
    # TWW Tailoring
    ## Threads of Devotion
    101419, 100431, 100603, 100517,
    ## Hats
    101415, 100592, 100427, 100513,
    ## Weathering Wear
    100595, 100516, 100430, 101418,
    ## Cloaks
    100512, 100591, 101414, 100426,
    ## Making a Statement
    100422, 100508, 100599, 101410, 
    ## Belts
    100419, 100505, 100596, 101407, 
    ## Armbands
    100420, 100506, 100597, 101408, 
    ## Gloves
    100594, 101417, 100429, 100515,
    ## Footwear
    100428, 100593, 101416, 100514,
    ## Weighted Garments
    100425, 100511, 100602, 101413, 
    ## Leggings
    100423, 100509, 100600, 101411, 
    ## Mantles
    100421, 100507, 100598, 101409, 
    ## Robes
    100424, 100510, 100601, 101412, 
    ## From Dawn Until Dusk
    100306, 
    ## Dawnweaving
    100304, 
    ## Dawnweave Tailoring
    100305, 
    ## Duskweaving
    100302, 
    ## Duskweave Tailoring
    100303, 
]

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

def map():
    # os.makedirs("Data/Latest", exist_ok=True)
    # os.chdir("wow-profession-tree")
    # exec(open('generate_database.py').read())
    # exec(open('profession_traits/get_csv_output.py').read())
    # os.chdir("..")
    # os.replace('wow-profession-tree/output/csv_profession_traits.csv', 'Data/Latest/csv_profession_traits.csv')

    rawDataTable = wagoTools.loadCSVTables(["csv_profession_traits"], None)[0]

    professionDataTable = {
        "Dragonflight": {},
        "The_War_Within": {}
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
        nodeName = row["NodeName"] or ""

        # ignore outdated nodeIDs
        if perkID in outdatedNodeIDs:
            continue
        if nodeID in outdatedNodeIDs:
            continue

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
            expansion = "Dragonflight"
            profession = professionDF
            
        if professionTWW is not None:
            expansion = "The_War_Within"
            profession = professionTWW

        if not profession in professionDataTable[expansion]:
            professionDataTable[expansion][profession] = {
                "recipeMapping": {},
                "nodeData": {},
            }

        if not recipeID in professionDataTable[expansion][profession]["recipeMapping"]:
            professionDataTable[expansion][profession]["recipeMapping"][recipeID] = []

        wagoTools.updateProgressBar(count, total, f"{expansion}->{profession}->{recipeID}")

        if not perkID in professionDataTable[expansion][profession]["recipeMapping"][recipeID]:
            professionDataTable[expansion][profession]["recipeMapping"][recipeID].append(perkID)

        if not perkID in professionDataTable[expansion][profession]["nodeData"]:
            professionDataTable[expansion][profession]["nodeData"][perkID] = {
                "nodeID": nodeID,
                "maxRank": maxRank,
                "stats": {}
            }

        cleanStatName = stat.lower().replace(" ", "").replace("(dnt-writemanually!)", "").replace("(dnt-writemanually)", "")
        professionDataTable[expansion][profession]["nodeData"][perkID]["stats"][cleanStatName] = stat_amount
    

    print("\nWriting Lua Files")
    for expansion, professions in professionDataTable.items():
        for profession, dataTable in professions.items():
            resultFileName = expansion + "/" + profession
            prefix = f"---@class CraftSim\nlocal CraftSim = select(2, ...)\nCraftSim.SPECIALIZATION_DATA.{expansion.upper()}.{profession.upper()}_DATA = "
            wagoTools.writeLuaTable(dataTable, resultFileName, prefix, None, True)
    print("Done")

    # copy to destination
    for expansion, professions in professionDataTable.items():
        os.makedirs(f"../../../Data/SpecializationData/{expansion}", exist_ok=True)
        for profession, dataTable in professions.items():
            shutil.copy(f"Result/Latest/{expansion}/{profession}.lua", f"../../../Data/SpecializationData/{expansion}/{profession}.lua")

if __name__ == '__main__':
    map()
