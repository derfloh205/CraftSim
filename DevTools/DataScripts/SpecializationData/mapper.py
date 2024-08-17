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
