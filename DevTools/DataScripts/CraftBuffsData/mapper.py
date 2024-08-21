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

def map():

    rawDataTable = wagoTools.loadCSVTables(["csv_buff_traits"], None)[0]

    buffDataMap = {}

    print("Mapping Buffs\n")
    count = 0
    total = len(rawDataTable)
    for row in rawDataTable:
        count = count + 1

        spellID = int(row["SpellID"])
        affectedSpellID = int(row["AffectedSpellID"])
        amount = int(row["Amount"])
        stat = row["Stat"]

        wagoTools.updateProgressBar(count, total, spellID)

        cleanStatName = stat.lower().replace(" ", "").replace("(dnt-writemanually!)", "").replace("(dnt-writemanually)", "")

        if not spellID in buffDataMap:
            buffDataMap[spellID] = {
                "spellID": spellID,
                "affectedSpellIDs": [],
                "stats": {}
            }

        buffDataMap[spellID]["stats"][cleanStatName] = amount

        if not affectedSpellID in buffDataMap[spellID]["affectedSpellIDs"]:
            buffDataMap[spellID]["affectedSpellIDs"].append(affectedSpellID)

    
    wagoTools.writeLuaTable(buffDataMap, "CraftBuffData", "CraftBuffData = ", None, True)
    

if __name__ == '__main__':
    map()
