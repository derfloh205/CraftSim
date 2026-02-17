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

# for missing or incorrect blizz data..
patchedIDs = {
    "The_War_Within": {
        "Blacksmithing": {
            # Everburning Forge
            "99267": {
                    "nodeID": 99267,
                    "maxRank": 40,
                    "stats": {
                    },
                },
            # Everburning Forge - Imaginative Foresight - Base
            "99266": {
                    "nodeID": 99266,
                    "maxRank": 20,
                    "stats": {
                        "ingenuity": 3,
                    },
                },
            # Everburning Forge - Imaginative Foresight - 1
            "99254": {
                    "nodeID": 99266,
                    "maxRank": 1,
                    "stats": {
                        "ingenuity": 10,
                    },
                },
            # Everburning Forge - Imaginative Foresight - 2
            "99253": {
                    "nodeID": 99266,
                    "maxRank": 1,
                    "stats": {
                        "ingenuity": 10,
                    },
                },
            # Everburning Forge - Imaginative Foresight - 3
            "99252": {
                    "nodeID": 99266,
                    "maxRank": 1,
                    "stats": {
                        "ingenuity": 10,
                    },
                },
            # Everburning Forge - Imaginative Foresight - 4
            "99251": {
                    "nodeID": 99266,
                    "maxRank": 1,
                    "stats": {
                        "ingenuity": 10,
                    },
                },
            # Everburning Forge - Imaginative Foresight - 5
            "99250": {
                    "nodeID": 99266,
                    "maxRank": 1,
                    "stats": {
                        "ingenuity": 10,
                    },
                },
            # Everburning Forge - Discerning Discipline - Base
            "99265": {
                    "nodeID": 99265,
                    "maxRank": 20,
                    "stats": {
                        "resourcefulness": 3,
                    },
                },
            # Everburning Forge - Discerning Discipline - 1
            "99249": {
                    "nodeID": 99265,
                    "maxRank": 1,
                    "stats": {
                        "resourcefulness": 15,
                    },
                },
            # Everburning Forge - Discerning Discipline - 2
            "99248": {
                    "nodeID": 99265,
                    "maxRank": 1,
                    "stats": {
                        "resourcefulness": 15,
                    },
                },
            # Everburning Forge - Discerning Discipline - 3
            "99247": {
                    "nodeID": 99265,
                    "maxRank": 1,
                    "stats": {
                        "resourcefulness": 15,
                    },
                },
            # Everburning Forge - Discerning Discipline - 4
            "99246": {
                    "nodeID": 99265,
                    "maxRank": 1,
                    "stats": {
                        "resourcefulness": 15,
                    },
                },
            # Everburning Forge - Discerning Discipline - 5
            "99245": {
                    "nodeID": 99265,
                    "maxRank": 1,
                    "stats": {
                        "resourcefulness": 15,
                    },
                },
            # Everburning Forge - Gracious Forging - Base
            "99264": {
                    "nodeID": 99264,
                    "maxRank": 20,
                    "stats": {
                        "multicraft": 3,
                    },
                },
            # Everburning Forge - Gracious Forging - 1
            "99244": {
                    "nodeID": 99264,
                    "maxRank": 1,
                    "stats": {
                        "multicraft": 10,
                    },
                },
            # Everburning Forge - Gracious Forging - 2
            "99243": {
                    "nodeID": 99264,
                    "maxRank": 1,
                    "stats": {
                        "multicraft": 10,
                    },
                },
            # Everburning Forge - Gracious Forging - 3
            "99242": {
                    "nodeID": 99264,
                    "maxRank": 1,
                    "stats": {
                        "multicraft": 10,
                    },
                },
            # Everburning Forge - Gracious Forging - 4
            "99241": {
                    "nodeID": 99264,
                    "maxRank": 1,
                    "stats": {
                        "multicraft": 10,
                    },
                },
            # Everburning Forge - Gracious Forging - 5
            "99240": {
                    "nodeID": 99264,
                    "maxRank": 1,
                    "stats": {
                        "multicraft": 10,
                    },
                },
        }
    }
}

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

professionsMid = {
     "2907": "Blacksmithing",
     "2915": "Leatherworking",
     "2906": "Alchemy",
     "2912": "Herbalism",
     "2916": "Mining",
     "2918": "Tailoring",
     "2910": "Engineering",
     "2909": "Enchanting",
     "2917": "Skinning",
     "2914": "Jewelcrafting",
     "2913": "Inscription"
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
        "The_War_Within": {},
        "Midnight": {}
    }
    print("Mapping Profession Talents\n")
    count = 0
    total = len(rawDataTable)
    print(f"Processing {total} rows")
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

        professionDF = None
        professionTWW = None
        professionMid = None
        if skillLineID in professionsDF:
            professionDF = professionsDF[skillLineID]
        if skillLineID in professionsTWW:
            professionTWW = professionsTWW[skillLineID]
        if skillLineID in professionsMid:
            professionMid = professionsMid[skillLineID]

        if professionDF == None and professionTWW == None and professionMid == None:
            continue

        expansion = None
        profession = None
        if professionDF is not None:
            expansion = "Dragonflight"
            profession = professionDF

        if professionTWW is not None:
            expansion = "The_War_Within"
            profession = professionTWW

        if professionMid is not None:
            expansion = "Midnight"
            profession = professionMid

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

    # apply patch
    for expansion, expansionData in patchedIDs.items():
        for profession, patchedIDsList in expansionData.items():
            for patchedNodeID, nodeData in patchedIDsList.items():
                professionDataTable[expansion][profession]["nodeData"][int(patchedNodeID)] = nodeData

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
